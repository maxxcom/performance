class SimpleActionAssignmentsController < ApplicationController
  before_action :set_simple_action_assignment, only: [:show, :edit, :update, :destroy]

  # GET /simple_action_assignments
  # GET /simple_action_assignments.json
  def index
    @simple_action_assignments = SimpleActionAssignment.all
  end

  # GET /simple_action_assignments/1
  # GET /simple_action_assignments/1.json
  def show
  end

  # GET /simple_action_assignments/new
  def new
    @simple_action_assignment = SimpleActionAssignment.new
  end

  # GET /simple_action_assignments/1/edit
  def edit
  end

  # POST /simple_action_assignments
  # POST /simple_action_assignments.json
  def create
    @simple_action_assignment = SimpleActionAssignment.new(simple_action_assignment_params)

    respond_to do |format|
      if @simple_action_assignment.save
        format.html { redirect_to @simple_action_assignment, notice: 'Simple action assignment was successfully created.' }
        format.json { render :show, status: :created, location: @simple_action_assignment }
      else
        format.html { render :new }
        format.json { render json: @simple_action_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_action_assignments/1
  # PATCH/PUT /simple_action_assignments/1.json
  def update
    respond_to do |format|
      if @simple_action_assignment.update(simple_action_assignment_params)
        format.html { redirect_to @simple_action_assignment, notice: 'Simple action assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @simple_action_assignment }
      else
        format.html { render :edit }
        format.json { render json: @simple_action_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_action_assignments/1
  # DELETE /simple_action_assignments/1.json
  def destroy
    @simple_action_assignment.destroy
    respond_to do |format|
      format.html { redirect_to simple_action_assignments_url, notice: 'Simple action assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simple_action_assignment
      @simple_action_assignment = SimpleActionAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def simple_action_assignment_params
      params.require(:simple_action_assignment).permit(:person_id, :simple_action_id, :wheight)
    end
end
