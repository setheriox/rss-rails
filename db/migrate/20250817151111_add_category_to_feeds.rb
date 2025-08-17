class AddCategoryToFeeds < ActiveRecord::Migration[8.0]
  def change
    add_reference :feeds, :category, null: true, foreign_key: true

    # Create Uncategorized category entry with white as color
    uncategorized = Category.find_or_create_by(name: "Uncategorized") do |cat|
      cat.color = "#ffffff"
    end

    # Update existing feeds to use uncategorized category
    Feed.where(category_id: nil).update_all(category_id: uncategorized.id)
    change_column_null :feeds, :category_id, false
  end
end
