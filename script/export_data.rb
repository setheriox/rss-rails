# Save this as export_data.rb in your Rails root
# Run with: rails runner export_data.rb

require 'json'

puts "Exporting data from SQLite..."

data = {
  categories: Category.all.as_json,
  feeds: Feed.all.as_json,
  filters: Filter.all.as_json,
  articles: Article.all.as_json
}

File.write('db/export_data.json', JSON.pretty_generate(data))
puts "Data exported to db/export_data.json"
puts "Categories: #{data[:categories].length}"
puts "Feeds: #{data[:feeds].length}"
puts "Filters: #{data[:filters].length}"
puts "Articles: #{data[:articles].length}"