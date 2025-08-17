class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    
    # Utilizes kaminari pagination, config @ config/initializers/kaminariconfig.rb
    # Grab only the articles not explicitly filtered, include the feed to avoid N+1 queries,
    # sort newest first by published date and ID, then paginate

    @articles = Article.includes(:feed)
                       .where(filtered: false)
                       .order(published: :desc, id: :desc)
                       .page(params[:page])
  
    
    
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



private
  def set_article
    @article = Article.find(params.expect(:id))
  end

  def article_params
    params.expect(article: [ :feed_id, :title, :description, :url, :published, :read, :starred, :filtered ])
  end
end

