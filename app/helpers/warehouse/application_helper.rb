module Warehouse
  module ApplicationHelper
    def order_operation_panel(order, warehouse_id)
      return nil unless order.editable_by?(warehouse_id)
      operation = []
      order.operation_status.each do |t|
        operation << "<li><a href='#{t[1]}'>#{t[0]}</a></li>"
      end

      html = <<-DOC.html_safe
      <div class="btn-group" role="group" aria-label="...">
        <button type="button" class="btn btn-default">1</button>
        <button type="button" class="btn btn-default">2</button>

        <div class="btn-group" role="group">
          <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Dropdown
            <span class="caret"></span>
          </button>
          <ul class="dropdown-menu">
          #{operation.join('')}
          </ul>
        </div>
      </div>
      DOC
    end
  end
end
