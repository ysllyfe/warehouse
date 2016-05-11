module Warehouse
  class GoodsController < WarehouseController
    before_action :get_warehouse

    def index
      @goods = @warehouse.goods
    end

    def create
      # 改价格
      costs = params[:costs]
      prices = params[:prices]
      costs.each do |key,val|
        good = Good.find_by(id:key)
        good.update(cost:val,price:prices[key])
      end
      redirect_to warehouse.warehouse_goods_path
    end

    private
    def get_warehouse
      @warehouse = Category.find(params[:warehouse_id])
    end
  end
end