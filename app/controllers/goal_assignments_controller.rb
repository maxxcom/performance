class GoalAssignmentsController < ApplicationController
  before_action :set_goal_assignment, only: [:show, :edit, :update, :destroy]

  # GET /goal_assignments
  # GET /goal_assignments.json
  def index
    @goal_assignments = GoalAssignment.all
  end
  
  def assegnazioni
    @goal_assignments = GoalAssignment.all
  end

  # GET /goal_assignments/1
  # GET /goal_assignments/1.json
  def show
  end

  # GET /goal_assignments/new
  def new
    @goal_assignment = GoalAssignment.new
  end

  # GET /goal_assignments/1/edit
  def edit
  end

  # POST /goal_assignments
  # POST /goal_assignments.json
  def create
    @goal_assignment = GoalAssignment.new(goal_assignment_params)

    respond_to do |format|
      if @goal_assignment.save
        format.html { redirect_to @goal_assignment, notice: 'Goal assignment was successfully created.' }
        format.json { render :show, status: :created, location: @goal_assignment }
      else
        format.html { render :new }
        format.json { render json: @goal_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goal_assignments/1
  # PATCH/PUT /goal_assignments/1.json
  def update
    respond_to do |format|
      if @goal_assignment.update(goal_assignment_params)
        format.html { redirect_to @goal_assignment, notice: 'Goal assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @goal_assignment }
      else
        format.html { render :edit }
        format.json { render json: @goal_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goal_assignments/1
  # DELETE /goal_assignments/1.json
  def destroy
    @goal_assignment.destroy
    respond_to do |format|
      format.html { redirect_to goal_assignments_url, notice: 'Goal assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goal_assignment
      @goal_assignment = GoalAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def goal_assignment_params
      params.require(:goal_assignment).permit(:person_id, :operational_goal_id, :wheight)
    end
end
