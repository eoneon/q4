Rails.application.routes.draw do
  #get 'search_items/search'

  resources :suppliers do
    resources :invoices
  end

  resources :invoices do
    resources :items, except: [:index]
    resources :export_skus, only: [:create]
    resources :skus, only: [:create] do
      member do
        post :batch_destroy
      end
    end
    # resources :search_items, only: [:search]
    resources :search_items, only: [:search] do
      collection do
        get :search
      end
    end
    member do
      get :search
    end
  end

  resources :items, only: [:search] do
    collection do
      get :search
    end
  end

  resources :products
  resources :field_items
  resources :artists do
    collection do
      get :search
    end
  end
  resources :product_search, only: [:index, :show]
  resources :product_items


  resources :item_groups do
    member do
      post :sort_up, :sort_down
    end
  end

  root to: 'product_items#index'
end
