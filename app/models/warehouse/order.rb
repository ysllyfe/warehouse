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

    has_many :order_items, foreign_key: "warehouse_order_id"
    has_many :order_memos, foreign_key: "warehouse_order_id"
    before_save :price_amount

    enum status: {
      created:     1,     #订单 创建
      canceled:    10,    #订单 取消
      accepted:    50,    #订单 接受
      shipping:    100,   #订单 发货
      warehousing: 200,   #订单 收货
      complete:    300    #订单 完成
    }

    aasm :column => :status, :enum => true do
      state :created, :initial => true
      state :canceled
      state :accepted
      state :shipping
      state :warehousing
      state :complete

      event :accept do
        transitions from: :created, to: :accepted
      end

      event :cancel do
        transitions from: [:created, :accepted], to: :canceled
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
