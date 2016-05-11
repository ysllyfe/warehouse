module Warehouse
  module ApplicationHelper
    def order_operation_panel(order, warehouse_id)
      return nil unless order.editable_by?(warehouse_id)
      operation = []
      order.operation_status.each do |t|
        operation << "<li><a href='?status=#{t[0]}' rel='nofollow' data-method='put'>#{t[0]}</a></li>"
      end

      html = <<-DOC.html_safe
      <div class="btn-group" role="group" aria-label="...">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          #{order.status}
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
