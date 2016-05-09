require "warehouse/engine"

module Warehouse
  require "warehouse/warehouse"
  mattr_accessor :parent_controller
  @@parent_controller = "ApplicationController"
end
