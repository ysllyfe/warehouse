# All Warehouse controllers are inherited from here.
class WarehouseController < Warehouse.parent_controller.constantize
  helper Warehouse::ApplicationHelper
end