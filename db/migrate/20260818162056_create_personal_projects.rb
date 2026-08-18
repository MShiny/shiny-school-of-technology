class CreatePersonalProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :personal_projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "idea"
      t.text :goal
      t.date :target_date
      t.text :notes

      t.timestamps
    end

    add_index :personal_projects, :status
  end
end
