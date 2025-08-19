class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    
    # Utilizes kaminari pagination, config @ config/initializers/kaminariconfig.rb
    # Grab only the articles not explicitly filtered, include the feed to avoid N+1 queries,

    @articles = Article.includes(:feed)
                       .where(filtered: false)
                       .order(published: :desc, id: :desc)
  
    if params[:category_id].present?
      @articles = @articles.joins(:feed).where(feeds: { category_id: params[:category_id] })
    end

    # NOTE!!!! Revisit THIS!!!
    # Just because I got feed id filtering, doesn't mean I'm done! 
    # I need to check out to make sure all other params are sent through all other methods as well
    if params[:feed_id].present?
      @articles = @articles.joins(:feed).where(articles: { feed_id: params[:feed_id] })
    end

    if params[:starred].present?
      @articles = @articles.where(starred: true)
    end

    if params[:unread].present?
      @articles = @articles.where(read: false) 
    end

    @articles = @articles.page(params[:page])

    # Get All Categories and Feeds
    @categories = Category.left_joins(:feeds)
                          .select("categories.*, COUNT(feeds.id) AS feeds_count")
                          .group("categories.id")
                          .order(name: :asc)
    if params[:category_id].present?
      @selected_category = Category.find(params[:category_id])
      @feeds_in_category = @selected_category.feeds.order(:name)
    end
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # Toggle read/unread status for an article via AJAX / Stimulus?
  def toggle_read
    @article = Article.find(params[:id])
    
    if @article.read == true
      @article.read = false
    else
      @article.read = true
    end
    
    if @article.save
      render json: { 
        success: true, 
        read: @article.read 
      }
    else
      render json: { 
        success: false, 
        errors: @article.errors.full_messages 
      }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { 
      success: false, 
      errors: ['Article not found'] 
    }, status: :not_found
  end


  # Toggle read/unread status for an article via AJAX / Stimulus?
  def toggle_starred
    @article = Article.find(params[:id])
    
    if @article.starred == true
      @article.starred = false
    else
      @article.starred = true
    end
    
    if @article.save
      render json: { 
        success: true, 
        starred: @article.starred 
      }
    else
      render json: { 
        success: false, 
        errors: @article.errors.full_messages 
      }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { 
      success: false, 
      errors: ['Article not found'] 
    }, status: :not_found
  end

  # Button to mark all (unread) items as read
  def mark_all_read
    Article.where(read: false).update_all(read: true)
    redirect_to articles_path, 
    notice: "All Items have been marked as read."
  end

  # Button to mark current page items as read
  def mark_page_read
    articles = Article.includes(:feed)
                      .where(filtered: false)
                      .order(published: :desc, id: :desc)

    # Apply category filter if present
    if params[:category_id].present?
      articles = articles.joins(:feed).where(feeds: { category_id: params[:category_id] })
    end

    # Apply feed filter if present  
    if params[:feed_id].present?
      articles = articles.joins(:feed).where(articles: { feed_id: params[:feed_id] })
    end

    # Apply starred filter if present
    if params[:starred].present?
      articles = articles.where(starred: true)
    end

    # Apply unread filter if present
    if params[:unread].present?
      articles = articles.where(read: false)
    end

    # Pagination
    page_articles = articles.page(params[:page])

    # Mark as read
    page_articles.update_all(read: true)

    # Preserve parameters in redirect...
    redirect_to articles_path(
      page: params[:page], 
      category_id: params[:category_id],
      feed_id: params[:feed_id], 
      starred: params[:starred],
      unread: params[:unread]),
      notice: "All items on current page have been marked as read."
  
  end
  
  private
  def set_article
    @article = Article.find(params.expect(:id))
  end

  def article_params
    params.expect(article: [ :feed_id, :title, :description, :url, :published, :read, :starred, :filtered ])
  end
end

