# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:index]
  root to: 'users#index'
end
