class CreateJoinTableGlobalNoteTemplateProject < ActiveRecord::Migration[5.2]
  def change
    create_join_table :global_note_templates, :projects do |t|
      # t.index [:global_note_template_id, :project_id]
      # t.index [:project_id, :global_note_template_id]
    end
  end
end
