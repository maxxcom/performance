class OperaAssignmentsController < ApplicationController
  before_action :set_opera_assignment, only: [:show, :edit, :update, :destroy]

  # GET /opera_assignments
  # GET /opera_assignments.json
  def index
    @opera_assignments = OperaAssignment.all
  end

  # GET /opera_assignments/1
  # GET /opera_assignments/1.json
  def show
  end

  # GET /opera_assignments/new
  def new
    @opera_assignment = OperaAssignment.new
  end

  # GET /opera_assignments/1/edit
  def edit
  end

  # POST /opera_assignments
  # POST /opera_assignments.json
  def create
    @opera_assignment = OperaAssignment.new(opera_assignment_params)

    respond_to do |format|
      if @opera_assignment.save
        format.html { redirect_to @opera_assignment, notice: 'Opera assignment was successfully created.' }
        format.json { render :show, status: :created, location: @opera_assignment }
      else
        format.html { render :new }
        format.json { render json: @opera_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /opera_assignments/1
  # PATCH/PUT /opera_assignments/1.json
  def update
    respond_to do |format|
      if @opera_assignment.update(opera_assignment_params)
        format.html { redirect_to @opera_assignment, notice: 'Opera assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @opera_assignment }
      else
        format.html { render :edit }
        format.json { render json: @opera_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /opera_assignments/1
  # DELETE /opera_assignments/1.json
  def destroy
    @opera_assignment.destroy
    respond_to do |format|
      format.html { redirect_to opera_assignments_url, notice: 'Opera assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_opera_assignment
      @opera_assignment = OperaAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def opera_assignment_params
      params.require(:opera_assignment).permit(:person_id, :opera_id, :wheight)
    end
end
