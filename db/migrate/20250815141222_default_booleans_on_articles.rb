class DefaultBooleansOnArticles < ActiveRecord::Migration[8.0]
  def change
    change_column_default :articles, :read, from: nil, to: false
    change_column_null :articles, :read, false, false

    change_column_default :articles, :starred, from: nil, to: false
    change_column_null :articles, :starred, false, false

    change_column_default :articles, :filtered, from: nil, to: false
    change_column_null :articles, :filtered, false, false
  end
end
