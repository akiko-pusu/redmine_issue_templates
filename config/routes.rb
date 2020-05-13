#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  concern :tamplate_common do
    get 'orphaned_templates', on: :collection
  end

  concern :previewable do
    post 'preview', on: :collection
  end

  resources :global_issue_templates, except: [:edit], concerns: %i[tamplate_common previewable]

  # for project issue template
  resources :projects, only: [] do
    resources :issue_templates, except: [:edit], concerns: [:tamplate_common] do
      post 'set_pulldown', on: :collection
      get 'list_templates', on: :collection
    end

    resources :issue_templates_settings, only: [:edit], concerns: [:previewable] do
      patch 'edit', on: :collection
    end

    get 'issue_templates_settings', to: 'issue_templates_settings#index'

    resources :note_templates, except: [:edit]
  end

  resources :issue_templates, only: %i[load preview load_selectable_fields], concerns: [:previewable] do
    post 'load', on: :collection
    get 'load_selectable_fields', on: :collection
  end

  # for note temlate
  resources :note_templates, only: %i[load preview list_templates] do
    post 'load', on: :collection
    get 'list_templates', on: :collection
  end

  # for global note temlate
  resources :global_note_templates, except: [:edit], concerns: %i[previewable]
end
