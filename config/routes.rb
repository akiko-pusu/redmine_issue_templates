#
# TODO: Clean up routing.
#
Rails.application.routes.draw do
  get 'projects/:project_id/issue_templates', to: 'issue_templates#index'
  match 'projects/:project_id/issue_templates/:action', controller: 'issue_templates', via: %i[get post patch put]
  match 'projects/:project_id/issue_templates/:action/:id', to: 'issue_templates#edit', via: %i[patch put post get], as: 'issue_template'
  match 'projects/:project_id/issue_templates_settings/:action', controller: 'issue_templates_settings', via: %i[get post patch put]
  match 'issue_templates/preview', to: 'issue_templates#preview', via: %i[get post]
  match 'projects/:project_id/issue_templates_settings/preview', to: 'issue_templates_settings#preview', via: %i[get post]
  get 'projects/:project_id/issue_templates/orphaned_templates', to: 'issue_templates#orphaned_templates', as: 'project_orphaned_templates'
  resources :global_issue_templates, except: [:edit] do
    get 'preview', on: :collection
    get 'orphaned_templates', on: :collection
  end
end
