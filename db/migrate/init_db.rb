class InitDb < ActiveRecord::Migration
  def change
    create_table "warehouse_categories", force: :cascade do |t|
      t.string   "name"
      t.integer  "warehouseable_ids",  default: [], array: true
      t.string   "warehouseable_type"
      t.boolean  "superset",           default: false
      t.string   "goods_class_name"
      t.string   "goods_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "warehouse_categories", :superset
    add_index "warehouse_categories", ["warehouseable_ids", "warehouseable_type"], name: "warehouse_categories_warehouseable", using: :btree

    create_table "warehouse_order_items", force: :cascade do |t|
      t.integer  "warehouse_order_id"
      t.integer  "warehouse_id"
      t.integer  "goods_id",           default: 0
      t.decimal  "unit_price",         default: 0.0
      t.integer  "quantity",           default: 0
      t.decimal  "price"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "warehouse_order_logs", force: :cascade do |t|
      t.integer  "warehouse_order_id"
      t.integer  "log_type"
      t.text     "info"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "warehouse_order_memos", force: :cascade do |t|
      t.integer  "warehouse_id"
      t.integer  "warehouse_order_id"
      t.text     "memo"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "warehouse_orders", force: :cascade do |t|
      t.integer  "purchase_warehouse"
      t.integer  "sale_warehouse"
      t.decimal  "price"
      t.integer  "status",             default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "warehouse_orders", ["purchase_warehouse"], name: "index_warehouse_orders_on_purchase_warehouse", using: :btree
    add_index "warehouse_orders", ["sale_warehouse"], name: "index_warehouse_orders_on_sale_warehouse", using: :btree

    create_table "warehouse_stocks", force: :cascade do |t|
      t.integer "warehouse_id"
      t.integer "goods_id",            default: 0
      t.integer "warehouse_order_id"
      t.integer "amount",              default: 0
    end
  end
end
