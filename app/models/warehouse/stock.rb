# == Schema Information
#
# Table name: warehouse_stocks
#
#  id           :integer          not null, primary key
#  warehouse_id :integer
#  goods_id     :integer          default(0)
#  amount       :integer          default(0)
#

module Warehouse
  class Stock < Base
    belongs_to :category
  end
end
