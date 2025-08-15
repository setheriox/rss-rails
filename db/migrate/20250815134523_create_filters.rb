class CreateFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :filters do |t|
      t.text :term
      t.boolean :title
      t.boolean :description

      t.timestamps
    end
  end
end
