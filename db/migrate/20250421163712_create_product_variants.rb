class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string  :sku, null: false # e.g MPOLO-BLACK-M
      t.decimal :mrp, precision: 10, scale: 2, null: false    # e.g., ₹1999.00
      t.decimal :price, precision: 10, scale: 2, null: false  # e.g., ₹1299.00
      t.decimal :discount_percent, precision: 5, scale: 2     # optional: e.g., 35.00 (%)
      t.string  :size
      t.string  :color
      t.integer :stock_quantity, default: 0
      t.jsonb   :specs, default: {}, null: false # e.g { fit: "regular", sleeve: "short", pattern: "solid" }

      t.timestamps
    end

    # GIN index for fast JSONB attribute searching
    add_index :product_variants, :specs, using: :gin
    add_index :product_variants, [ :product_id, :size, :color ], unique: true
    add_index :product_variants, :sku, unique: true
  end
end
