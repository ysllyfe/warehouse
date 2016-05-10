# == Schema Information
#
# Table name: warehouse_categories
#
#  id                 :integer          not null, primary key
#  name               :string
#  warehouseable_ids  :integer          default([]), is an Array
#  warehouseable_type :string
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  warehouse_categories_warehouseable  (warehouseable_ids,warehouseable_type)
#

module Warehouse
  class Category < ActiveRecord::Base
    # belongs_to :warehouseable, polymorphic: true
    has_many :stocks, foreign_key: "warehouse_id"
    has_many :orders, foreign_key: "warehouse_id"
    has_many :order_items, foreign_key: "warehouse_id"

    scope :common_category, -> { where(superset: false) }
    scope :superset,        -> { where(superset: true).first }

    class << self

      def merge_warehouse_stocks(goods_stocks,other_goods_stocks)
        goods_stocks.each_with_index do |t,index|
          t.merge!({:other_amount=>select_stocks(other_goods_stocks,t[:id])})
        end
      end

      def select_stocks(stocks,id)
        stocks.each do |stock|
          return stock[:amount] if stock[:id] == id
        end
      end

      def merge_warehouse(ids)
        raise 'Argument Error, merge_warehouse(ids) ids must be an array with warehouse id' unless ids.kind_of?(Array)
        return if ids.count == 1
        category = find(ids.shift)
        categories = find(ids)
        categories.each do |cate|
          cate.merge_warehouse_to(category.id)
          category.warehouseable_ids += cate.warehouseable_ids
          category.name = "#{category.name}#{cate.name}"
          cate.delete
        end
        category.save
      end

    end

    # 手动改库存，一定会自动建一条订单，不允许直接对stocks表进行操作
    # params goods_id:商品ID，amount:采购数量，price:单价
    def add_stocks(goods_id, amount, price)
      superset_category = self.class.superset
      amount = amount.to_i
      if amount < 0
        # superset_category为购方
        order_items = OrderItem.new({warehouse_id:superset_category.id,goods_id:goods_id, quantity:amount.abs, unit_price:price})
        order = Order.new(sale_warehouse: self.id,purchase_warehouse:superset_category.id)
        order.order_items << order_items
      else
        # superset_category为销方
        order_items = OrderItem.new({warehouse_id:self.id,goods_id:goods_id, quantity:amount.abs, unit_price:price})
        order = Order.new(sale_warehouse: superset_category.id,purchase_warehouse:self.id)
        order.order_items << order_items
      end
      # 变更order状态
      if order.save
        order.may_ship? && order.ship!
        order.may_done? && order.done!
      end
    end

    #合并仓库时候需要更新的数据
    def merge_warehouse_to(id)
      stocks.update_all(warehouse_id:id)
      purchase_orders.update_all(purchase_warehouse:id)
      sale_orders.update_all(sale_warehouse:id)
    end

    # 能够预订的仓库
    def can_purchase_warehouses
      self.class.where.not(id:self.id)
    end

    # 能够预订的仓库的collection for select
    def can_purchase_warehouses_collection
      can_purchase_warehouses.map do |t|
        [t.full_name, t.id]
      end
    end

    # 能够并仓的仓库，要求warehouseable_type一致
    def can_merge_warehouses
      self.class.where(warehouseable_type: warehouseable_type)
    end

    # 子节点
    def children
      return if superset
      warehouseable_type.classify.constantize.where(id: warehouseable_ids)
    end

    # 子节点名称
    def children_name
      children.inject([]) do |mem,t|
        mem << t.try(opts[:name])
      end
    end

    # 返回代理的对象，superset无代理对象
    def delegate_obj
      return nil if superset
      children.first
    end

    # 仓库的类型，解释型
    def warehouse_type
      return 'Superset' if superset
      opts[:type] || warehouseable_type
    end

    # 全名
    def full_name
      "#{opts[:type]} > #{name}"
    end

    # 仓库库存
    def goods_stocks
      exists_stocks = stocks.inject({}) do |mem, item|
        if mem[item.goods_id]
          mem[item.goods_id] += item.amount
        else
          mem[item.goods_id] = item.amount
        end
        mem
      end
      goods_list = opts[:goods_class_name].classify.constantize.all
      warehouse_stocks = []
      goods_list.each do |good|
        warehouse_stocks << goods_stock_item(good, exists_stocks)
      end
      warehouse_stocks
    end

    # 取opts
    def opts
      return { goods_class_name:goods_class_name, name:m_name, goods_name:goods_name } if superset
      delegate_obj.get_warehouse_opts
    end

    def purchase_orders
      Warehouse::Order.where(purchase_warehouse:id)
    end

    def sale_orders
      Warehouse::Order.where(sale_warehouse:id)
    end

    private
    def goods_stock_item(good, exists_stocks)
      {
        id: good.id,
        class: good.class.to_s,
        name: good.name,
        guidance_price: good.guidance_price,
        cost_price: good.cost_price,
        brand_id: good.brand_id,
        product_category_id: good.product_category_id,
        amount: exists_stocks[good.id] ? exists_stocks[good.id] : 0
      }
    end
  end
end
