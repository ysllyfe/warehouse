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
    belongs_to :order
    # 对应库存的增减，不能直接记录数据，要从order触发
  end
end
