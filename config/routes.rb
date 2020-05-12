Rails.application.routes.draw do
  resources :products
  resources :product_items
  resources :field_items
  
  resources :item_groups do
    member do
      post :sort_up, :sort_down
    end
  end

  root to: 'product_items#index'
end
