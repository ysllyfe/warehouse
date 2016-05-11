# Warehouse

### Usage
**add gem to your Gemfile**

```ruby
gem 'warehouse', :github => 'ysllyfe/warehouse'
```

In the model that you want to treat as a warehouse

```ruby
Class YOUR_MODEL < ActiveRecord::Base
    ...
    include WarehouseAble
    acts_as_warehouse :goods_class_name=>Product, :name=>'name', :type=>'chinese name of the model', :goods_name=>'name'

end
```
其中
goods_class_name表示原系统中的商品表名
name表示对应YOUR_MODEL表示名称的字段
goods_name表示商品表中商品名称的字段

The WarehouseAble will automatic create the warehouse record.
Initialize the exist records. And create the superset Category.

```ruby
YOUR_MODEL.warehouse_init
```

Change routes.rb to mount the engine

```ruby
mount Warehouse::Engine => '/'
```

warehouse 构成一个闭环，所有向外部采购的商品，认为全部来自于superset，所有销售出去的商品，认为销售给superset。

**重要：手动修改商品库存时，请使用add_stocks方法，系统自动生成订单，并修改订单状态至完成。对应会有superset的库存和对应category的库存变化**

### How to Develop

`git clone https://github.com/ysllyfe/warehouse.git LOCAL_PATH`

**add gem local to your Gemfile**

```bash
gem 'quiet_assets', group: :development
gem 'require_reloader', group: :development
gem 'warehouse', :path => LOCAL_PATH
```
To reload all local gems (the ones with :path attribute, or using local git repo):

**config/environments/development.rb**

```ruby
YourApp::Application.configure do
  ...
  RequireReloader.watch_local_gems!
end
```


