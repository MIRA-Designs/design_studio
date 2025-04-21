class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.string :color
      t.string :size, limit: 10
      t.decimal :mrp, precision: 7, scale: 2
      t.decimal :discount, precision: 7, scale: 2
      t.decimal :rating, precision: 2, scale: 1

      t.timestamps
    end
  end
end
