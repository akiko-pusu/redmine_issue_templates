namespace :redmine_issue_templates do
  desc 'Apply inhelit template setting to child projects.'
  task :apply_inhelit_template_to_child_projects, 'project_id'
  task apply_inhelit_template_to_child_projects: :environment do |_t, args|
    project_id = args.project_id
    begin
      IssueTemplateSetting.apply_template_to_child_projects(project_id)
    rescue ActiveRecord::RecordNotFound
      puts "IssueTemplateSetting to project specified by #{project_id} does not exist."
    end
  end

  desc 'Unapply inhelit template setting from child projects.'
  task :unapply_inhelit_template_from_child_projects, 'project_id'
  task unapply_inhelit_template_from_child_projects: :environment do |_t, args|
    project_id = args.project_id
    begin
      IssueTemplateSetting.unapply_template_from_child_projects(project_id)
    rescue ActiveRecord::RecordNotFound
      puts "IssueTemplateSetting to project specified by #{project_id} does not exist."
    end
  end
end
