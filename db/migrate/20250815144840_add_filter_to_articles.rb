class AddFilterToArticles < ActiveRecord::Migration[8.0]
  def change
    add_reference :articles, :filter, foreign_key: true
  end
end
