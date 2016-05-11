# == Schema Information
#
# Table name: warehouse_orders
#
#  id                 :integer          not null, primary key
#  purchase_warehouse :integer
#  sale_warehouse     :integer
#  price              :decimal(, )
#  status             :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_warehouse_orders_on_purchase_warehouse  (purchase_warehouse)
#  index_warehouse_orders_on_sale_warehouse      (sale_warehouse)
#

module Warehouse
  class Order < Base
    include AASM

    before_save :record_status_change, if: -> {status_changed?}

    has_many :order_items, foreign_key: "warehouse_order_id"
    has_many :order_memos, foreign_key: "warehouse_order_id"
    before_save :price_amount

    enum status: {
      created:     0,     #订单 创建
      canceled:    10,    #订单 取消
      shipping:    100,   #订单 发货
      complete:    200    #订单 收货
    }

    def transitions_to(state)
      return false if state.blank?
      states, event = before_status(state)
      return true if states.include?(state) && self.send("may_#{event}?") && self.send("#{event}!")
      return false
    end

    def before_status(state)
      case state
      when 'created'
        [ [], nil]
      when 'canceled'
        [ ['created' , 'shipping'], 'cancel']
      when 'shipping'
        [ ['created'] , 'ship']
      when 'complete'
        [ ['shipping'] , 'done']
      end
    end

    aasm :column => :status, :enum => true do

      state :created, :initial => true
      state :canceled
      state :shipping
      state :complete

      event :ship do
        transitions from: [:created], to: :shipping
      end

      event :done do
        transitions from: [:shipping], to: :complete
      end

      event :cancel do
        transitions :from => [:created, :shipping], :to => :canceled
      end

    end

    def record_status_change
      raise 'Error, status change must through AASM.' unless aasm.current_event
      case aasm.current_event.to_s
      when /ship/
        # 对应供应方的库存减少
        add_stock(sale,'-')
      when /done/
        # 对应采购人的库存增加
        add_stock(purchase,'+')
      when /cancel/
        # 是否shipping，是的话，要回退商品库存
        status_was == 'shipping' && add_stock(sale,'+')
        true
      end
    end

    def add_stock(category,direction='+')
      order_items.each do |t|
        amount = direction == '+' ? t.quantity : -t.quantity
        Stock.create(warehouse_id:category.id,goods_id:t.goods_id,amount:amount,warehouse_order_id:id)
        # good list touch
        Good.touch_goods(warehouse_id:category.id,goods_id:t.goods_id,cost:t.unit_price)
      end
    end

    def editable_by?(warehouse_id)
      return nil unless [purchase_warehouse, sale_warehouse].include?(warehouse_id)
      true
    end

    def purchase
      Category.find(purchase_warehouse)
    end

    def sale
      Category.find(sale_warehouse)
    end

    def operation_status
      self.class.statuses.map do |t,val|
        [t, val]
      end
    end

    private
    def price_amount
      self.price = order_items.map(&:live_price).sum
    end
  end
end
