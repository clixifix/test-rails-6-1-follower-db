Rails.application.routes.draw do
  get 'articles/update_all', to: 'articles#update_all'

  resources :articles do
    get 'update_one', to: 'articles#update_one'
  end
  root to: 'articles#index'
end
