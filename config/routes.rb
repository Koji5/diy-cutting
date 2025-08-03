Rails.application.routes.draw do

  # Devise
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # ヘルスチェック用ルート(自動生成)
  get "up" => "rails/health#show", as: :rails_health_check

  # API
  namespace :api, defaults: { format: :json } do
    get "prefectures/:code/cities",     to: "postals#cities"
    get "postal_lookup/:zip",           to: "postals#lookup"
    get "copy_address",                 to: "postals#copy_address"
    get "bank_branches/bank_search",            to: "bank_branches#search_bank"
    get "bank_branches/bank/:code",             to: "bank_branches#show_bank"
    get "bank_branches/:code/branch_search",    to: "bank_branches#search_branch"
    get "bank_branches/:code/branch_list", to: "bank_branches#branch_list"
  end

  # トップページ（ルート）の制御
  authenticated :user do
    root to: "articles#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "welcome#index", as: :unauthenticated_root
  end
  resources :articles, only: [:index]

  # 各画面
  resources :accounts, only: [:show, :edit, :update] do
    post :toggle_role, on: :collection
  end
  resources :parts do
    member do
      get :inline_detail
      get :show_modal
    end
  end
  resources :recipes do
    member do
      get :show_modal
    end
  end
  resources :carts do
    member do
      get :check_and_add
    end
  end
  resources :rfqs, only: [:new, :create, :show]
  resource :member_profile, only: [:new, :create, :edit, :update]
  resource :vendor_profile, only: [:new, :create, :edit, :update]
  resources :addresses, only: [:index, :create, :update, :destroy] do
    collection do
      get :new_modal
    end
    member do
      get :edit_modal
    end
  end
  resource :service_area, only: [:show, :edit, :update] do
    member do
      patch :confirm
    end
  end
end
