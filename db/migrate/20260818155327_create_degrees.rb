class CreateDegrees < ActiveRecord::Migration[8.0]
  def change
    create_table :degrees do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "planned"

      t.timestamps
    end

    add_index :degrees, :status
  end
end
