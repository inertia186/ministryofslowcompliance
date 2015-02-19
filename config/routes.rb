Ministryofslowcompliance::Application.routes.draw do
  root :to => "contents#index"
  get "/welcome" => "contents#welcome"
  get "/about" => "contents#about"
  get "/search_by_author/:author_id" => "contents#index", as: :search_by_author
  get "/search_by_former_members" => "contents#search_by_former_members", as: :search_by_former_members
  devise_for :users,
    :controllers => {
      :registrations => "users/registrations",
      :passwords => "users/passwords"
    }
  devise_scope :user do
    get "/user/sign_out" => "devise/sessions#destroy"
  end
  resources :posts do
    collection do
      get :search
    end
    resources :comments
  end
  resources :post do
    resources :comments
  end
  resources :comments do
    resources :comments
  end
end
