class FetchFeedsService
  require 'open-uri'

  def self.call
    filters = Filter.all.to_a

    Feed.find_each do |feed|
      fetch_feed(feed, filters)
    end
  end

  # custom santization to keep pesky rss annoyances at bay
  def self.sanitize_content(content)
    return content unless content
  
    doc = Nokogiri::HTML::DocumentFragment.parse(content)

    # Fuck iframes and embeddings! (I'm looking at you slashdot!)
    doc.css('iframe, embed, object, applet, script').remove
    doc.to_html
  end
  

  def self.fetch_feed(feed, filters)
    begin
      xml = URI.parse(feed.url).open(read_timeout: 10, open_timeout: 5).read
      parsed = Feedjira.parse(xml)

      parsed.entries.each do |entry|

        # output some pretty console data, can also be used to log for skipped entries
        if Article.exists?(url: entry.url, feed_id: feed.id)
          #puts "Duplicate Entry - Skipping: #{feed.name[0,24]} \t #{entry.title[0,24]} \t #{entry.published || Time.now}"

          feed_name = feed.name[0,12]
          title = entry.title[0,40]
          published = entry.published.in_time_zone("Eastern Time (US & Canada)")  

          printf "Duplicate Entry - Skipping: %-16s %-44s %s\n", feed_name, title, published
          next
        end
        matching_filter = matching_filter(entry, filters)

        # Add the article to the database!
        Article.create!(
          feed: feed,
          title: entry.title,
          description: entry.summary || entry.content,
          url: entry.url,
          published: entry.published || Time.now,
          filtered: matching_filter.present?,
          filter: matching_filter
        )

        # output pretty console data part 2! But this time, it's new entries!
        puts "Added: #{feed.name} - #{entry.title} - #{entry.published || Time.now}"
      end

    rescue => e
      Rails.logger.error("Failed to fetch feed #{feed.url}: #{e.message}")
    end
  end

  # Check if entry contains any filtered data, if so, filter it! 
  def self.matching_filter(entry, filters)
    filters.find do |filter|
      title_match = filter.title && entry.title.to_s.match?(filter.regex)
      description_match = filter.description &&
                          (entry.summary.to_s.match?(filter.regex) ||
                          entry.content.to_s.match?(filter.regex))
      title_match || description_match
    end
  end
end
