module Warehouse
  class Engine < ::Rails::Engine
    # require 'warehouse/concerns/warehouse'
    #
    # initializer 'warehouse.include_concerns' do
    #   ActionDispatch::Reloader.to_prepare do
    #     ActiveRecord::Base.send(:include, WarehouseAble)
    #   end
    # end
    #
    # # Autoload from lib directory
    # config.autoload_paths << File.expand_path('../../', __FILE__)

    isolate_namespace Warehouse
  end
end
