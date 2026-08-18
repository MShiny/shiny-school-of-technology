class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "not_started"
      t.text :notes

      t.timestamps
    end

    add_index :subjects, :status
  end
end
