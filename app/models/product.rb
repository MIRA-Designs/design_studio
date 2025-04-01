class Product < ApplicationRecord
  has_rich_text :description

  has_many_attached :images do |attachable|
    attachable.variant :normal, resize_to_limit: [ 540, 720 ]
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end
end
