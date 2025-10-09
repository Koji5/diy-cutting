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
    get "prefectures/:code/cities", to: "postals#cities"
    get "postal_lookup/:zip", to: "postals#lookup"
    get "copy_address", to: "postals#copy_address"
    get "bank_branches/bank_search", to: "bank_branches#search_bank"
    get "bank_branches/bank/:code", to: "bank_branches#show_bank"
    get "bank_branches/:code/branch_search", to: "bank_branches#search_branch"
    get "bank_branches/:code/branch_list", to: "bank_branches#branch_list"
    post "service_area_summary", to: "service_area_summaries#create"
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
    resource :board_part,  only: [:show, :edit, :update]
    resource :lumber_part, only: [:show, :edit, :update]
  end
  resources :board_parts,  only: [:new, :create]
  resources :lumber_parts, only: [:new, :create]
  # 使うヘルパ
  # edit    edit_part_board_part_path(@part)  => GET /parts/:part_id/board_part/edit
  # update  part_board_part_path(@part)       => PATCH /parts/:part_id/board_part
  # new     new_board_part_path               => GET /board_parts/new
  # create  board_parts_path                  => POST /board_parts
  # show    part_board_part_path(@part)       => GET /parts/:part_id/board_part
  # destroy part_path(part)                   => DELETE /parts/:id
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
  resources :drawing_tests, only: [:new] do
    post :generate_all, on: :collection   # ← 3種まとめて生成（保存だけ）
    get  :download,    on: :collection    # ← 個別ダウンロード（pdf / dxf_dim / dxf_cam）
    post :preview_images, on: :collection # プレビュープロキシ
  end
end
