class CreateFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url, null: false

      t.timestamps
    end
  end
end
