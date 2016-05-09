# == Schema Information
#
# Table name: warehouse_order_logs
#
#  id                 :integer          not null, primary key
#  warehouse_order_id :integer
#  log_type           :integer
#  info               :text
#  created_at         :datetime
#  updated_at         :datetime
#

module Warehouse
  class OrderLog < Base
    belongs_to :order
  end
end
