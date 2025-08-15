#!/usr/bin/env ruby

require_relative '../config/environment'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'time'
require 'logger'

class FeedFetcher
  def initialize
    @logger = Logger.new(Rails.root.join('log', 'feed_fetcher.log'))
    @logger.level = Logger::INFO
    @logger.info "Feed fetcher initialized"
  end

  private

  public

  def get_all_feeds
    Feed.all.map do |feed|
      {
        id: feed.id,
        name: feed.name,
        url: feed.url
      }
    end
  end

  def fetch_url_with_retry(url, max_retries = 3)
    attempt = 1

    while attempt <= max_retries
      begin
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 30
        http.open_timeout = 30

        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          @logger.info "Downloaded #{response.body.length} bytes from #{url}"
          return response.body
        elsif response.is_a?(Net::HTTPRedirection)
          # Handle redirects
          redirect_location = response['Location']
          if redirect_location
            # Handle relative redirects
            if redirect_location.start_with?('/')
              redirect_url = "#{uri.scheme}://#{uri.host}#{uri.port != 80 && uri.port != 443 ? ":#{uri.port}" : ''}#{redirect_location}"
            else
              redirect_url = redirect_location
            end

            @logger.info "Following redirect from #{url} to #{redirect_url}"
            return fetch_url_with_retry(redirect_url, max_retries - attempt + 1)
          else
            raise "HTTP #{response.code}: #{response.message} (no redirect location)"
          end
        else
          raise "HTTP #{response.code}: #{response.message}"
        end

      rescue => e
        @logger.warn "Attempt #{attempt} failed for #{url}: #{e.message}"

        if attempt < max_retries
          sleep_time = attempt
          sleep(sleep_time)
          attempt += 1
        else
          raise "Failed to fetch feed after #{max_retries} attempts: #{e.message}"
        end
      end
    end
  end

  def clean_xml_content(content)
    return content if content.nil? || content.empty?

    begin
      # Handle common malformed DOCTYPE issues
      content = content.gsub(/<\s*doctype\s+/i, '<!DOCTYPE ')

      # Remove problematic DOCTYPE declarations
      content = content.gsub(/<!\\s*DOCTYPE[^>]*>/i, '')

      # Fix XML processing instructions
      content = content.gsub(/<\?\s*xml[^>]*\?>/i, '<?xml version="1.0" encoding="UTF-8"?>')

      # Ensure proper XML declaration
      unless content.strip.match?(/^\s*<\?xml/i)
        content = '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + content.strip
      end

      content
    rescue => e
      @logger.warn "Error cleaning XML content: #{e.message}"
      content
    end
  end

  def parse_rss_feed(xml_doc, feed_id)
    added_count = 0

    # Handle different RSS formats
    items = xml_doc.xpath('//item') # RSS 2.0
    if items.empty?
      items = xml_doc.xpath('//entry') # Atom (no namespace)
    end
    if items.empty?
      items = xml_doc.xpath('//atom:entry', 'atom' => 'http://www.w3.org/2005/Atom') # Atom with namespace
    end
    if items.empty?
      items = xml_doc.xpath('//rss:item', 'rss' => 'http://purl.org/rss/1.0/') # RDF/RSS 1.0
    end

    @logger.info "Found #{items.length} items in feed"

    items.each do |item|
      title = ''
      description = ''
      url = ''
      published = Time.now

      # RSS 2.0 format
      if item.name == 'item'
        title = item.xpath('title').text.strip
        description = item.xpath('description').text.strip
        url = item.xpath('link').text.strip
        pub_date = item.xpath('pubDate').text.strip
        published = Time.parse(pub_date) unless pub_date.empty?

      # Atom format
      elsif item.name == 'entry'
        # Try with namespace first, then without
        title = item.xpath('atom:title', 'atom' => 'http://www.w3.org/2005/Atom').text.strip
        title = item.xpath('title').text.strip if title.empty?

        summary = item.xpath('atom:summary', 'atom' => 'http://www.w3.org/2005/Atom').text.strip
        summary = item.xpath('summary').text.strip if summary.empty?

        content = item.xpath('atom:content', 'atom' => 'http://www.w3.org/2005/Atom').text.strip
        content = item.xpath('content').text.strip if content.empty?

        description = content.empty? ? summary : content

        link_elem = item.xpath('atom:link[@rel="alternate"]', 'atom' => 'http://www.w3.org/2005/Atom').first
        link_elem = item.xpath('atom:link', 'atom' => 'http://www.w3.org/2005/Atom').first if link_elem.nil?
        link_elem = item.xpath('link[@rel="alternate"]').first if link_elem.nil?
        link_elem = item.xpath('link').first if link_elem.nil?
        url = link_elem['href'] if link_elem

        published_elem = item.xpath('atom:published', 'atom' => 'http://www.w3.org/2005/Atom').first
        published_elem = item.xpath('atom:updated', 'atom' => 'http://www.w3.org/2005/Atom').first if published_elem.nil?
        published_elem = item.xpath('published').first if published_elem.nil?
        published_elem = item.xpath('updated').first if published_elem.nil?
        published = Time.parse(published_elem.text) if published_elem
      end

      # Skip entries with empty URLs
      if url.empty?
        @logger.debug "Skipping entry with empty URL: #{title}"
        next
      end

      # Check if article already exists
      existing_article = Article.find_by(url: url, feed_id: feed_id)

      if existing_article.nil?
        # Create new article
        Article.create!(
          title: title,
          description: description,
          url: url,
          published: published,
          feed_id: feed_id,
          read: false,
          starred: false,
          filtered: false
        )

        added_count += 1
        @logger.info "Added new article: #{title}"
      else
        @logger.debug "Article already exists: #{title} (#{url})"
      end
    end

    added_count
  end

  def refresh_feeds
    start_time = Time.now
    @logger.info "Starting RSS feed refresh..."

    begin
      feeds = get_all_feeds
      @logger.info "Found #{feeds.length} feeds to refresh"

      total_added = 0
      success_count = 0
      error_count = 0

      feeds.each do |feed|
        begin
          @logger.info "Fetching feed: #{feed[:name]} (#{feed[:url]})"

          content = fetch_url_with_retry(feed[:url])

          if content.nil? || content.strip.empty?
            raise "Feed returned empty content"
          end

          content = clean_xml_content(content)

          # Parse XML
          xml_doc = Nokogiri::XML(content) do |config|
            config.nocdata
          end

          added = parse_rss_feed(xml_doc, feed[:id])
          total_added += added
          success_count += 1

          @logger.info "Successfully processed feed: #{feed[:name]} (Added: #{added})"

        rescue => e
          error_count += 1
          @logger.error "Error processing feed #{feed[:name]}: #{e.message}"
        end
      end

      duration = ((Time.now - start_time) * 1000).round
      @logger.info "Feed refresh completed in #{duration}ms - Added: #{total_added}, Success: #{success_count}, Errors: #{error_count}"

      {
        success: true,
        duration: duration,
        feeds_processed: feeds.length,
        articles_added: total_added,
        feeds_success: success_count,
        feeds_error: error_count
      }

    rescue => e
      @logger.error "Critical error during feed refresh: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end
end

# CLI usage
if __FILE__ == $0
  if ARGV.length > 0 && ARGV[0] == '--help'
    puts "Feed Fetcher - Rails version"
    puts "Usage:"
    puts "  ruby fetch.rb                       # Run feed refresh"
    puts "  ruby fetch.rb --help                # Show this help"
    exit
  end

  fetcher = FeedFetcher.new

  begin
    result = fetcher.refresh_feeds

    if result[:success]
      puts "Feed refresh completed successfully:"
      puts "  Duration: #{result[:duration]}ms"
      puts "  Feeds processed: #{result[:feeds_processed]}"
      puts "  Articles added: #{result[:articles_added]}"
      puts "  Feeds success: #{result[:feeds_success]}"
      puts "  Feeds error: #{result[:feeds_error]}"
    else
      puts "Feed refresh failed: #{result[:error]}"
      exit 1
    end
  end
end
