# db/seeds.rb

# categories
Category.find_or_create_by!(name: "Uncategorized") { |cat| cat.color = "#ffffff" }
Category.find_or_create_by!(name: "Anime") { |cat| cat.color = "#8ff0a4" }
Category.find_or_create_by!(name: "News") { |cat| cat.color = "#3584e4" }
Category.find_or_create_by!(name: "Reddit") { |cat| cat.color = "#e01b24" }
Category.find_or_create_by!(name: "Server") { |cat| cat.color = "#dc8add" }
Category.find_or_create_by!(name: "youtube") { |cat| cat.color = "#ff7800" }
Category.find_or_create_by!(name: "Tech") { |cat| cat.color = "#3584e4" }
Category.find_or_create_by!(name: "Torrents") { |cat| cat.color = "#8ff0a4" }
Category.find_or_create_by!(name: "Gaming") { |cat| cat.color = "#408654" }

uncategorized = Category.find_by!(name: "Uncategorized")
anime = Category.find_by!(name: "Anime")
news = Category.find_by!(name: "News")
reddit = Category.find_by!(name: "Reddit")
server = Category.find_by!(name: "Server")
youtube = Category.find_by!(name: "youtube")
tech = Category.find_by!(name: "Tech")
torrents = Category.find_by!(name: "Torrents")
gaming = Category.find_by!(name: "Gaming")

# feeds
feeds = [

  { name: "Anime News Network", url: "https://www.animenewsnetwork.com/newsfeed/rss.xml", category: anime },


  { name: "[GM]Dave", url: "https://bannable-offenses.blogspot.com/feeds/posts/default", category: gaming },
  { name: "IGN", url: "https://www.ign.com/rss/v2/articles/feed", category: gaming },





  { name: "Slashdot", url: "https://rss.slashdot.org/Slashdot/slashdot", category: news },





  { name: "programminghumor", url: "https://www.reddit.com/r/programminghumor.rss", category: reddit },















  { name: "kumanuki", url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCYYlQ_kMJ5fV3RxpDd1TALQ", category: youtube },
  { name: "Legal Mindset", url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCtiec4EBNN3iiNgXHgykm9A", category: youtube },
  { name: "Matthew Shezmen", url: "https://www.youtube.com/feeds/videos.xml?channel_id=UCB4WnO_ELLYdSBxiFn3Wn1A", category: youtube }
]
feeds.each do |f|
  Feed.find_or_create_by!(name: f[:name]) do |feed|
    feed.url = f[:url]
    feed.category = f[:category] || uncategorized
  end
end

Filter.create!([
  { term: "promo", title: true, description: false },
  { term: "coupon", title: true, description: false },
  { term: "codes*025", title: true, description: false },
  { term: "best deals today", title: true, description: false },
  { term: "best*202", title: true, description: false },
  { term: "last of us", title: true, description: false },
  { term: "deals save", title: true, description: false },
  { term: "save deals", title: true, description: false },
  { term: "best deals", title: true, description: false },
  { term: "best add", title: true, description: false },
  { term: "Combinator", title: true, description: false },
  { term: "how to choose", title: true, description: false },
  { term: "ways to upgrade", title: true, description: false },
  { term: "1*Best", title: true, description: false },
  { term: "you can buy", title: true, description: false },
  { term: "save*$", title: true, description: false },
  { term: "discount", title: true, description: false },
  { term: "cheap", title: true, description: false },
  { term: "All Stage 2025", title: true, description: false },
  { term: "202*Review", title: true, description: false },
  { term: "trouble flying", title: true, description: false },
  { term: "Prime Day", title: true, description: false },
  { term: "save off", title: true, description: false },
  { term: "best buy", title: true, description: false },
  { term: "Tested Reviewed", title: true, description: false },
  { term: "$*off", title: true, description: false },
  { term: "#shorts", title: true, description: false }
])