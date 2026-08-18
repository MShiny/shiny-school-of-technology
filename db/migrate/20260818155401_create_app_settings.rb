class CreateAppSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :app_settings do |t|
      t.text :default_daily_goal, null: false

      t.timestamps
    end
  end
end
