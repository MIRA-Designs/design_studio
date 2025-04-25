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
end
