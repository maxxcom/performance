class TargetDipendenteEvaluationsController < ApplicationController
  before_action :set_target_dipendente_evaluation, only: [:show, :edit, :update, :destroy]

  # GET /target_dipendente_evaluations
  # GET /target_dipendente_evaluations.json
  def index
    @target_dipendente_evaluations = TargetDipendenteEvaluation.all
  end

  # GET /target_dipendente_evaluations/1
  # GET /target_dipendente_evaluations/1.json
  def show
  end

  # GET /target_dipendente_evaluations/new
  def new
    @target_dipendente_evaluation = TargetDipendenteEvaluation.new
  end

  # GET /target_dipendente_evaluations/1/edit
  def edit
  end

  # POST /target_dipendente_evaluations
  # POST /target_dipendente_evaluations.json
  def create
    @target_dipendente_evaluation = TargetDipendenteEvaluation.new(target_dipendente_evaluation_params)

    respond_to do |format|
      if @target_dipendente_evaluation.save
        format.html { redirect_to @target_dipendente_evaluation, notice: 'Target dipendente evaluation was successfully created.' }
        format.json { render :show, status: :created, location: @target_dipendente_evaluation }
      else
        format.html { render :new }
        format.json { render json: @target_dipendente_evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /target_dipendente_evaluations/1
  # PATCH/PUT /target_dipendente_evaluations/1.json
  def update
    respond_to do |format|
      if @target_dipendente_evaluation.update(target_dipendente_evaluation_params)
        format.html { redirect_to @target_dipendente_evaluation, notice: 'Target dipendente evaluation was successfully updated.' }
        format.json { render :show, status: :ok, location: @target_dipendente_evaluation }
      else
        format.html { render :edit }
        format.json { render json: @target_dipendente_evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /target_dipendente_evaluations/1
  # DELETE /target_dipendente_evaluations/1.json
  def destroy
    @target_dipendente_evaluation.destroy
    respond_to do |format|
      format.html { redirect_to target_dipendente_evaluations_url, notice: 'Target dipendente evaluation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_dipendente_evaluation
      @target_dipendente_evaluation = TargetDipendenteEvaluation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_dipendente_evaluation_params
      params.require(:target_dipendente_evaluation).permit(:target_id, :target_type, :person_id, :dirigente_id, :valore)
    end
end
