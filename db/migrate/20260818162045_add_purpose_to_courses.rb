class AddPurposeToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :purpose, :text
  end
end
