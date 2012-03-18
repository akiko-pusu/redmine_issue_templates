# Routes
ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/issue_templates/:action', :controller => 'issue_templates'
	map.connect 'projects/:project_id/issue_templates/:action/:id', :controller => 'issue_templates', :action => 'edit'
  map.connect 'projects/:project_id/issue_templates_settings/:action', 
    :controller => 'issue_templates_settings'
  map.connect 'issue_templates/preview/:id', :controller => 'issue_templates', :action => 'preview'
  map.connect 'projects/:project_id/issue_templates_settings/preview', :controller => 'issue_templates_settings', :action => 'preview', :conditions => {:method => :post }
end