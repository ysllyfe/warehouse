module Warehouse
  class Base < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = 'warehouse_'
  end
end