Rails.application.routes.draw do 
  match 'projects/:project_id/issue_templates/:action', :to => 'issue_templates'
  match 'projects/:project_id/issue_templates/:action/:id', :to => 'issue_templates#edit'
  match 'projects/:project_id/issue_templates/move/:id', :to => 'issue_templates#move_to'
  match 'projects/:project_id/issue_templates_settings/:action', :to => 'issue_templates_settings'
  match 'issue_templates/preview', :to => 'issue_templates#preview', :via => [:get, :post]
  match 'projects/:project_id/issue_templates_settings/preview', :to => 'issue_templates_settings#preview', :via => [:get, :post]
  match 'global_issue_templates/:action', :to => 'global_issue_templates'
  match 'global_issue_templates/:action/:id', :to => 'global_issue_templates#edit'
  match 'global_issue_templates/preview', :to => 'global_issue_templates#preview', :via => [:get, :post]
end