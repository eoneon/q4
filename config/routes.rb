Rails.application.routes.draw do
  resources :product_items
  root to: 'product_items#index'
end
