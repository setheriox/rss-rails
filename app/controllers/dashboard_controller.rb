class DashboardController < ApplicationController
  def index

    @total_articles = Article.count

    @categories_count = Category.left_joins(feeds: :articles)
                                .select('categories.*, COUNT(articles.id) AS articles_count')
                                .group('categories.id')
                                .order('articles_count DESC')

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

    #@@read_percentage = @total_Articles > 0 ? (@read_articles.to_f / @total_articles * 100).round(1) : 0 
  end
end
