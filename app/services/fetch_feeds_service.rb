class FetchFeedsService
  require 'open-uri'

  def self.call
filters = Filter.all.to_a

    Feed.find_each do |feed|
      fetch_feed(feed, filters)
    end
  end

  def self.fetch_feed(feed, filters)
    begin
      xml = URI.open(feed.url, read_timeout: 10, open_timeout: 5).read
      parsed = Feedjira.parse(xml)

      parsed.entries.each do |entry|
        next if Article.exists?(url: entry.url, feed_id: feed.id)

        matching_filter = matching_filter(entry, filters)

        Article.create!(
          feed: feed,
          title: entry.title,
          description: entry.summary || entry.content,
          url: entry.url,
          published: entry.published || Time.now,
          filtered: matching_filter.present?,
          filter: matching_filter
        )
      end


    rescue => e
      Rails.logger.error("Failed to fetch feed #{feed.url}: #{e.message}")
    end
  end

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
