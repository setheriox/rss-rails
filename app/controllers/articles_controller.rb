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

   @categories = ordered_categories_with_counts
   @total_unread = Article.where(read: false, filtered: false).count

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

  # AJAX endpoint to get updated sidebar counts
  def sidebar_counts
    categories = ordered_categories_with_counts
    total_unread = Article.where(read: false, filtered: false).count
    
    counts = {
      total_unread: total_unread,
      categories: categories.map do |category|
        {
          id: category.id,
          unread_count: category.unread_count,
          feeds: category.feeds.map do |feed|
            {
              id: feed.id,
              unread_count: feed.unread_count
            }
          end
        }
      end
    }
    
    render json: counts
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

  def ordered_categories_with_counts
    #########################################
    # Get All Categories and make sure
    # Uncategorized is at the end of the list
    ##########################################
    
    # Get all categories with their feeds and unread counts
    categories = Category.includes(feeds: :articles)
                        .order(name: :asc)

    # Calculate unread counts for each category and feed
    categories.each do |category|
      category.instance_variable_set(:@unread_count, 
        category.feeds.sum { |feed| feed.articles.where(read: false, filtered: false).count })
      
      category.feeds.each do |feed|
        feed.instance_variable_set(:@unread_count,
          feed.articles.where(read: false, filtered: false).count)
      end
    end

    # Create blank category list for a sorted list 
    category_list = []
    uncategorized = nil

    # Cycle through each category
    categories.each do |category|
      if category.name != "Uncategorized"
        category_list << category
      else
        uncategorized = category
      end
    end

    # Add Uncategorized to the end of the list (if it exists)
    category_list << uncategorized if uncategorized

    # Replace @categories with the reordered version
    category_list
  end

  def ordered_categories
    #########################################
    # Get All Categories and nake sure
    # Uncategorized is at the end of the list
    ##########################################
    categories = Category.left_joins(:feeds)
                          .select("categories.*, COUNT(feeds.id) AS feeds_count")
                          .group("categories.id")
                          .order(name: :asc)

    # Create blank category list for a sorted list 
    category_list = []
    uncategorized = nil

    # Cycle through each category
    categories.each do |category|
      if category.name != "Uncategorized"
        category_list << category
      else
        uncategorized = category
      end
    end

    # Add Uncategorized to the end of the list (if it exists)
    category_list << uncategorized if uncategorized

    # Replace @categories with the reordered version
    category_list
  end
end
