class FiltersController < ApplicationController
  before_action :set_filter, only: %i[ show edit update destroy ]

  # GET /filters or /filters.json
  def index
    @filters = Filter.all
  end

  # GET /filters/1 or /filters/1.json
  def show
    # Get all articles that have been filtered out
    @filtered_articles = @filter.articles.order(published: :desc,id: :desc)
  end

  # GET /filters/new
  def new
    @filter = Filter.new
  end

  # GET /filters/1/edit
  def edit
  end

  # POST /filters or /filters.json
  def create
    @filter = Filter.new(filter_params)

    respond_to do |format|
      if @filter.save
        format.html { redirect_to @filter, notice: "Filter was successfully created." }
        format.json { render :show, status: :created, location: @filter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /filters/1 or /filters/1.json
  def update
    respond_to do |format|
      if @filter.update(filter_params)
        format.html { redirect_to @filter, notice: "Filter was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @filter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @filter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /filters/1 or /filters/1.json
  def destroy
    @filter.destroy!

    respond_to do |format|
      format.html { redirect_to filters_path, notice: "Filter was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_filter
      @filter = Filter.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def filter_params
      params.expect(filter: [ :term, :title, :description ])
    end
end
