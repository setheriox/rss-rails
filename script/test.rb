require 'feedjira'

url = 'https://animecornerstore.blogspot.com/feeds/posts/default?alt=rss'

begin
  feed = Feedjira.parse(URI.open(url).read)

  puts "Feed name: #{feed.name}"
  feed.entries.each do |entry|
    puts "Title: #{entry.title}"
    puts "URL: #{entry.url}"
    puts "Published: #{entry.published}"
    puts "Summary: #{entry.summary}"
    puts "---"
  end
rescue OpenURI::HTTPError => e
  puts "Failed to open URL: #{e.message}"
rescue => e
  puts "Failed to parse feed: #{e.message}"
end
