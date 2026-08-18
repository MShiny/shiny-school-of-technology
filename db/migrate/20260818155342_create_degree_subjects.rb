class CreateDegreeSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :degree_subjects do |t|
      t.references :degree, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end

    add_index :degree_subjects, [ :degree_id, :subject_id ], unique: true
  end
end
