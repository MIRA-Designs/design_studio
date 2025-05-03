class Product < ApplicationRecord
  CATEGORIES = %w[women men kids infants]

  has_many :variants, dependent: :destroy, class_name: "ProductVariant"
  has_rich_text :description

  has_many_attached :images do |attachable|
    attachable.variant :normal, resize_to_limit: [ 540, 720 ]
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end

  validates :name, :description, :brand, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :rating,
  numericality: {
    greater_than_or_equal_to: 1.0,
    less_than_or_equal_to: 5.0,
    allow_nil: true,
    message: "must be between 1.0 and 5.0"
  }

  scope :with_spec, ->(key, value) {
    where("specs @> ?", { key => value }.to_json)
  }

  scope :for_category, ->(cat) { where(category: cat) }

  def primary_variant
    # Assuming the first variant is the primary one
    variants.first
  end

  # Custom method to process and reattach images (new and existing)
  def process_images(image_params)
    # Reject params that are not valid integers (i.e., convert to 0), and map to valid IDs
    existing_image_ids = image_params.reject { |param| param.to_s.to_i == 0 }.map { |param| param.to_i }

    # Filter out any uploaded images (ActionDispatch::Http::UploadedFile objects)
    new_images = image_params.select { |param| param.is_a?(ActionDispatch::Http::UploadedFile) }

    # Reattach existing image IDs as image blobs
    existing_image_ids.each do |image_id|
      images.attach(ActiveStorage::Blob.find(image_id)) # Attach only valid IDs
    end

    # Attach new uploaded images
    images.attach(new_images) unless new_images.empty?
  end
end
