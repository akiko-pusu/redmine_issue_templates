#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  resources :global_issue_templates, except: [:edit] do
    post 'preview', on: :collection
    get 'orphaned_templates', on: :collection
  end

  # for project issue template
  resources :projects, only: [] do
    resources :issue_templates, except: [:edit] do
      post 'preview', on: :collection
      get 'orphaned_templates', on: :collection
      post 'set_pulldown', on: :collection
      get 'list_templates', on: :collection
      post 'load', on: :collection
      get 'load', on: :member
    end

    resources :issue_templates_settings, only: [] do
      patch 'edit', on: :collection
      post 'preview', on: :collection
    end
  end
end
