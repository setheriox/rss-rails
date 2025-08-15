class FetchFeedsService
  require 'open-uri'

  def self.call
    Feed.find_each do |feed|
      fetch_feed(feed)
    end
  end

  def self.fetch_feed(feed)
    begin
      xml = URI.open(feed.url).read
      parsed = Feedjira.parse(xml)

      parsed.entries.each do |entry|
        next if Article.exists?(guid: entry.id) || Article.exists?(url: entry.url)

        Article.create!(
          feed: feed,
          title: entry.title,
          description: entry.summary || entry.content,
          url: entry.url,
          published: entry.published || Time.now,
        )
      end

      feed.update!(last_fetched_at: Time.now)

    rescue => e
      Rails.logger.error("Failed to fetch feed #{feed.url}: #{e.message}")
    end
  end
end
