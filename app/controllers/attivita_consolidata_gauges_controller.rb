class AttivitaConsolidataGaugesController < ApplicationController
  before_action :set_attivita_consolidata_gauge, only: [:show, :edit, :update, :destroy]

  # GET /attivita_consolidata_gauges
  # GET /attivita_consolidata_gauges.json
  def index
    @attivita_consolidata_gauges = AttivitaConsolidataGauge.all
  end

  # GET /attivita_consolidata_gauges/1
  # GET /attivita_consolidata_gauges/1.json
  def show
  end

  # GET /attivita_consolidata_gauges/new
  def new
    @attivita_consolidata_gauge = AttivitaConsolidataGauge.new
  end

  # GET /attivita_consolidata_gauges/1/edit
  def edit
  end

  # POST /attivita_consolidata_gauges
  # POST /attivita_consolidata_gauges.json
  def create
    @attivita_consolidata_gauge = AttivitaConsolidataGauge.new(attivita_consolidata_gauge_params)

    respond_to do |format|
      if @attivita_consolidata_gauge.save
        format.html { redirect_to @attivita_consolidata_gauge, notice: 'Attivita consolidata gauge was successfully created.' }
        format.json { render :show, status: :created, location: @attivita_consolidata_gauge }
      else
        format.html { render :new }
        format.json { render json: @attivita_consolidata_gauge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attivita_consolidata_gauges/1
  # PATCH/PUT /attivita_consolidata_gauges/1.json
  def update
    respond_to do |format|
      if @attivita_consolidata_gauge.update(attivita_consolidata_gauge_params)
        format.html { redirect_to @attivita_consolidata_gauge, notice: 'Attivita consolidata gauge was successfully updated.' }
        format.json { render :show, status: :ok, location: @attivita_consolidata_gauge }
      else
        format.html { render :edit }
        format.json { render json: @attivita_consolidata_gauge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attivita_consolidata_gauges/1
  # DELETE /attivita_consolidata_gauges/1.json
  def destroy
    @attivita_consolidata_gauge.destroy
    respond_to do |format|
      format.html { redirect_to attivita_consolidata_gauges_url, notice: 'Attivita consolidata gauge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attivita_consolidata_gauge
      @attivita_consolidata_gauge = AttivitaConsolidataGauge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attivita_consolidata_gauge_params
      params.require(:attivita_consolidata_gauge).permit(:ufficio_stringa, :linea_di_attivita, :indicatore_di_quantita, :consuntivo_anno_n_meno_3, :consuntivo_anno_n_meno_2, :consuntivo_anno_n_meno_1, :previsionale_anno_n, :previsionale_anno_n_piu_1, :previsionale_anno_n_piu_2, :previsionale_anno_n_piu_3, :obiettivo_di_performance, :note, :foglio_di_lavoro)
    end
end
