# lib/tasks/seed_fake_users.rake

namespace :db do
  desc "Seed 10,000 fake users into the users table"
  task seed_fake_users: :environment do
    require "faker"
    require "pg"

    conn = PG.connect(dbname: "test_db")
    # delete existing users to load fake users
    conn.exec_params("DELETE FROM users")

    puts "Seeding 10,000 fake users ...."
    (1..10_000).each do |i|
      conn.exec_params(
        "INSERT INTO users (user_id, username, email, phone_number) VALUES ($1, $2, $3, $4)",
        [ i, Faker::Internet.username, Faker::Internet.email, Faker::PhoneNumber.phone_number ]
      )
    end
    puts "Seeded 10,000 fake users into the users table"
    conn.close
  end
end
