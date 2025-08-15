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
      xml = URI.open(feed.url).read
      parsed = Feedjira.parse(xml)

      parsed.entries.each do |entry|
        next if Article.exists?(url: entry.url, feed_id: feed.id)
        
        filtered_flag = matches_filter?(entry, filters)

        Article.create!(
          feed: feed,
          title: entry.title,
          description: entry.summary || entry.content,
          url: entry.url,
          published: entry.published || Time.now,
          filtered: filtered_flag
        )
      end

      feed.update!(last_fetched_at: Time.now)

    rescue => e
      Rails.logger.error("Failed to fetch feed #{feed.url}: #{e.message}")
    end
  end

  def self.matches_filter?(entry, filters)
    filters.any? do |filter|
      term = filter.term.to_s.downcase

      title_match = filter.title && entry.title.to_s.downcase.include?(term)
      description_match = filter.description && (entry.summary.to_s.downcase.include?(term) || entry.content.to_s.downcase.include?(term))
      title_match || description_match
    end
  end
end
