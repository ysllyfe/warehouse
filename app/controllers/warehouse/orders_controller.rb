module Warehouse
  class OrdersController < WarehouseController
    before_action :get_warehouse
    def index
      @goods_stocks = @warehouse.children.first.goods_stocks
    end

    def new
      @step = params[:step] || '1'
      case @step
      when '1'
        @warehouses = @warehouse.can_purchase_warehouses_collection
      when '2'
        @sale_warehouse = @warehouse.can_purchase_warehouses.find(params[:sale_warehouse_id])
        @goods_stocks = @warehouse.goods_stocks
        @sale_goods_stocks = @sale_warehouse.goods_stocks
        Category.merge_warehouse_stocks(@sale_goods_stocks,@goods_stocks)
      else
        raise 'Step Error!'
      end
    end

    def create
      @warehouse = Category.find(params[:warehouse_id])
      @sale_warehouse = Category.find(params[:sale_warehouse])
      order_items = []
      params[:purchase].each do |(key,value)|
        next if value.to_i == 0
        order_items << OrderItem.new({warehouse_id:@warehouse.id,goods_id:key, quantity:value, unit_price:params[:price][key]})
      end
      order = Order.new(sale_warehouse: @sale_warehouse.id,purchase_warehouse:@warehouse.id)
      order.order_items << order_items
      if order.save
        redirect_to warehouse.warehouse_path(@warehouse.id), :notice=>'生成采购订单成功！'
      else
        raise 'System Error!'
      end
    end

    def show
      @order = Order.find(params[:id])

      unless @order.purchase_warehouse == @warehouse.id || @order.sale_warehouse == @warehouse.id
        render :text => 'Order is not belongs to you!'
      end

      @goods = @order.order_items
      @product = @warehouse.opts[:goods_class_name].classify.constantize
      @memo = OrderMemo.new
      @memos = @order.order_memos.order('id desc')
    end

    def memo!
      @order = Order.find(params[:id])
      memo = OrderMemo.new(params.require(:order_memo).permit(:memo))
      memo.warehouse_id = params[:warehouse_id]
      if @order.order_memos << memo
        redirect_to warehouse.warehouse_order_path(@warehouse.id, @order.id)
      else
        flash[:error] = @order.errors.full_messages
        redirect_to warehouse.warehouse_order_path(@warehouse.id, @order.id)
      end
    end

    private
    def get_warehouse
      @warehouse = Category.find(params[:warehouse_id])
    end
  end
end
