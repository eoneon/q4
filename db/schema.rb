# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200424004340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "field_items", force: :cascade do |t|
    t.string "type"
    t.string "field_name"
    t.hstore "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_groups", force: :cascade do |t|
    t.string "origin_type"
    t.bigint "origin_id"
    t.string "target_type"
    t.bigint "target_id"
    t.hstore "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort"
    t.index ["origin_type", "origin_id"], name: "index_item_groups_on_origin_type_and_origin_id"
    t.index ["target_type", "target_id"], name: "index_item_groups_on_target_type_and_target_id"
  end

  create_table "product_items", force: :cascade do |t|
    t.string "type"
    t.string "item_name"
    t.hstore "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
