class PhaseAssignmentsController < ApplicationController
  before_action :set_phase_assignment, only: [:show, :edit, :update, :destroy]

  # GET /phase_assignments
  # GET /phase_assignments.json
  def index
    @phase_assignments = PhaseAssignment.all
  end

  # GET /phase_assignments/1
  # GET /phase_assignments/1.json
  def show
  end

  # GET /phase_assignments/new
  def new
    @phase_assignment = PhaseAssignment.new
  end

  # GET /phase_assignments/1/edit
  def edit
  end

  # POST /phase_assignments
  # POST /phase_assignments.json
  def create
    @phase_assignment = PhaseAssignment.new(phase_assignment_params)

    respond_to do |format|
      if @phase_assignment.save
        format.html { redirect_to @phase_assignment, notice: 'Phase assignment was successfully created.' }
        format.json { render :show, status: :created, location: @phase_assignment }
      else
        format.html { render :new }
        format.json { render json: @phase_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phase_assignments/1
  # PATCH/PUT /phase_assignments/1.json
  def update
    respond_to do |format|
      if @phase_assignment.update(phase_assignment_params)
        format.html { redirect_to @phase_assignment, notice: 'Phase assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @phase_assignment }
      else
        format.html { render :edit }
        format.json { render json: @phase_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phase_assignments/1
  # DELETE /phase_assignments/1.json
  def destroy
    @phase_assignment.destroy
    respond_to do |format|
      format.html { redirect_to phase_assignments_url, notice: 'Phase assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phase_assignment
      @phase_assignment = PhaseAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phase_assignment_params
      params.require(:phase_assignment).permit(:person_id, :phase_id, :wheight)
    end
end
