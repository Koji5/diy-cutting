Rails.application.routes.draw do
  get "articles/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get  "prefectures/:code/cities", to: "postals#cities"      # 都道府県→市区町村
  get  "postal_lookup/:zip",       to: "postals#lookup"      # 郵便番号→候補一覧
  get "vendors/flash_toast", to: "vendors/coverage_settings#flash_toast"

  root "articles#index"            # トップページを articles#index に
  resources :articles, only: [:index]

  # 共通ログイン・パスワード・会員（member）登録
  devise_for :users,
            path: "",                                   # → /login /logout /sign_up
            path_names: { sign_in: "login",
                          sign_out: "logout",
                          sign_up:  "sign_up" },
            controllers: { registrations: "members/registrations" }

  # ─────────────────────────────────────────────
  # ロール専用の登録フォームだけを追加する
  # （ログイン／パスワード関連はすべて共通の :user スコープを使う）
  devise_scope :user do
    ## Vendor
    get  "vendor/sign_up", to: "vendors/registrations#new",
                          as: :new_vendor_registration
    post "vendor",         to: "vendors/registrations#create",
                          as: :vendor_registration

    ## Affiliate
    get  "affiliate/sign_up", to: "affiliates/registrations#new",
                              as: :new_affiliate_registration
    post "affiliate",         to: "affiliates/registrations#create",
                              as: :affiliate_registration
  end

  namespace :vendors do
    resource  :coverage_settings, only: %i[show update]  # 画面１枚
    post "coverage_settings/cities_bulk", to: "coverage_settings#cities_bulk"
    post "coverage_settings/prefs_bulk",  to: "coverage_settings#prefs_bulk"
    post "coverage_settings/nationwide_bulk",  to: "coverage_settings#nationwide_bulk"
    get  "coverage_settings/cities/:pref_code", to: "coverage_settings#cities_json", as: :coverage_cities_json
  end
end
