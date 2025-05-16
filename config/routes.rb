Rails.application.routes.draw do
  get "articles/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get  "prefectures/:code/cities", to: "postals#cities"      # 都道府県→市区町村
  get  "postal_lookup/:zip",       to: "postals#lookup"      # 郵便番号→候補一覧

  root "articles#index"            # トップページを articles#index に
  resources :articles, only: [:index]

  # ① Member (標準)  ─ /users/...
  devise_for :users, controllers: {
    registrations: "members/registrations"
  }, path: "", path_names: { sign_up: "sign_up", sign_in: "sign_in" }

  # ② Vendor 専用     ─ /vendors/...
  devise_for :vendors, class_name: "User", controllers: {
    registrations: "vendors/registrations"
  }, path: "vendors", path_names: { sign_up: "sign_up", sign_in: "sign_in" }
end
