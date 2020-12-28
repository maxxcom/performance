class FtePercentagesController < ApplicationController
  before_action :set_fte_percentage, only: [:show, :edit, :update, :destroy], except: [:aggiungi_fte_percentage]

  # GET /fte_percentages
  # GET /fte_percentages.json
  def index
    @fte_percentages = FtePercentage.all
  end

  # GET /fte_percentages/1
  # GET /fte_percentages/1.json
  def show
  end

  # GET /fte_percentages/new
  def new
    @fte_percentage = FtePercentage.new
  end

  # GET /fte_percentages/1/edit
  def edit
  end

  # POST /fte_percentages
  # POST /fte_percentages.json
  def create
    @fte_percentage = FtePercentage.new(fte_percentage_params)

    respond_to do |format|
      if @fte_percentage.save
        format.html { redirect_to @fte_percentage, notice: 'Fte percentage was successfully created.' }
        format.json { render :show, status: :created, location: @fte_percentage }
      else
        format.html { render :new }
        format.json { render json: @fte_percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fte_percentages/1
  # PATCH/PUT /fte_percentages/1.json
  def update
    respond_to do |format|
      if @fte_percentage.update(fte_percentage_params)
        format.html { redirect_to @fte_percentage, notice: 'Fte percentage was successfully updated.' }
        format.json { render :show, status: :ok, location: @fte_percentage }
      else
        format.html { render :edit }
        format.json { render json: @fte_percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fte_percentages/1
  # DELETE /fte_percentages/1.json
  def destroy
    @fte_percentage.destroy
    respond_to do |format|
      format.html { redirect_to fte_percentages_url, notice: 'Fte percentage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def aggiungi_fte_percentage
    puts "aggiungi_fte_percentage"
    puts params
	category_id = params[:category_id][:id]
	percentuale = params[:percentuale]
	
	c = Category.find(category_id)
	
	@fte_percentage = FtePercentage.where(category_id: category_id).first
	if @fte_percentage == nil 
      @fte_percentage = FtePercentage.new	
	  @fte_percentage.category = c
	  @fte_percentage.percentuale = percentuale.to_f
	  @fte_percentage.save
	else
	  @fte_percentage.percentuale = percentuale.to_f
	  @fte_percentage.save
	end
	
	render index
		
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fte_percentage
	  puts "set_fte_percentage"
	  if params[:id].length > 0
       @fte_percentage = FtePercentage.find(params[:id])
	  end
	  
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fte_percentage_params
      params.require(:fte_percentage).permit(:category_id, :percentuale)
    end
end
