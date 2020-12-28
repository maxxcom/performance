class ValutationsController < ApplicationController
  before_action :set_valutation, only: [:show, :edit, :update, :destroy]

  # GET /valutations
  # GET /valutations.json
  def index
    @valutations = Valutation.all
  end

  # GET /valutations/1
  # GET /valutations/1.json
  def show
  end

  # GET /valutations/new
  def new
    @valutation = Valutation.new
  end

  # GET /valutations/1/edit
  def edit
  end

  # POST /valutations
  # POST /valutations.json
  def create
    @valutation = Valutation.new(valutation_params)

    respond_to do |format|
      if @valutation.save
        format.html { redirect_to @valutation, notice: 'Valutation was successfully created.' }
        format.json { render :show, status: :created, location: @valutation }
      else
        format.html { render :new }
        format.json { render json: @valutation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /valutations/1
  # PATCH/PUT /valutations/1.json
  def update
    respond_to do |format|
      if @valutation.update(valutation_params)
        format.html { redirect_to @valutation, notice: 'Valutation was successfully updated.' }
        format.json { render :show, status: :ok, location: @valutation }
      else
        format.html { render :edit }
        format.json { render json: @valutation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /valutations/1
  # DELETE /valutations/1.json
  def destroy
    @valutation.destroy
    respond_to do |format|
      format.html { redirect_to valutations_url, notice: 'Valutation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_valutation
      @valutation = Valutation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def valutation_params
      params.require(:valutation).permit(:value, :year, :state, :person_id, :vfator_id)
    end
end
