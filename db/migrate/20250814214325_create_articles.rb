class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.bigint :feed_id
      t.text :title
      t.text :description
      t.text :url
      t.datetime :published
      t.boolean :read
      t.boolean :starred
      t.boolean :filtered

      t.timestamps
    end
  end
end
