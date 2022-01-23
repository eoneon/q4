Rails.application.routes.draw do
  #get 'search_items/search'

  resources :suppliers do
    resources :invoices
  end

  resources :invoices do
    resources :items, except: [:index]
    resources :export_skus, only: [:create]
    resources :titles, only: [:new]
    resources :table_skus, only: [:show]
    resources :skus, only: [:show, :create, :update] do
      collection do
        post :batch_destroy
      end
      collection do
        get :search
      end
    end

    resources :search_items, only: [:search, :index, :new, :create] do
      collection do
        get :search
      end
    end
    member do
      get :search
    end

    resources :batch_items, only: [:search, :index, :create] do
      collection do
        get :search
      end
    end
  end

  resources :item_products do
    collection do
      get :search
    end
  end

  resources :artist_items, only: [:search] do
    collection do
      get :search
    end
  end

  resources :item_fields
  resources :products

  resources :artists do
    collection do
      get :search
    end
  end

  # resources :product_search, only: [:index, :show]
  # resources :product_items
  #
  # resources :item_groups do
  #   member do
  #     post :sort_up, :sort_down
  #   end
  # end

  root to: 'product_items#index'
end

# resources :items, only: [:search] do
#   collection do
#     get :search
#   end
# end
