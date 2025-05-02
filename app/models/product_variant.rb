# app/models/product_variant.rb
class ProductVariant < ApplicationRecord
  store_accessor :specs, :material, :fit, :sleeve, :pattern

  belongs_to :product

  before_save :price_from_discount

  validates :mrp, presence: true, numericality: { greater_than: 0 }
  validates :discount_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :size, :color, presence: true

  def discount_amount
    mrp - price
  end

  private

  def price_from_discount
    if mrp_changed? || discount_percent_changed?
      self.price = (mrp * (100 - discount_percent) / 100).round(2)
    end
  end
end
