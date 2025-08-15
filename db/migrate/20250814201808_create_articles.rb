class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :url
      t.datetime :published
      t.boolean :read
      t.boolean :starred
      t.boolean :filtered

      t.timestamps
    end
  end
end
