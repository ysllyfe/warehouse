module WarehouseAble
  extend ActiveSupport::Concern
  included do
    # has_one :warehouse, as: :warehouseable, class_name: 'Warehouse::Category'
    after_create :create_warehouse
  end
  module ClassMethods
    attr_reader :warehouse_opts
    # 初始化model warehouse数据
    def warehouse_init
      all.each do |t|
        t.warehouse || t.warehouse = ::Warehouse::Category.new
      end
    end
    private
    def acts_as_warehouse(options={})
      conf = {
        :prefix => '',
        :goods_class_name => nil,
        :name => 'name'
      }
      conf.update(options)
      if conf[:goods_class_name].nil?
        raise ActiveRecord::ActiveRecordError, "acts_as_warehouse must be provided with :goods_class_name option with class name like Product"
      end
      unless conf[:prefix] == ''
        conf[:prefix] += '_'
      end
      @warehouse_opts = conf
    end
  end

  def warehouse
    ::Warehouse::Category.where("? = ANY (warehouseable_ids) and warehouseable_type = ?", self.id, self.class).first
  end

  def warehouse=(warehouse_category)
    raise 'Error! 合并仓库要同类型!' if warehouse_category.warehouseable_type && warehouse_category.warehouseable_type != self.class
    warehouse_category.warehouseable_ids << self.id
    warehouse_category.warehouseable_type = self.class
    warehouse_category.name = "#{warehouse_category.name}#{self.try(get_warehouse_opts[:name])}"
    warehouse_category.save
  end

  # 仓库商品库存计算
  def goods_stocks
    exists_stocks = warehouse.stocks.inject({}) do |mem, item|
      if mem[item.goods_id]
        mem[item.goods_id] += item.amount
      else
        mem[item.goods_id] = item.amount
      end
      mem
    end
    if get_warehouse_opts[:goods_class_name].kind_of? Class
      goods_list = get_warehouse_opts[:goods_class_name].all
    elsif get_warehouse_opts[:goods_class_name].kind_of? String
      goods_list = get_warehouse_opts[:goods_class_name].classify.constantize.all
    else
      raise 'Argument Error, :goods_class_name must be Class or String'
    end
    warehouse_stocks = []
    goods_list.each do |good|
      warehouse_stocks << goods_stock_item(good, exists_stocks)
    end
    warehouse_stocks
  end


  #取acts_as_warehouse带过来的options
  def get_warehouse_opts
    if self.class.warehouse_opts.blank? && self.class.superclass.try(:warehouse_opts).present?
      opts = self.class.superclass.warehouse_opts
    elsif self.class.warehouse_opts.present? && self.class.superclass.try(:warehouse_opts).present?
      opts = self.class.superclass.warehouse_opts.merge(self.class.warehouse_opts)
    else
      opts = self.class.warehouse_opts
    end
    opts || {}
  end

  private
  def goods_stock_item(good, exists_stocks)
    {
      id: good.id,
      class: good.class.to_s,
      name: good.name,
      guidance_price: good.guidance_price,
      cost_price: good.cost_price,
      brand_id: good.brand_id,
      product_category_id: good.product_category_id,
      amount: exists_stocks[good.id] ? exists_stocks[good.id] : 0
    }
  end

  def create_warehouse
    self.warehouse = ::Warehouse::Category.new
  end
end