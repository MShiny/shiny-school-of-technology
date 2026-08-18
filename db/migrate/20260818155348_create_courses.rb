class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.references :subject, null: false, foreign_key: true
      t.string :title, null: false
      t.string :provider
      t.string :url
      t.string :status, null: false, default: "planned"
      t.string :level
      t.integer :progress_percentage
      t.text :notes

      t.timestamps
    end

    add_index :courses, :status
  end
end
