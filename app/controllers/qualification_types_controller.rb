class QualificationTypesController < ApplicationController
  before_action :set_qualification_type, only: [:show, :edit, :update, :destroy]

  # GET /qualification_types
  # GET /qualification_types.json
  def index
    @qualification_types = QualificationType.all
  end

  # GET /qualification_types/1
  # GET /qualification_types/1.json
  def show
  end

  # GET /qualification_types/new
  def new
    @qualification_type = QualificationType.new
  end

  # GET /qualification_types/1/edit
  def edit
  end

  # POST /qualification_types
  # POST /qualification_types.json
  def create
    @qualification_type = QualificationType.new(qualification_type_params)

    respond_to do |format|
      if @qualification_type.save
        format.html { redirect_to @qualification_type, notice: 'Qualification type was successfully created.' }
        format.json { render :show, status: :created, location: @qualification_type }
      else
        format.html { render :new }
        format.json { render json: @qualification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /qualification_types/1
  # PATCH/PUT /qualification_types/1.json
  def update
    respond_to do |format|
      if @qualification_type.update(qualification_type_params)
        format.html { redirect_to @qualification_type, notice: 'Qualification type was successfully updated.' }
        format.json { render :show, status: :ok, location: @qualification_type }
      else
        format.html { render :edit }
        format.json { render json: @qualification_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /qualification_types/1
  # DELETE /qualification_types/1.json
  def destroy
    @qualification_type.destroy
    respond_to do |format|
      format.html { redirect_to qualification_types_url, notice: 'Qualification type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_qualification_type
      @qualification_type = QualificationType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def qualification_type_params
      params.require(:qualification_type).permit(:denominazione)
    end
end
