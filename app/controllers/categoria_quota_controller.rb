class CategoriaQuotaController < ApplicationController
  before_action :set_categoria_quotum, only: [:show, :edit, :update, :destroy]

  # GET /categoria_quota
  # GET /categoria_quota.json
  def index
    @categoria_quota = CategoriaQuotum.all
  end

  # GET /categoria_quota/1
  # GET /categoria_quota/1.json
  def show
  end

  # GET /categoria_quota/new
  def new
    @categoria_quotum = CategoriaQuotum.new
  end

  # GET /categoria_quota/1/edit
  def edit
  end

  # POST /categoria_quota
  # POST /categoria_quota.json
  def create
    @categoria_quotum = CategoriaQuotum.new(categoria_quotum_params)

    respond_to do |format|
      if @categoria_quotum.save
        format.html { redirect_to @categoria_quotum, notice: 'Categoria quotum was successfully created.' }
        format.json { render :show, status: :created, location: @categoria_quotum }
      else
        format.html { render :new }
        format.json { render json: @categoria_quotum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categoria_quota/1
  # PATCH/PUT /categoria_quota/1.json
  def update
    respond_to do |format|
      if @categoria_quotum.update(categoria_quotum_params)
        format.html { redirect_to @categoria_quotum, notice: 'Categoria quotum was successfully updated.' }
        format.json { render :show, status: :ok, location: @categoria_quotum }
      else
        format.html { render :edit }
        format.json { render json: @categoria_quotum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categoria_quota/1
  # DELETE /categoria_quota/1.json
  def destroy
    @categoria_quotum.destroy
    respond_to do |format|
      format.html { redirect_to categoria_quota_url, notice: 'Categoria quotum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categoria_quotum
      @categoria_quotum = CategoriaQuotum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categoria_quotum_params
      params.require(:categoria_quotum).permit(:chiave, :quota_comportamento, :quota_obiettivi)
    end
end
