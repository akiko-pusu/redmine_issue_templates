Rails.application.routes.draw do 
  match 'projects/:project_id/issue_templates/:action', :to => 'issue_templates'
  match 'projects/:project_id/issue_templates/:action/:id', :to => 'issue_templates#edit'
  match 'projects/:project_id/issue_templates_settings/:action', :to => 'issue_templates_settings'
  match 'issue_templates/preview/:id', :to => 'issue_templates#preview'
  match 'projects/:project_id/issue_templates_settings/preview', :to => 'issue_templates_settings#preview', :via => [:get, :post]
end