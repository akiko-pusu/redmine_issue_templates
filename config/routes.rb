#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  get 'projects/:project_id/issue_templates', to: 'issue_templates#index'
  match 'projects/:project_id/issue_templates/:action', controller: 'issue_templates', via: %i[get post patch put]
  match 'projects/:project_id/issue_templates/:action/:id', to: 'issue_templates#edit', via: %i[patch put post get], as: 'issue_template'
  match 'issue_templates/preview', to: 'issue_templates#preview', via: %i[get post]
  get 'projects/:project_id/issue_templates/orphaned_templates', to: 'issue_templates#orphaned_templates', as: 'project_orphaned_templates'
  resources :global_issue_templates, except: [:edit] do
    get 'preview', on: :collection
    get 'orphaned_templates', on: :collection
  end

  # for project issue template
  resources :projects do
    resources :issue_templates_settings, only: [] do
      patch 'edit', on: :collection
      post 'preview', on: :collection
    end
  end
end
