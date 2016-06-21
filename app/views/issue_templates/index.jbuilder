json.set! :global_issue_templates do
  json.array! @global_issue_templates do |template|
    json.id template.id
    json.tracker_id template.tracker_id
    json.tracker_name template.tracker.name
    json.title template.title
    json.issue_title template.issue_title
    json.description template.description
    json.note template.note
    json.enabled template.enabled
    json.updated_on template.updated_on
    json.created_on template.created_on
    json.updated_on template.updated_on
  end
end
json.set! :inherit_templates do
  json.array! @inherit_templates do |template|
    json.id template.id
    json.tracker_id template.tracker_id
    json.tracker_name template.tracker.name
    json.title template.title
    json.issue_title template.issue_title
    json.description template.description
    json.note template.note
    json.enabled template.enabled
    json.is_default template.is_default
    json.enabled_sharing template.enabled_sharing
    json.position template.position
    json.updated_on template.updated_on
    json.created_on template.created_on
    json.updated_on template.updated_on
  end
end
json.set! :issue_templates do
  json.array! project_templates do |template|
    json.id template.id
    json.tracker_id template.tracker_id
    json.tracker_name template.tracker.name
    json.title template.title
    json.issue_title template.issue_title
    json.description template.description
    json.note template.note
    json.enabled template.enabled
    json.is_default template.is_default
    json.enabled_sharing template.enabled_sharing
    json.position template.position
    json.updated_on template.updated_on
    json.created_on template.created_on
    json.updated_on template.updated_on
  end
end
