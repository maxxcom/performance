class OfficeTargetCollaborationsController < ApplicationController
  before_action :set_office_target_collaboration, only: [:show, :edit, :update, :destroy]

  # GET /office_target_collaborations
  # GET /office_target_collaborations.json
  def index
    @office_target_collaborations = OfficeTargetCollaboration.all
  end

  # GET /office_target_collaborations/1
  # GET /office_target_collaborations/1.json
  def show
  end

  # GET /office_target_collaborations/new
  def new
    @office_target_collaboration = OfficeTargetCollaboration.new
  end

  # GET /office_target_collaborations/1/edit
  def edit
  end

  # POST /office_target_collaborations
  # POST /office_target_collaborations.json
  def create
    @office_target_collaboration = OfficeTargetCollaboration.new(office_target_collaboration_params)

    respond_to do |format|
      if @office_target_collaboration.save
        format.html { redirect_to @office_target_collaboration, notice: 'Office target collaboration was successfully created.' }
        format.json { render :show, status: :created, location: @office_target_collaboration }
      else
        format.html { render :new }
        format.json { render json: @office_target_collaboration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /office_target_collaborations/1
  # PATCH/PUT /office_target_collaborations/1.json
  def update
    respond_to do |format|
      if @office_target_collaboration.update(office_target_collaboration_params)
        format.html { redirect_to @office_target_collaboration, notice: 'Office target collaboration was successfully updated.' }
        format.json { render :show, status: :ok, location: @office_target_collaboration }
      else
        format.html { render :edit }
        format.json { render json: @office_target_collaboration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /office_target_collaborations/1
  # DELETE /office_target_collaborations/1.json
  def destroy
    @office_target_collaboration.destroy
    respond_to do |format|
      format.html { redirect_to office_target_collaborations_url, notice: 'Office target collaboration was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office_target_collaboration
      @office_target_collaboration = OfficeTargetCollaboration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_target_collaboration_params
      params.require(:office_target_collaboration).permit(:target_id, :target_type, :office_id)
    end
end
