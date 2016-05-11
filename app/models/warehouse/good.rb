module Warehouse
  class Good < Base
    def self.touch_goods(opts={})
      conf = {
        :warehouse_id => nil,
        :goods_id => nil,
        :cost => nil
      }
      conf.update(opts)
      return nil if conf[:warehouse_id].nil? || conf[:goods_id].nil? || conf[:cost].nil?
      self.find_or_create_by(warehouse_id:conf[:warehouse_id],goods_id:conf[:goods_id]) do |t|
        t.cost = conf[:cost]
        t.price = conf[:cost]
      end
    end
    def warehouse_price
      price
    end
    def warehouse_cost
      cost
    end
  end
end