class OpmlController < ApplicationController
  require 'nokogiri'
  require 'builder'
  require 'rake'          # Needed for the filters rake after importing

  def index
    @feeds = Feed.includes(:category).order('categories.name, feeds.name')
  end

  def import
    file = params[:file]
    doc = Nokogiri::XML(File.read(file.path))

    # Due to categories being requirement, need to get all unique category names from OPML
    category_names = []
    doc.xpath("//outline[outline[@type='rss']]").each do |outline|
      if outline['text']
        name = outline['text']
      elsif outline["title"]
        name = outline['title']
      end
      if name && !category_names.include?(name)
        category_names << name
      end
    end
    
    category_names.uniq!
    # Now the fun part... trying to create a category map
    # Set "Uncategorized" as the first category
    category_map = {}
    uncategorized_color = "#ffffff"
    uncategorized = Category.find_or_create_by!(name: "Uncategorized") do |cat|
      cat.color = uncategorized_color
    end
    category_map["Uncategorized"] = uncategorized

    # Add all the other categories from the OPML
    category_names.each do |name|
      # Skip if category is "Uncategorized", we just finished that
      next if name == "Uncategorized"

      random_color = "#%06x" % (rand * 0xffffff)
      category = Category.find_or_create_by!(name: name) do |cat|
        cat.color = random_color
      end

      category_map[name] = category
    end
    
    # Find all RSS feeds in the imported file
    feeds = doc.xpath("//outline[@type='rss']")

    feeds.each_with_index do |outline, index|
      # Default category: "Uncategorized"
      category_name = "Uncategorized"

      # Check if there is a parent outline with a name
      parent = outline.parent
      if parent && parent.name == "outline"
        if parent["text"]
          category_name = parent["text"]
        elsif parent["title"]
          category_name = parent["title"]
        end
      end

      # Look up category from the map, fallback to Uncategorized if not found
      category = category_map[category_name]
      if category.nil?
        category = category_map["Uncategorized"]
      end

      # Create the feed, if there's issuess, skip to next one
      next unless outline["xmlUrl"].present?
      feed = Feed.find_or_initialize_by(url: outline["xmlUrl"])

      if outline["title"]
        feed.name = outline["title"]
      elsif outline["text"]
        feed.name = outline["text"]
      else
        feed.name = "(No Name Feed)"
      end

      feed.category = category

      # Save the feed!!!
      feed.save!

      # Fetch the articles from the feeds :)
      Rails.application.load_tasks unless Rake::Task.task_defined?("feeds:fetch")
      Rake::Task["feeds:fetch"].reenable
      Rake::Task["feeds:fetch"].invoke
    end
  end
end
