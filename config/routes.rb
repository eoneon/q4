Rails.application.routes.draw do

  # resources :product_items do
  #   resources :product_targets
  #   resources :field_targets
  # end
  resources :product_items
  resources :item_groups

  root to: 'product_items#index'
end
