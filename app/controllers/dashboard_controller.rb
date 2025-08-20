class DashboardController < ApplicationController
  def index
    @total_articles = Article.count

    @categories_count = Category.left_joins(feeds: :articles)
                                .select('categories.*, COUNT(articles.id) AS articles_count')
                                .group('categories.id')
                                .order('articles_count DESC')

    @top_feeds = Feed.joins(:articles)
                     .group('feeds.name')
                     .order('COUNT(articles.id) DESC')
                     .limit(5)
                     .count

    # Basic Count
    @total_articles = Article.count
    @total_feeds = Feed.count
    @total_categories = Category.count
    @total_filters = Filter.count

    # Article Stats
    @read_articles = Article.where(read: true).count
    @unread_articles = Article.where(read: false).count
    @starred_articles = Article.where(starred: true).count
    @filtered_articles = Article.where(filtered: true).count

    @feed_activity = Feed.joins(:articles).group("feeds.name").count

    # Most Active Feeds (24 hours)
    @feeds_24h = Feed.joins(:articles)
                    .where('articles.published >= ?', 24.hours.ago)
                    .group('feeds.name')
                    .order('COUNT(articles.id) DESC')
                    .limit(5)
                    .count

    # Most Active Feeds (All Time)
    @feeds_all_time = Feed.joins(:articles)
                          .group('feeds.name')
                          .order('COUNT(articles.id) DESC')
                          .limit(5)
                          .count


  end
end
