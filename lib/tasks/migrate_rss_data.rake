# lib/tasks/migrate_rss_data.rake

require 'sqlite3'

namespace :migrate do
  desc "Migrate data from old RSS SQLite database to Rails models"
  task rss_data: :environment do
    # Path to your old SQLite database
    old_db_path = ENV['OLD_DB_PATH'] || 'rss.db'
    
    unless File.exist?(old_db_path)
      puts "❌ Database file not found: #{old_db_path}"
      puts "Usage: OLD_DB_PATH=/path/to/rss.db bundle exec rake migrate:rss_data"
      exit 1
    end
    
    # Connect to old database
    old_db = SQLite3::Database.new(old_db_path)
    old_db.results_as_hash = true
    
    puts "🚀 Starting RSS data migration..."
    
    # Track statistics
    stats = {
      categories: 0,
      feeds: 0,
      articles: 0,
      filters: 0,
      skipped_articles: 0
    }
    
    # Wrap everything in a transaction for safety
    ActiveRecord::Base.transaction do
      
      # 1. Migrate Categories
      puts "\n📁 Migrating categories..."
      categories_map = {}
      
      old_db.execute("SELECT * FROM categories ORDER BY id") do |row|
        category = Category.find_or_create_by(name: row['name']) do |c|
          c.color = row['color']
        end
        categories_map[row['id']] = category.id
        stats[:categories] += 1
        print "."
      end
      
      puts "\n✅ Migrated #{stats[:categories]} categories"
      
      # 2. Migrate Feeds
      puts "\n📡 Migrating feeds..."
      feeds_map = {}
      
      old_db.execute("SELECT * FROM feeds ORDER BY id") do |row|
        feed = Feed.find_or_create_by(url: row['url']) do |f|
          f.name = row['name']
          f.category_id = categories_map[row['category_id']]
        end
        feeds_map[row['id']] = feed.id
        stats[:feeds] += 1
        print "."
      end
      
      puts "\n✅ Migrated #{stats[:feeds]} feeds"
      
      # 3. Migrate Filters
      puts "\n🔍 Migrating filters..."
      filters_map = {}
      
      old_db.execute("SELECT * FROM filters ORDER BY id") do |row|
        filter = Filter.find_or_create_by(term: row['term']) do |f|
          f.title = row['title'] == 1
          f.description = row['description'] == 1
        end
        filters_map[row['id']] = filter.id
        stats[:filters] += 1
        print "."
      end
      
      puts "\n✅ Migrated #{stats[:filters]} filters"
      
      # 4. Migrate Entries to Articles (most complex part)
      puts "\n📰 Migrating entries to articles..."
      
      # Process in batches to handle large datasets
      batch_size = 1000
      offset = 0
      
      loop do
        entries = old_db.execute(
          "SELECT * FROM entries ORDER BY id LIMIT #{batch_size} OFFSET #{offset}"
        )
        
        break if entries.empty?
        
        entries.each do |row|
          begin
            # Determine if article was filtered and which filter was used
            filter_id = nil
            filtered = false
            
            if row['filtered'] == 1 || row['manually_filtered'] == 1
              filtered = true
              # Try to determine which filter was applied based on filter_reason
              if row['filter_reason'] && !filters_map.empty?
                # This is a best guess - you might need to adjust this logic
                matching_filter = Filter.find_by(term: row['filter_reason'])
                filter_id = matching_filter&.id
              end
            end
            
            # Skip if article with same URL already exists
            if Article.exists?(url: row['link'])
              stats[:skipped_articles] += 1
              next
            end
            
            Article.create!(
              feed_id: feeds_map[row['feed_id']],
              title: row['title'],
              description: row['description'],
              url: row['link'],
              published: row['published'] ? Time.parse(row['published'].to_s) : nil,
              read: row['read'] == 1,
              starred: row['starred'] == 1,
              filtered: filtered,
              filter_id: filter_id
            )
            
            stats[:articles] += 1
            print "." if stats[:articles] % 100 == 0
            
          rescue => e
            puts "\n⚠️  Error migrating entry ID #{row['id']}: #{e.message}"
            # Continue with next entry
          end
        end
        
        offset += batch_size
        puts "\n   Processed #{offset} entries..." if offset % 5000 == 0
      end
      
      puts "\n✅ Migrated #{stats[:articles]} articles (skipped #{stats[:skipped_articles]} duplicates)"
      
    end # End transaction
    
    # Close old database connection
    old_db.close
    
    # Print final statistics
    puts "\n" + "="*50
    puts "🎉 Migration completed successfully!"
    puts "="*50
    puts "Categories: #{stats[:categories]}"
    puts "Feeds: #{stats[:feeds]}"
    puts "Filters: #{stats[:filters]}"
    puts "Articles: #{stats[:articles]}"
    puts "Skipped duplicates: #{stats[:skipped_articles]}"
    puts "="*50
    
    puts "\n💡 Next steps:"
    puts "1. Verify data integrity in Rails console"
    puts "2. Test your application functionality"
    puts "3. Consider running: bundle exec rake db:migrate:reset if you need to re-run"
    
  rescue => e
    puts "\n❌ Migration failed: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    raise
  end
end