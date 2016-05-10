module Warehouse
  class WarehousesController < WarehouseController
    def index
      @warehouses = Category.common_category.order('id desc')
    end

    def merge
      @warehouse = Category.find(params[:id])
      @warehouses = @warehouse.can_merge_warehouses
    end

    def merge!
      Category.merge_warehouse(params[:merge_warehouses])
      redirect_to warehouse.warehouses_path, :notice=>'合并仓库成功！'
    end

    def edit
      @warehouse = Category.find(params[:id])
    end

    def update
      @warehouse = Category.find(params[:id])
      if @warehouse.update(params.require(:category).permit(:name))
        redirect_to warehouse.warehouses_path, notice: '修改分类名称成功！'
      else
        flash[:error] = @warehouse.errors.full_messages
        render 'edit'
      end
    end

    def show
      @warehouse = Category.find(params[:id])
      @orders = @warehouse.purchase_orders
    end
  end
end
