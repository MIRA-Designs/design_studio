class AddBrandToProducts < ActiveRecord::Migration[8.0]
  def change
    # Add 'brand' column
    add_column :products, :brand, :string

    # Add index for brand
    add_index :products, :brand
  end
end
