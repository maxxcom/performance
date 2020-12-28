class SdopeRowsController < ApplicationController
  before_action :set_sdope_row, only: [:show, :edit, :update, :destroy]

  # GET /sdope_rows
  # GET /sdope_rows.json
  def index
    @sdope_rows = SdopeRow.all
  end

  # GET /sdope_rows/1
  # GET /sdope_rows/1.json
  def show
  end

  # GET /sdope_rows/new
  def new
    @sdope_row = SdopeRow.new
  end

  # GET /sdope_rows/1/edit
  def edit
  end

  # POST /sdope_rows
  # POST /sdope_rows.json
  def create
    @sdope_row = SdopeRow.new(sdope_row_params)

    respond_to do |format|
      if @sdope_row.save
        format.html { redirect_to @sdope_row, notice: 'Sdope row was successfully created.' }
        format.json { render :show, status: :created, location: @sdope_row }
      else
        format.html { render :new }
        format.json { render json: @sdope_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sdope_rows/1
  # PATCH/PUT /sdope_rows/1.json
  def update
    respond_to do |format|
      if @sdope_row.update(sdope_row_params)
        format.html { redirect_to @sdope_row, notice: 'Sdope row was successfully updated.' }
        format.json { render :show, status: :ok, location: @sdope_row }
      else
        format.html { render :edit }
        format.json { render json: @sdope_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sdope_rows/1
  # DELETE /sdope_rows/1.json
  def destroy
    @sdope_row.destroy
    respond_to do |format|
      format.html { redirect_to sdope_rows_url, notice: 'Sdope row was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def importcsv
  
  end
  
  def importazionecsv
    filename = params[:file].original_filename
	SdopeRow.import(params[:file]) #pure viene lanciato il metodo del model
    @sdope_rows = SdopeRow.all #ora va in un index con valorizzato quello che ha importato
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sdope_row
      @sdope_row = SdopeRow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sdope_row_params
      params.require(:sdope_row).permit(:matricola, :nominativo, :livello, :figuracod, :figurades, :ruolo, :titolo1, :titolo2, :titolo3, :titolo4)
    end
end
