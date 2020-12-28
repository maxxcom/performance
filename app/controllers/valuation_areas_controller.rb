class ValuationAreasController < ApplicationController
  before_action :set_valuation_area, only: [:show, :edit, :update, :destroy]

  # GET /valuation_areas
  # GET /valuation_areas.json
  def index
    @valuation_areas = ValuationArea.all
  end

  # GET /valuation_areas/1
  # GET /valuation_areas/1.json
  def show
  end

  # GET /valuation_areas/new
  def new
    @valuation_area = ValuationArea.new
  end

  # GET /valuation_areas/1/edit
  def edit
  end

  # POST /valuation_areas
  # POST /valuation_areas.json
  def create
    @valuation_area = ValuationArea.new(valuation_area_params)

    respond_to do |format|
      if @valuation_area.save
        format.html { redirect_to @valuation_area, notice: 'Valuation area was successfully created.' }
        format.json { render :show, status: :created, location: @valuation_area }
      else
        format.html { render :new }
        format.json { render json: @valuation_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /valuation_areas/1
  # PATCH/PUT /valuation_areas/1.json
  def update
    respond_to do |format|
      if @valuation_area.update(valuation_area_params)
        format.html { redirect_to @valuation_area, notice: 'Valuation area was successfully updated.' }
        format.json { render :show, status: :ok, location: @valuation_area }
      else
        format.html { render :edit }
        format.json { render json: @valuation_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /valuation_areas/1
  # DELETE /valuation_areas/1.json
  def destroy
    @valuation_area.destroy
    respond_to do |format|
      format.html { redirect_to valuation_areas_url, notice: 'Valuation area was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_valuation_area
      @valuation_area = ValuationArea.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def valuation_area_params
      params.require(:valuation_area).permit(:denominazione, :descrizione)
    end
end
