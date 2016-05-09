# == Schema Information
#
# Table name: warehouse_order_items
#
#  id                 :integer          not null, primary key
#  warehouse_order_id :integer
#  warehouse_id       :integer
#  goods_id           :integer          default(0)
#  unit_price         :decimal(, )      default(0.0)
#  quantity           :integer          default(0)
#  price              :decimal(, )
#  created_at         :datetime
#  updated_at         :datetime
#

module Warehouse
  class OrderItem < Base
    belongs_to :order
    belongs_to :category
    before_save :calculate_price
    def live_price
      unit_price * quantity
    end
    private
    def calculate_price
      self.price = live_price
    end
  end
end
