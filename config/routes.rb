# frozen_string_literal: true

Rails.application.routes.draw do

  get '/api/swagger', to: 'application#swagger', as: :swagger

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount PgHero::Engine, at: 'pghero'
  mount API => '/'

  resources :tags do
    collection do
      get 'download', to: "tags#download_form"
      post 'import', to: "tags#import"
    end
  end
  resources :question_states
  resources :messages
  resources :settings
  resources :enrollments do
    collection do
      get 'download', to: "enrollments#download_form"
      post 'import', to: "enrollments#import"
    end
  end
  resources :roles
  resources :questions, param: :question_id do
    member do
      get 'paginatedPreviousQuestions', to: 'questions#paginated_previous_questions'
      get 'previousQuestions', to: 'questions#previous_questions'
      post 'acknowledge', to: 'questions#acknowledge'
      post 'update_state', to: 'questions#update_state'
    end

    collection do
      get 'download', to: "questions#download_form"
    end
  end
  resources :courses, param: :course_id

  resources :questions, shallow: true do
    resources :messages
    resources :question_states
  end

  resources :users, only: [], shallow: true do
    resources :questions
    resources :enrollments
    resources :tags
    resource :settings do
      get 'notifications', to: "settings#notifications"
    end
  end
  resources :users, param: :user_id
  resource :user, shallow: true, only: [], as: :current_user do
    resources :enrollments, controller: 'users/enrollments'
  end

  resources :courses, only: [] do
    resources :questions, param: :question_id do
      collection do
        get 'count', to: 'questions#count'
        get 'download', to: "questions#download_form"
      end
    end
    resources :tags do
      collection do
        get 'download', to: "tags#download_form"
      end
    end
    resources :users, param: :user_id
    resources :question_states
    resources :messages
    resources :enrollments do
      collection do
        get 'download', to: "enrollments#download_form"
      end
    end
    resources :roles
  end

  use_doorkeeper do
    controllers applications: "oauth/applications"
  end

  resources :courses, only: [] do
    use_doorkeeper do
      controllers applications: "oauth/applications"
    end
  end

  resources :courses, only: [] do
    scope 'oauth' do
      resources :applications
    end
  end

  resources :courses, param: :course_id do
    collection do

      post 'semester'
    end
    member do
      get 'roster', to: 'courses#roster'
      get 'queue', to: 'courses#queue'
      get 'settings/queues', to: 'courses#queues'
      get 'activeTAs', to: 'courses#active_tas'
      get 'analytics', to: 'courses/analytics#index'
      get 'analytics/today', to: 'courses/analytics#today'
      get 'analytics/tas', to: 'courses/analytics#tas'
      get 'settings/course', to: 'courses/settings#index'
      post 'answer', to: 'courses#answer'
      get 'answer', to: 'courses#answer_page'
      get 'answer/question', to: 'courses#answer_page', as: :answer_question
      get 'answer/previousQuestions', to: 'courses#answer_page'
      post 'putBack', to: 'courses#putBack'
      post 'finishAnswering', to: 'courses#finishAnswering'
      post 'freeze', to: 'courses#freeze'
      post 'kick', to: 'courses#kick'
      get 'topQuestion', to: 'courses#top_question'
      get 'open', to: 'courses#open_status'
      post 'open', to: 'courses#open'
    end
  end

  get 'landing/', to: 'landing#index'

  get '/users/auth/google_oauth2/callback', to: 'oauth_accounts#create_or_update', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }
  get '/users/auth/failure', to: 'oauth_accounts#error', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }

  root to: 'landing#index'

  devise_scope :user do
    get 'auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
    get 'auth/failure', to: 'users/omniauth_callbacks#failure'
    get 'sign_in', to: 'landing#index', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # devise_for :users, skip: :all
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
