class SimpleActionsController < ApplicationController
  before_action :set_simple_action, only: [:show, :edit, :update, :destroy]

  # GET /simple_actions
  # GET /simple_actions.json
  def index
    @simple_actions = SimpleAction.all
  end
  
  def indexfiltro
    if params[:simple_action] != nil
     @stringa_ricerca = params[:simple_action][:stringa]
	 @simple_actions = SimpleAction.left_joins(:responsabile_principale).where("lower(simple_actions.denominazione) LIKE lower(?) OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	else
     @simple_actions = SimpleAction.all
	 @stringa_ricerca = ""
	end
  end

  # GET /simple_actions/1
  # GET /simple_actions/1.json
  def show
  end

  # GET /simple_actions/new
  def new
    @simple_action = SimpleAction.new
  end

  # GET /simple_actions/1/edit
  def edit
  end

  # POST /simple_actions
  # POST /simple_actions.json
  def create
    @simple_action = SimpleAction.new(simple_action_params)

    respond_to do |format|
      if @simple_action.save
        format.html { redirect_to @simple_action, notice: 'Simple action was successfully created.' }
        format.json { render :show, status: :created, location: @simple_action }
      else
        format.html { render :new }
        format.json { render json: @simple_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_actions/1
  # PATCH/PUT /simple_actions/1.json
  def update
    respond_to do |format|
      if @simple_action.update(simple_action_params)
        format.html { redirect_to @simple_action, notice: 'Simple action was successfully updated.' }
        format.json { render :show, status: :ok, location: @simple_action }
      else
        format.html { render :edit }
        format.json { render json: @simple_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_actions/1
  # DELETE /simple_actions/1.json
  def destroy
    @simple_action.destroy
    respond_to do |format|
      format.html { redirect_to indexfiltro_simple_actions_path, notice: 'Simple action was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simple_action
      @simple_action = SimpleAction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def simple_action_params
      params.require(:simple_action).permit(:denominazione, :descrizione, :responsabile_principale_id, :peso, :anno, :ente, :fase_id)
    end
end
