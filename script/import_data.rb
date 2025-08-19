# Save this as import_data.rb in your Rails root
# Run with: RAILS_ENV=production rails runner import_data.rb

require 'json'

puts "Importing data to PostgreSQL..."

# Clear existing data first
puts "Clearing existing data..."
Article.delete_all
Feed.delete_all
Filter.delete_all
Category.delete_all

# Disable foreign key checks temporarily
ActiveRecord::Base.connection.execute('SET session_replication_role = replica;') rescue nil

data = JSON.parse(File.read('db/export_data.json'))

# Reset sequences before import to avoid conflicts
puts "Resetting sequences..."
ActiveRecord::Base.connection.execute("SELECT setval('categories_id_seq', 1, false);")
ActiveRecord::Base.connection.execute("SELECT setval('feeds_id_seq', 1, false);")
ActiveRecord::Base.connection.execute("SELECT setval('filters_id_seq', 1, false);")
ActiveRecord::Base.connection.execute("SELECT setval('articles_id_seq', 1, false);")

# Import in dependency order using raw SQL for better performance
puts "Importing categories..."
data['categories'].each do |category|
  # Handle null timestamps
  created_at = category['created_at'] || Time.current.to_s
  updated_at = category['updated_at'] || Time.current.to_s
  
  ActiveRecord::Base.connection.execute(
    "INSERT INTO categories (id, name, color, created_at, updated_at) VALUES (#{category['id']}, #{ActiveRecord::Base.connection.quote(category['name'])}, #{ActiveRecord::Base.connection.quote(category['color'])}, #{ActiveRecord::Base.connection.quote(created_at)}, #{ActiveRecord::Base.connection.quote(updated_at)})"
  )
end

puts "Importing filters..."
data['filters'].each do |filter|
  # Handle null timestamps
  created_at = filter['created_at'] || Time.current.to_s
  updated_at = filter['updated_at'] || Time.current.to_s
  
  ActiveRecord::Base.connection.execute(
    "INSERT INTO filters (id, term, title, description, created_at, updated_at) VALUES (#{filter['id']}, #{ActiveRecord::Base.connection.quote(filter['term'])}, #{filter['title']}, #{filter['description']}, #{ActiveRecord::Base.connection.quote(created_at)}, #{ActiveRecord::Base.connection.quote(updated_at)})"
  )
end

puts "Importing feeds..."
data['feeds'].each do |feed|
  # Handle null timestamps
  created_at = feed['created_at'] || Time.current.to_s
  updated_at = feed['updated_at'] || Time.current.to_s
  
  ActiveRecord::Base.connection.execute(
    "INSERT INTO feeds (id, name, url, created_at, updated_at, category_id) VALUES (#{feed['id']}, #{ActiveRecord::Base.connection.quote(feed['name'])}, #{ActiveRecord::Base.connection.quote(feed['url'])}, #{ActiveRecord::Base.connection.quote(created_at)}, #{ActiveRecord::Base.connection.quote(updated_at)}, #{feed['category_id']})"
  )
end

puts "Importing articles (this may take a while)..."
data['articles'].each_with_index do |article, index|
  published = article['published'] ? ActiveRecord::Base.connection.quote(article['published']) : 'NULL'
  filter_id = article['filter_id'] ? article['filter_id'] : 'NULL'
  
  # Handle null timestamps
  created_at = article['created_at'] || Time.current.to_s
  updated_at = article['updated_at'] || Time.current.to_s
  
  ActiveRecord::Base.connection.execute(
    "INSERT INTO articles (id, feed_id, title, description, url, published, filter_id, read, starred, filtered, created_at, updated_at) VALUES (#{article['id']}, #{article['feed_id']}, #{ActiveRecord::Base.connection.quote(article['title'])}, #{ActiveRecord::Base.connection.quote(article['description'])}, #{ActiveRecord::Base.connection.quote(article['url'])}, #{published}, #{filter_id}, #{article['read']}, #{article['starred']}, #{article['filtered']}, #{ActiveRecord::Base.connection.quote(created_at)}, #{ActiveRecord::Base.connection.quote(updated_at)})"
  )
  
  # Progress indicator
  if (index + 1) % 1000 == 0
    puts "Imported #{index + 1} articles..."
  end
end

# Re-enable foreign key checks
ActiveRecord::Base.connection.execute('SET session_replication_role = DEFAULT;') rescue nil

# Set sequences to the correct next value
puts "Setting sequences to correct values..."
ActiveRecord::Base.connection.execute("SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));")
ActiveRecord::Base.connection.execute("SELECT setval('feeds_id_seq', (SELECT MAX(id) FROM feeds));")
ActiveRecord::Base.connection.execute("SELECT setval('filters_id_seq', (SELECT MAX(id) FROM filters));")
ActiveRecord::Base.connection.execute("SELECT setval('articles_id_seq', (SELECT MAX(id) FROM articles));")

puts "Import complete!"
puts "Categories: #{Category.count}"
puts "Feeds: #{Feed.count}"
puts "Filters: #{Filter.count}"
puts "Articles: #{Article.count}"