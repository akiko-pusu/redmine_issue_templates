#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  concern :tamplate_common do
    post 'preview', on: :collection
    get 'orphaned_templates', on: :collection
  end

  resources :global_issue_templates, except: [:edit], concerns: :tamplate_common

  # for project issue template
  resources :projects, only: [] do
    resources :issue_templates, except: [:edit], concerns: :tamplate_common do
      post 'set_pulldown', on: :collection
      get 'list_templates', on: :collection
      post 'load', on: :collection
    end

    resources :issue_templates_settings, only: [] do
      patch 'edit', on: :collection
      post 'preview', on: :collection
    end
  end
end
