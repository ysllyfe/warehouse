module Warehouse
  class StocksController < WarehouseController
    before_action :get_warehouse
    def index
      @goods_stocks = @warehouse.goods_stocks
    end

    def create
      @warehouse.add_stocks(params[:goods_id],params[:amount],params[:price])
      render :text=>'success'
    end

    private
    def get_warehouse
      @warehouse = Category.find(params[:warehouse_id])
    end
  end
end
