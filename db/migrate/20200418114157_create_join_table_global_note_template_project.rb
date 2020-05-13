class CreateJoinTableGlobalNoteTemplateProject < ActiveRecord::Migration[5.2]
  def change
    create_join_table :global_note_templates, :projects, table_name: :global_note_template_projects do |t|
      # t.index [:global_note_template_id, :project_id]
      # t.index [:project_id, :global_note_template_id]
    end
  end
end
