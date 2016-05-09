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

    def add_stocks(goods_id, amount)
      stocks << Stock.new(goods_id:goods_id, amount:amount)
    end

    def merge_warehouse_to(id)
      #合并仓库时候需要修改的数据
      stocks.update_all(warehouse_id:id)
      purchase_orders.update_all(purchase_warehouse:id)
      sale_orders.update_all(sale_warehouse:id)
    end

    def can_purchase_warehouses
      self.class.all.where.not(id:self.id)
    end

    def can_purchase_warehouses_collection
      can_purchase_warehouses.map do |t|
        [t.full_name, t.id]
      end
    end

    def can_merge_warehouses
      self.class.where(warehouseable_type: warehouseable_type)
    end

    def children
      warehouseable_type.classify.constantize.where(id: warehouseable_ids)
    end

    def delegate_obj
      children.first
    end

    def warehouse_type
      opts[:type] || warehouseable_type
    end

    def full_name
      "#{opts[:type]} > #{name}"
    end

    def goods_stocks
      delegate_obj.goods_stocks
    end

    def opts
      delegate_obj.get_warehouse_opts
    end

    def children_name
      children.inject([]) do |mem,t|
        mem << t.try(t.get_warehouse_opts[:name])
      end
    end

    def purchase_orders
      Warehouse::Order.where(purchase_warehouse:id)
    end

    def sale_orders
      Warehouse::Order.where(sale_warehouse:id)
    end
  end
end
