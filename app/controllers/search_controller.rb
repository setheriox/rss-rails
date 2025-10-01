class SearchController < ApplicationController
  def index
    if params[:q].present?
      query = "%#{params[:q]}%"
      @articles = Article.includes(:feed)
                        .where(filtered: false)
                        .where("articles.title LIKE ? OR articles.description LIKE ?", query, query)
                        .order(published: :desc, id: :desc)
                        .page(params[:page])
    else
      @articles = Article.none.page(params[:page])
    end
  end
end
