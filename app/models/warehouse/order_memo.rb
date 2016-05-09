# == Schema Information
#
# Table name: warehouse_order_memos
#
#  id                 :integer          not null, primary key
#  warehouse_id       :integer
#  warehouse_order_id :integer
#  memo               :text
#  created_at         :datetime
#  updated_at         :datetime
#

module Warehouse
  class OrderMemo < Base
    belongs_to :order
    def user_name
      warehouse_id ? Category.find(warehouse_id).full_name : '未知'
    end
  end
end
