json.extract! product, :id, :title, :description, :category, :color, :size, :mrp, :discount, :rating, :created_at, :updated_at
json.url product_url(product, format: :json)
