# Warehouse


### How to Development

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

In the model that you want to treat as a warehouse

```ruby
Class YOUR_MODEL < ActiveRecord::Base
    ...
    include WarehouseAble
    acts_as_warehouse :goods_class_name=>Product, :name=>'name', :type=>'chinese name of the model'
    
end
```
The WarehouseAble will automatic create the warehouse record.
Initialize the exist records.

```ruby
YOUR_MODEL.warehouse_init
```

Change routes.rb to mount the engine

```ruby
mount Warehouse::Engine => '/'
```

