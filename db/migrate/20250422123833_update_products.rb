class UpdateProducts < ActiveRecord::Migration[8.0]
  def change
    remove_columns :products, :title, :color, :size, :mrp, :discount, :rating

    add_column :products, :name, :string, null: false
    add_column :products, :rating, :decimal, precision: 2, scale: 1, default: 0.0

    add_index :products, :category
  end
end
