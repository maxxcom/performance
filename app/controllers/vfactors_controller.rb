class VfactorsController < ApplicationController
  before_action :set_vfactor, only: [:show, :edit, :update, :destroy]

  # GET /vfactors
  # GET /vfactors.json
  def index
    @vfactors = Vfactor.all.order(ordine_apparizione: :asc)
  end

  # GET /vfactors/1
  # GET /vfactors/1.json
  def show
  end

  # GET /vfactors/new
  def new
    @vfactor = Vfactor.new
  end

  # GET /vfactors/1/edit
  def edit
  end

  # POST /vfactors
  # POST /vfactors.json
  def create
    @vfactor = Vfactor.new(vfactor_params)

    respond_to do |format|
      if @vfactor.save
        format.html { redirect_to @vfactor, notice: 'Vfactor was successfully created.' }
        format.json { render :show, status: :created, location: @vfactor }
      else
        format.html { render :new }
        format.json { render json: @vfactor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vfactors/1
  # PATCH/PUT /vfactors/1.json
  def update
    respond_to do |format|
      if @vfactor.update(vfactor_params)
        format.html { redirect_to @vfactor, notice: 'Vfactor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vfactor }
      else
        format.html { render :edit }
        format.json { render json: @vfactor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vfactors/1
  # DELETE /vfactors/1.json
  def destroy
    @vfactor.destroy
    respond_to do |format|
      format.html { redirect_to vfactors_url, notice: 'Vfactor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vfactor
      @vfactor = Vfactor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vfactor_params
      params.require(:vfactor).permit(:denominazione, :descrizione, :ordine_apparizione, :peso_sg, :peso_dirigenti, :peso_po, :peso_preposti, :peso_nonpreposti, :min, :max)
    end
end
