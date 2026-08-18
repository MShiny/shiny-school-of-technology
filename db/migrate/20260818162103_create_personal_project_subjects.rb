class CreatePersonalProjectSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :personal_project_subjects do |t|
      t.references :personal_project, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end

    add_index :personal_project_subjects, [ :personal_project_id, :subject_id ], unique: true, name: "index_pp_subjects_on_project_and_subject"
  end
end
