# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if Rails.env.development?
  Dir[Rails.root.join("db/seeds/local/*.rb")].sort.each { |f| load f }

  # ───────────────────────────────
  # 開発環境専用：管理者ユーザーを 1 件だけ用意
  # ───────────────────────────────
  admin_email    = "admin@example.dev"
  admin_password = "123456"

  admin = User.find_or_create_by!(email: admin_email) do |u|
    u.password              = admin_password
    u.password_confirmation = admin_password
    u.role                  = :admin                 # enum { member:0, vendor:1, admin:2, affiliate:3 }
    u.public_uid            ||= SecureRandom.urlsafe_base64(24)
  end

  # AdminDetail がまだ無ければ作成
  if admin.admin_detail.nil?
    admin.build_admin_detail(
      nickname:   "DevMaster",
      icon_url:   nil,
      department: "Development"
    )
    admin.save!
  end

  puts <<~MSG
    [seed] 開発用管理者ユーザーを作成／更新しました
           email:    #{admin_email}
           password: #{admin_password}
  MSG
end
