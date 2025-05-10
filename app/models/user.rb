class User < ApplicationRecord
  has_secure_password
  enum :role, {
    customer:  "customer",
    admin:     "admin"
  }
  has_many :sessions, dependent: :destroy
  has_many :orders

  normalizes :email, with: ->(e) { e.strip.downcase }
end
