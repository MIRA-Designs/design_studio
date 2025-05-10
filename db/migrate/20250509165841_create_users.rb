class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string   :email,           null: false, index: { unique: true }
      t.string   :password_digest, null: false
      t.string   :role,            null: false, default: "customer"
      t.string   :first_name
      t.string   :last_name
      t.jsonb    :metadata,        null: false, default: {}
      t.timestamps
    end

    # You can later set up an enum in the User model:
    # enum role: { customer: "customer", admin: "admin" }
  end
end
