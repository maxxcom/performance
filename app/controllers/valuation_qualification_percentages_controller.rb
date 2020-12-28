class ValuationQualificationPercentagesController < ApplicationController
  before_action :set_valuation_qualification_percentage, only: [:show, :edit, :update, :destroy]

  # GET /valuation_qualification_percentages
  # GET /valuation_qualification_percentages.json
  def index
    @valuation_qualification_percentages = ValuationQualificationPercentage.all
  end

  # GET /valuation_qualification_percentages/1
  # GET /valuation_qualification_percentages/1.json
  def show
  end

  # GET /valuation_qualification_percentages/new
  def new
    @valuation_qualification_percentage = ValuationQualificationPercentage.new
  end

  # GET /valuation_qualification_percentages/1/edit
  def edit
  end

  # POST /valuation_qualification_percentages
  # POST /valuation_qualification_percentages.json
  def create
    @valuation_qualification_percentage = ValuationQualificationPercentage.new(valuation_qualification_percentage_params)

    respond_to do |format|
      if @valuation_qualification_percentage.save
        format.html { redirect_to @valuation_qualification_percentage, notice: 'Valuation qualification percentage was successfully created.' }
        format.json { render :show, status: :created, location: @valuation_qualification_percentage }
      else
        format.html { render :new }
        format.json { render json: @valuation_qualification_percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /valuation_qualification_percentages/1
  # PATCH/PUT /valuation_qualification_percentages/1.json
  def update
    respond_to do |format|
      if @valuation_qualification_percentage.update(valuation_qualification_percentage_params)
        format.html { redirect_to @valuation_qualification_percentage, notice: 'Valuation qualification percentage was successfully updated.' }
        format.json { render :show, status: :ok, location: @valuation_qualification_percentage }
      else
        format.html { render :edit }
        format.json { render json: @valuation_qualification_percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /valuation_qualification_percentages/1
  # DELETE /valuation_qualification_percentages/1.json
  def destroy
    @valuation_qualification_percentage.destroy
    respond_to do |format|
      format.html { redirect_to valuation_qualification_percentages_url, notice: 'Valuation qualification percentage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_valuation_qualification_percentage
      @valuation_qualification_percentage = ValuationQualificationPercentage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def valuation_qualification_percentage_params
      params.require(:valuation_qualification_percentage).permit(:valuation_area_id, :qualification_type_id, :percentuale, :category_id)
    end
end
