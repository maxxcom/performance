class StrategicGoalsController < ApplicationController
  before_action :set_strategic_goal, only: [:show, :edit, :update, :destroy]

  # GET /strategic_goals
  # GET /strategic_goals.json
  def index
    @strategic_goals = StrategicGoal.all
  end

  # GET /strategic_goals/1
  # GET /strategic_goals/1.json
  def show
  end

  # GET /strategic_goals/new
  def new
    @strategic_goal = StrategicGoal.new
  end

  # GET /strategic_goals/1/edit
  def edit
  end

  # POST /strategic_goals
  # POST /strategic_goals.json
  def create
    @strategic_goal = StrategicGoal.new(strategic_goal_params)

    respond_to do |format|
      if @strategic_goal.save
        format.html { redirect_to @strategic_goal, notice: 'Strategic goal was successfully created.' }
        format.json { render :show, status: :created, location: @strategic_goal }
      else
        format.html { render :new }
        format.json { render json: @strategic_goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /strategic_goals/1
  # PATCH/PUT /strategic_goals/1.json
  def update
    respond_to do |format|
      if @strategic_goal.update(strategic_goal_params)
        format.html { redirect_to @strategic_goal, notice: 'Strategic goal was successfully updated.' }
        format.json { render :show, status: :ok, location: @strategic_goal }
      else
        format.html { render :edit }
        format.json { render json: @strategic_goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /strategic_goals/1
  # DELETE /strategic_goals/1.json
  def destroy
    @strategic_goal.destroy
    respond_to do |format|
      format.html { redirect_to strategic_goals_url, notice: 'Strategic goal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def manage_strategic_goal
    @strategic_goal = StrategicGoal.find(params[:format])
    # respond_to do |format|
	   # format.js   { }
    # end
  end
  
  
  def add_operational_goal
    puts "Vediamo i parametri add_operational_goal"
	puts params
	@strategic_goal = StrategicGoal.find(params[:strategic_goal_id])
	@operational_goal = OperationalGoal.find(params[:strategic_goal][:id])
	@operational_goal.obiettivo_strategico_padre = @strategic_goal
	@operational_goal.save
    respond_to do |format|
	   format.js    {render :action => "manage_strategic_goal" }
	end
  end
  
  def remove_operational_goal
    puts "Vediamo i parametri remove_operational_goal"
	puts params
	@operational_goal = OperationalGoal.find(params[:strategic_goal][:operational_goal_id])
	@operational_goal.obiettivo_strategico_padre =  nil
	@operational_goal.save
	@strategic_goal = StrategicGoal.find(params[:strategic_goal_id])
    respond_to do |format|
	   format.js    {render :action => "manage_strategic_goal" }
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_strategic_goal
      @strategic_goal = StrategicGoal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def strategic_goal_params
      params.require(:strategic_goal).permit(:denominazione, :descrizione, :anno, :ente)
    end
end
