json.extract! article, :id, :feed_id, :title, :description, :url, :published, :read, :starred, :filtered, :created_at, :updated_at
json.url article_url(article, format: :json)
