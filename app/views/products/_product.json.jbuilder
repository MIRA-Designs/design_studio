json.extract! product, :id, :brand, :name, :description, :category, :rating, :created_at, :updated_at
json.url product_url(product, format: :json)

# Include image URLs
json.images product.images.map { |image| url_for(image) }

if product.variants.any?
  variant = product.primary_variant

  json.variant do
    json.extract! variant, :id, :sku, :mrp, :price, :discount_percent, :size, :color, :stock_quantity, :specs, :created_at, :updated_at
  end
end
