class AddRoadmapPositionToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :roadmap_position, :integer
  end
end
