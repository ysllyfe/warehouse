module WarehouseAble
  extend ActiveSupport::Concern
  included do
    after_create :create_warehouse
  end
  module ClassMethods
    attr_reader :warehouse_opts
    # 初始化model warehouse数据
    def warehouse_init
      all.each do |t|
        t.warehouse || t.warehouse = ::Warehouse::Category.new
      end
      # superset
      ::Warehouse::Category.find_or_create_by(superset:true) do |t|
        t.goods_class_name = @warehouse_opts[:goods_class_name]
        t.m_name = @warehouse_opts[:name]
        t.goods_name = @warehouse_opts[:goods_name]
        t.superset = true
        t.name = 'superset'
      end
    end
    private
    def acts_as_warehouse(options={})
      conf = {
        :prefix => '',
        :goods_class_name => nil,
        :name => 'name',        # name 表示 acts_as_warehouse 对象表示名称的字段
        :goods_name => 'name'   # goods_name 表示 product 的 name 字段/方法
      }
      conf.update(options)
      if conf[:goods_class_name].nil? || conf[:name].nil? || conf[:goods_name].nil?
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

  # 仓库商品库存计算，仓库库存计算放到model/category中
  def goods_stocks
    warehouse.goods_stocks
  end

  # 手动改库存，一定会自动建一条订单，不允许直接对stocks表进行操作
  def add_stocks(goods_id, amount, unit_price)
    warehouse.add_stocks(goods_id, amount, unit_price)
  end

  #取acts_as_warehouse带过来的options，有可能是多重继承，这里只取两重
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
  def create_warehouse
    self.warehouse = ::Warehouse::Category.new
  end
end