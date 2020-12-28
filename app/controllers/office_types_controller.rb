class OfficeTypesController < ApplicationController
  before_action :set_office_type, only: [:show, :edit, :update, :destroy]

  # GET /office_types
  # GET /office_types.json
  def index
    @office_types = OfficeType.all
  end

  # GET /office_types/1
  # GET /office_types/1.json
  def show
  end

  # GET /office_types/new
  def new
    @office_type = OfficeType.new
  end

  # GET /office_types/1/edit
  def edit
  end

  # POST /office_types
  # POST /office_types.json
  def create
    @office_type = OfficeType.new(office_type_params)

    respond_to do |format|
      if @office_type.save
        format.html { redirect_to @office_type, notice: 'Office type was successfully created.' }
        format.json { render :show, status: :created, location: @office_type }
      else
        format.html { render :new }
        format.json { render json: @office_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /office_types/1
  # PATCH/PUT /office_types/1.json
  def update
    respond_to do |format|
      if @office_type.update(office_type_params)
        format.html { redirect_to @office_type, notice: 'Office type was successfully updated.' }
        format.json { render :show, status: :ok, location: @office_type }
      else
        format.html { render :edit }
        format.json { render json: @office_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /office_types/1
  # DELETE /office_types/1.json
  def destroy
    @office_type.destroy
    respond_to do |format|
      format.html { redirect_to office_types_url, notice: 'Office type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office_type
      @office_type = OfficeType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_type_params
      params.require(:office_type).permit(:denominazione)
    end
end
