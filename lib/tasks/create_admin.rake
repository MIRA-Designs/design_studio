# This task creates or updates the first admin user.
# It uses the `ADMIN_EMAIL` and `ADMIN_PASSWORD` environment variables to set the email and password.
# If the user already exists, it updates the password and role.
# If the user does not exist, it creates a new user with the provided email and password.
# Run it with:
#  ADMIN_EMAIL=foo@bar.com ADMIN_PASSWORD=topsecret rails admin:create
namespace :admin do
  desc "Create or update the first admin user"
  task create: :environment do
    email    = ENV.fetch("ADMIN_EMAIL")    { abort "Set ADMIN_EMAIL" }
    password = ENV.fetch("ADMIN_PASSWORD") { abort "Set ADMIN_PASSWORD" }

    user = User.find_or_initialize_by(email: email)
    user.password              = password
    user.password_confirmation = password
    user.role                   = "admin"
    user.save!

    puts "✅ Admin user #{email} created/updated"
  end
end
