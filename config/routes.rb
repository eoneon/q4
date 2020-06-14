Rails.application.routes.draw do
  resources :suppliers do
    resources :invoices
  end

  resources :invoices do
    resources :items, except: [:index]
    resources :skus, only: [:create] do
      member do
        post :destroy
      end
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
