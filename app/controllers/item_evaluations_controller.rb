class ItemEvaluationsController < ApplicationController
  before_action :set_item_evaluation, only: [:show, :edit, :update, :destroy]

  # GET /item_evaluations
  # GET /item_evaluations.json
  def index
    @item_evaluations = ItemEvaluation.all
  end

  # GET /item_evaluations/1
  # GET /item_evaluations/1.json
  def show
  end

  # GET /item_evaluations/new
  def new
    @item_evaluation = ItemEvaluation.new
  end

  # GET /item_evaluations/1/edit
  def edit
  end

  # POST /item_evaluations
  # POST /item_evaluations.json
  def create
    @item_evaluation = ItemEvaluation.new(item_evaluation_params)

    respond_to do |format|
      if @item_evaluation.save
        format.html { redirect_to @item_evaluation, notice: 'Item evaluation was successfully created.' }
        format.json { render :show, status: :created, location: @item_evaluation }
      else
        format.html { render :new }
        format.json { render json: @item_evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /item_evaluations/1
  # PATCH/PUT /item_evaluations/1.json
  def update
    respond_to do |format|
      if @item_evaluation.update(item_evaluation_params)
        format.html { redirect_to @item_evaluation, notice: 'Item evaluation was successfully updated.' }
        format.json { render :show, status: :ok, location: @item_evaluation }
      else
        format.html { render :edit }
        format.json { render json: @item_evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_evaluations/1
  # DELETE /item_evaluations/1.json
  def destroy
    @item_evaluation.destroy
    respond_to do |format|
      format.html { redirect_to item_evaluations_url, notice: 'Item evaluation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def valutazioniobiettivixdirigente
    @dirigenti = []
    @dirigenti = Person.dirigenti
  end
  
  def searchevaluationsxdirigente
    puts params
    @dirigente = Person.find(params[:person][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	
	# Se non ci sono vengono creati tutti i record per le valutazioni
	@obiettivi.each do |obiettivo|
	   if obiettivo.valutazione == nil
	     new_ev = ItemEvaluation.new;
		 new_ev.valore_valutazione_oiv = obiettivo.valore_totale
		 obiettivo.valutazione = new_ev
		 obiettivo.save
	   end
	   
	end
	
	respond_to do |format|
	   format.js   { }
    end
  end
  
  def set_valore_valutazione_oiv
    puts params
	@dirigente = Person.find(params[:item_evaluation][:dirigente_id])
	valore = params[:item_evaluation][:value]
	obiettivo =	OperationalGoal.find(params[:item_evaluation][:obiettivo_id])
	val = obiettivo.valutazione
	val.valore_valutazione_oiv = valore
	val.save
	
	respond_to do |format|
	    format.js   { render :action => "searchevaluationsxdirigente"  }
    end
	
  end
  
  def valutazionitargetxdirigente
    @dirigenti = []
    @dirigenti = Person.dirigenti
  end
  
  def searchvalutazionidirigentexdirigente
    puts params
    @dirigente = Person.find(params[:person][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	
	# Se non ci sono vengono creati tutti i record per le valutazioni
	# e gli mette per defaults il valore che ha il target (la misurazione)
	@obiettivi.each do |obiettivo|
	   
	   if (obiettivo.valutazione == nil) && (obiettivo.assegnatari.length > 0)
	     new_ev = ItemEvaluation.new;
		 new_ev.valore_valutazione_dirigente = obiettivo.valore_totale
		 new_ev.save
		 obiettivo.valutazione = new_ev
		 obiettivo.save
	   end
	   
	   obiettivo.fasi.each do |fase|
	     if (fase.valutazione == nil) && (fase.assegnatari.length > 0)
	       new_ev = ItemEvaluation.new;
		   new_ev.valore_valutazione_dirigente = fase.valore_totale
		   new_ev.save
		   fase.valutazione = new_ev
		   fase.save
	     end
		 
		 fase.azioni.each do |azione|
		    if (azione.valutazione == nil) && (azione.assegnatari.length > 0)
	          new_ev = ItemEvaluation.new;
		      new_ev.valore_valutazione_dirigente = azione.valore_totale
			  new_ev.save
		      azione.valutazione = new_ev
		      azione.save
			end
	     end
		 
		 
	   end
	   
	end
	
	respond_to do |format|
	   format.js   { render :action => "searchvalutazionidirigentexdirigente" }
    end
  end
  
  def set_valore_valutazione_dirigente
    puts "set_valore_valutazione_dirigente"
    puts params
	@dirigente = Person.find(params[:item_evaluation][:dirigente_id])
	
	valore = params[:item_evaluation][:value]
	val = ItemEvaluation.find(params[:item_evaluation][:item_evaluation_id])
	
	val.valore_valutazione_dirigente = valore
	val.save
	
	# questo controllo non serve e allora si decommenta quello sopra
	
	tipo = params[:item_evaluation][:tipo]
	
	# case tipo
    # when "Obiettivo"
      # o = OperationalGoal.find(params[:item_evaluation][:obiettivo_id])
	  # if o.valutazione.id == val.id
	    
	    # val.valore_valutazione_dirigente = valore
	    # val.save 
	  # end
    # when "Fase"
      # f = Phase.find(params[:item_evaluation][:fase_id])
	  # if f.valutazione.id == val.id
	    # val.valore_valutazione_dirigente = valore
	    # val.save 
	  # end
    # when "Azione"
      # a = Phase.find(params[:item_evaluation][:azione_id])
	  # if a.valutazione.id == val.id
	    # val.valore_valutazione_dirigente = valore
	    # val.save 
	  # end
	  
	# end
	
	
	
	respond_to do |format|
	    format.js   { render :action => "searchvalutazionidirigentexdirigente"  }
    end
	
  end
 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_evaluation
      @item_evaluation = ItemEvaluation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_evaluation_params
      params.require(:item_evaluation).permit(:valore_valutazione_dirigente, :valore_valutazione_oiv)
    end
end
