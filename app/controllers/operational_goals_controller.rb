class OperationalGoalsController < ApplicationController
  before_action :set_operational_goal, only: [:show, :edit, :update, :destroy]
  before_action :check_login

  # GET /operational_goals
  # GET /operational_goals.json
  def index
    @operational_goals = OperationalGoal.all
  end
  
  def index_filtro
    @operational_goals = OperationalGoal.all
  end
  
  def indexfiltro
    if params[:operational_goal] != nil
     @stringa_ricerca = params[:operational_goal][:stringa]
	 @operational_goals = OperationalGoal.left_joins(:responsabile_principale).where("lower(operational_goals.denominazione) LIKE lower(?) OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	else
     @operational_goals = OperationalGoal.all
	 @stringa_ricerca = ""
	end
  end

  # GET /operational_goals/1
  # GET /operational_goals/1.json
  def show
  end

  # GET /operational_goals/new
  def new
    @operational_goal = OperationalGoal.new
  end
  
  def nuovoobiettivo
    
  end
  
  def crea_nuovo_obiettivo
    puts "CREA_NUOVO_OBIETTIVO"
	puts params
	denominazione = params[:denominazione]
	descrizione = params[:descrizione]
	responsabile_principale_id = params[:responsabile_principale_id]
	indicatore_avanzamento = params[:indicatore_avanzamento]
	obiettivo_di_ente = params[:obiettivo_di_ente]
	obiettivo_di_gruppo = params[:obiettivo_di_gruppo]
	obiettivo_individuale = params[:obiettivo_individuale]
	attivita_ordinaria = params[:attivita_ordinaria]
	indice_strategicita = params[:indice_strategicita]
	anno = params[:anno]
	ente = params[:ente]
	
	resp = Person.find(responsabile_principale_id)
	
	@operational_goal = OperationalGoal.new
	@operational_goal.denominazione = denominazione
	@operational_goal.descrizione = descrizione
	@operational_goal.responsabile_principale = resp
	@operational_goal.obiettivo_di_ente = obiettivo_di_ente
	@operational_goal.obiettivo_di_gruppo = obiettivo_di_gruppo
	@operational_goal.obiettivo_individuale = obiettivo_individuale
	@operational_goal.attivita_ordinaria = attivita_ordinaria
	@operational_goal.indice_strategicita = indice_strategicita
	@operational_goal.anno = anno
	@operational_goal.ente = ente
	@operational_goal.save
	
	if indicatore_avanzamento.eql? "1"
	  indicatore = Gauge.new
	  indicatore.nome = "Avanzamento " + denominazione
	  indicatore.descrizione = "Indicatore automatico avanzamento obiettivo"
      indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
      indicatore.valore_misurazione = 0.0
	  indicatore.save
	  @operational_goal.indicatori<<  indicatore
	end
	
  end

  # GET /operational_goals/1/edit
  def edit
  end

  # POST /operational_goals
  # POST /operational_goals.json
  def create
    @operational_goal = OperationalGoal.new(operational_goal_params)

    respond_to do |format|
      if @operational_goal.save
        format.html { redirect_to @operational_goal, notice: 'Operational goal was successfully created.' }
        format.json { render :show, status: :created, location: @operational_goal }
      else
        format.html { render :new }
        format.json { render json: @operational_goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operational_goals/1
  # PATCH/PUT /operational_goals/1.json
  def update
    respond_to do |format|
      if @operational_goal.update(operational_goal_params)
        format.html { redirect_to @operational_goal, notice: 'Operational goal was successfully updated.' }
        format.json { render :show, status: :ok, location: @operational_goal }
      else
        format.html { render :edit }
        format.json { render json: @operational_goal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operational_goals/1
  # DELETE /operational_goals/1.json
  def destroy
    @operational_goal.destroy
    respond_to do |format|
      format.html { redirect_to indexfiltro_operational_goals_path, notice: 'Operational goal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def static_add_altro_responsabile
    puts params
	
	@operational_goal = OperationalGoal.find(params[:format])
  end
  
  def gestisci_operational_goal
   puts params
   @og = OperationalGoal.first
   respond_to do |format|
	   format.js   { }
   end
  end
  
  def set_responsabili
   @operational_goal = OperationalGoal.find(params[:format])
   # respond_to do |format|
	  # format.js   { }
   # end
  end 
  
  def set_responsabile
    puts "Vediamo i parametri set_responsabile"
	puts params
	@person = Person.find(params[:operational_goal][:id])
	@operational_goal = OperationalGoal.find(params[:operational_goal_id])
	@operational_goal.responsabile_principale = @person
	@operational_goal.save
    respond_to do |format|
	   format.js    {render :action => "set_responsabili" }
	end
  end
  
  def add_altro_responsabile
    puts "Vediamo i parametri add_altro_responsabile"
	puts params
	@person = Person.find(params[:operational_goal][:id])
	@operational_goal = OperationalGoal.find(params[:operational_goal_id])
	@operational_goal.altri_responsabili<< @person
	@operational_goal.save
	@operational_goal.reload
    respond_to do |format|
	   format.js    {render :action => "set_responsabili" }
	end
  end
  
  def remove_altro_responsabile
    puts "Vediamo i parametri remove_altro_responsabile"
	puts params
	@person = Person.find(params[:operational_goal][:person_id])
	@operational_goal = OperationalGoal.find(params[:operational_goal_id])
	@operational_goal.altri_responsabili.delete(@person)
	@operational_goal.save
	@operational_goal.reload
    respond_to do |format|
	   format.js    {render :action => "set_responsabili" }
	end
  end
  
  def gestioneobiettivixdirigente
     @dirigenti = []
     #@dirigenti = Person.dirigenti
     # con il filtro faccio vedere solo quello che deve vedere
     @dirigenti = filtro_dirigenti
  end 
  
  def searchobiettividipendentixdirigente
  puts "PARAMETRI searchobiettividipendentixdirigente"
  puts params
  @dirigente = nil
  @obiettivi = []
  @obiettivo = nil
  @fasi = []
  @fase = nil
  @azioni = []
  @azione = nil
  @listadipendenti = []
    
  @dirigente = Person.find(params[:person][:id])
  
  @dirigente.obiettivi_responsabile.each do |o|
   @obiettivi<< o
  end
  #@obiettivi = @dirigente.obiettivi_responsabile
  @dirigente.dirige.each do |o|
    o.dipendenti.each do |p|
      @listadipendenti<< p
    end	
  end
  puts "OUT searchobiettividipendentixdirigente"
  puts  @listadipendenti.length
  puts  @obiettivi.length
  puts  @dirigente.nominativo
  respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente"  }
  end
  end
  
  def selectobiettivoxdirigente
    puts "PARAMETRI selectobiettovixdirigente"
    puts params
	puts params[:person][:dirigente_id]
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:person][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
	respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def selectfasexdirigente
    puts "PARAMETRI selectfasexdirigente"
    puts params
	puts params[:operational_goal][:id]
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:operational_goal][:obiettivo_id])
	@fase = Phase.find(params[:operational_goal][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
	respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def selectazionexdirigente
    puts "PARAMETRI selectazionexdirigente"
    puts params
	puts params[:phase][:id]
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	@fase = Phase.find(params[:phase][:fase_id])
	@azione = SimpleAction.find(params[:phase][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
	respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def remove_assegnatario
    puts "PARAMETRI remove_assegnatario"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:operational_goal_id])
	@dipendente = Person.find(params[:operational_goal][:person_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@obiettivo.assegnatari.delete(@dipendente)
	@obiettivo.save
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def remove_assegnatario_fase
    puts "PARAMETRI remove_assegnatario_fase"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivi =@dirigente.obiettivi_responsabile
	@fase = Phase.find(params[:phase][:fase_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	@fasi = @obiettivo.fasi
	@dipendente = Person.find(params[:phase][:person_id])
	@fase.assegnatari.delete(@dipendente)
	@fase.save
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def remove_assegnatario_azione
    puts "PARAMETRI remove_assegnatario_azione"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:simple_action][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:simple_action][:obiettivo_id])
	@fase = Phase.find(params[:simple_action][:fase_id])
	@azione = SimpleAction.find(params[:simple_action][:azione_id])
	@dipendente = Person.find(params[:simple_action][:person_id])
	@azione.assegnatari.delete(@dipendente)
	@azione.save
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def add_assegnatario
    puts "PARAMETRI add_assegnatario"
    puts params  
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:operational_goal_id])
	@dipendente = Person.find(params[:operational_goal][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@obiettivo.assegnatari<< @dipendente
	@obiettivo.save
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def add_assegnatario_fase
    puts "PARAMETRI add_assegnatario_fase"
    puts params  
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	@dipendente = Person.find(params[:phase][:id])
	@fase = Phase.find(params[:phase][:fase_id])
	@fase.assegnatari<< @dipendente
	@fase.save
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def add_assegnatario_azione
    puts "PARAMETRI add_assegnatario_azione"
    puts params  
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listadipendenti = []
	
	@dirigente = Person.find(params[:simple_action][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:simple_action][:obiettivo_id])
	@dipendente = Person.find(params[:simple_action][:id])
	@fase = Phase.find(params[:simple_action][:fase_id])
	@azione = SimpleAction.find(params[:simple_action][:azione_id])
	@azione.assegnatari<< @dipendente
	@azione.save
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@dirigente.dirige.each do |o|
      o.dipendenti.each do |p|
        @listadipendenti<< p
      end	
    end
    respond_to do |format|
	    format.js   { render :action => "assegnaobiettivifasiazionixdirigente" }
    end
  end
  
  def importa
    
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	importati = OperationalGoal.importa(params[:file]) # viene lanciato il metodo del model
    @obiettivi = importati[0]
	@fasi = importati[1]
	@azioni = importati[2] 
	@obiettivi_modificati = importati[3]
	
	# qua va automaticamente alla vista importa con la variabile 
  end
  
  def importavalori
    
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	importati = OperationalGoal.importavalori(params[:file]) # viene lanciato il metodo del model
    @obiettivi = importati[0]
	@fasi_modificate = importati[1]
	@azioni_modificate = importati[2] 
	@obiettivi_modificati = importati[3]
	@indicatori_valorizzati = importati[4]
	@valutazioni_importate = importati[5]
	@target_non_trovati = importati[6]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_attivita_ordinaria
   #@dirigenti = Person.dirigenti
   # con il filtro faccio vedere solo quello che deve vedere
   @dirigenti = filtro_dirigenti
  end
  
  def importa_attivita_ordinaria
    
	puts "IMPORTA_ATTIVITA_ORDINARIA"
	puts params
	responsabile = Person.find(params[:person][:id])
	puts responsabile.cognome
    filename = params[:file].original_filename
	colonna_nome_ufficio = params[:colonna_nome_ufficio]
	colonna_obiettivo = params[:colonna_obiettivo]
	colonna_indicatore = params[:colonna_indicatore]
	colonna_valore = params[:colonna_valore]
	colonna_obiettivo_performance = params[:colonna_obiettivo_performance]
	nome_foglio = params[:nome_foglio]
	puts "FILENAME " + filename
	importati = OperationalGoal.importa_attivita_ordinaria(params[:file], responsabile, colonna_nome_ufficio, colonna_obiettivo, colonna_indicatore, colonna_valore, colonna_obiettivo_performance, nome_foglio) # viene lanciato il metodo del model
    @obiettivi = importati[0]
	@obiettivi_modificati = importati[1]
	@righe_non_determinate = importati[2]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_valori_attivita_ordinaria
    #@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti  @dirigenti = Person.dirigenti
  end
  
  def importa_valori_attivita_ordinaria
    
	puts "IMPORTA_ATTIVITA_ORDINARIA"
	puts params
	responsabile = Person.find(params[:person][:id])
	puts responsabile.cognome
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	importati = OperationalGoal.importa_misurazioni_attivita_ordinaria(params[:file], responsabile) # viene lanciato il metodo del model
    @obiettivi = importati[0]
	@obiettivi_modificati = importati[1]
	@righe_non_determinate = importati[2]
	@valori_assegnati = importati[3]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def pesi_fasi_azioni
    @dirigenti = []
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
  end
  
  def search_pesi_fasi_azioni
    
	@dirigente = Person.find(params[:person][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	
	respond_to do |format|
	    format.js   { render :action => "set_pesi_fasi_azioni"  }
    end
	
  end
  
  def setpeso_fase_azione
    puts "setpeso_fase_azione"
	puts params
    @dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	tipo = params[:operational_goal][:tipo]
	
	case tipo
	when "Fase"
	  fase = Phase.find(params[:operational_goal][:phase_id])
	  fase.peso = params[:operational_goal][:value]
      fase.save
	when "Azione"
	  azione = SimpleAction.find(params[:operational_goal][:simple_action_id])
	  azione.peso = params[:operational_goal][:value]
      azione.save
    end	
    
	respond_to do |format|
	    format.js   { render :action => "set_pesi_fasi_azioni"  }
    end
  
  end
  
  def strutturaobiettivixdirigente
    @dirigenti = []
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
  end
  
  def viewstrutturaobiettivixdirigente
    puts "VIEWSTRUTTURAOBIETTIVIXDIRIGENTE"
    @dirigenti = []
	@target_array = []
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
	
    @dirigente = Person.find(params[:person][:id])
	
	@dirigente.obiettivi_responsabile.each do |o|
      @target_array<< o
    end
    @dirigente.fasi_responsabile.each do |f|
      @target_array<< f
    end
	@dirigente.azioni_responsabile.each do |a|
      @target_array<< a
    end
	
	respond_to do |format|
	    format.js   { render :action => "viewstrutturaobiettivixdirigente" }
    end
    
	
  end
  
  def selecttargetxdirigente
    
	puts "SELECTTARGETXDIRIGENTE"
	puts params
	@dirigente = nil
    @target_array = []
	@obiettivo = nil
	@fase = nil
	@target = nil
	 
	selezionato = params[:operational_goal][:selected]
	puts selezionato 
	if selezionato != nil
	  id = selezionato.split(" ")[0]
	  tipo = selezionato.split(" ")[1]
	  case tipo
      when "OperationalGoal"
        @obiettivo = OperationalGoal.find(id)
		@target = @obiettivo
      when "Phase"
        @fase = Phase.find(id)
		@target = @fase
	  end
	end
	@dirigenti = Person.dirigenti
    @dirigente = Person.find(params[:operational_goal][:dirigente_id])
	
	@dirigente.obiettivi_responsabile.each do |o|
      @target_array<< o
    end
    @dirigente.fasi_responsabile.each do |f|
      @target_array<< f
    end
	@dirigente.azioni_responsabile.each do |a|
      @target_array<< a
    end
	
	puts "targets # : " + @target_array.length.to_s
	
    respond_to do |format|
	    format.js   { render :action => "viewstrutturaobiettivixdirigente" }
    end
    
    
  end
  
  def removechildfromparent
    
	puts "REMOVECHILDFROMPARENT"
	puts params
    @dirigente = nil
    @target_array = []
	@obiettivo = nil
	@fase = nil
	@target = nil
	
	@dirigente = Person.find(params[:dirigente_id])
	parent_id = params[:parent_id]
	parent_tipo = params[:parent_type]
	rimuovere_id = params[:target_id]
	rimuovere_type = params[:target_type]
	
	case parent_tipo
    when "OperationalGoal"
        @obiettivo = OperationalGoal.find(parent_id)
		@fase = Phase.find(rimuovere_id)
		@fase.obiettivo_operativo_fase = nil
		# questo faceva cancellare la fase
		#@obiettivo.fasi.delete(@fase)
		#@obiettivo.save
		@fase.save
		@target = @obiettivo
		
		
    when "Phase"
        @fase = Phase.find(parent_id)
		@azione = SimpleAction.find(rimuovere_id)
		@azione.fase = nil
		#@fase.azioni.delete(@azione)
		#@fase.save
		@azione.save
		@target = @fase
	end
	
	@dirigente.obiettivi_responsabile.each do |o|
      @target_array<< o
    end
    @dirigente.fasi_responsabile.each do |f|
      @target_array<< f
    end
	@dirigente.azioni_responsabile.each do |a|
      @target_array<< a
    end
	
	respond_to do |format|
	    format.js   { render :action => "viewstrutturaobiettivixdirigente" }
    end
  
  end
  
  def movetarget
    puts "MOVETARGET"
	puts params
	
    dirigente_id = params[:dirigente_id]
	target_id = params[:target_id]
	target_type = params[:target_type]
	nodo_dragged_id = params[:nodo_dragged_id]
	nodo_target_id = params[:nodo_target_id]
	
	
	@dirigente = nil
    @target_array = []
	@obiettivo = nil
	@fase = nil
	@target = nil
	
	@dirigente = Person.find(dirigente_id)
	
	@dirigente.obiettivi_responsabile.each do |o|
      @target_array<< o
    end
    @dirigente.fasi_responsabile.each do |f|
      @target_array<< f
    end
	@dirigente.azioni_responsabile.each do |a|
      @target_array<< a
    end
	
	case target_type
	when "OperationalGoal"
	  @target = OperationalGoal.find(target_id)
	when "Phase"
	  @target = Phase.find(target_id)
	when "SimpleAction"
      @target = SimpleAction.find(target_id)
    end	
	
    respond_to do |format|
	    format.js   { render :action => "viewstrutturaobiettivixdirigente" }
    end
  end
  
  def addchildinparent
    puts "ADDCHILDINPARENT"
	puts params
    @dirigente = nil
    @target_array = []
	@obiettivo = nil
	@fase = nil
	@target = nil
	
	@dirigente = Person.find(params[:dirigente_id])
	parent_id = params[:parent_id]
	parent_tipo = params[:parent_type]
	aggiungere_id = params[:id]
		
	case parent_tipo
    when "OperationalGoal"
        @obiettivo = OperationalGoal.find(parent_id)
		@fase = Phase.find(aggiungere_id)
		@obiettivo.fasi<< @fase
		@obiettivo.save
		@target = @obiettivo
		
		
    when "Phase"
        @fase = Phase.find(parent_id)
		@azione = SimpleAction(aggiungere_id)
		@fase.azioni<< @azione
		@fase.save
		@target = @fase
	end
	
	@dirigente.obiettivi_responsabile.each do |o|
      @target_array<< o
    end
    @dirigente.fasi_responsabile.each do |f|
      @target_array<< f
    end
	@dirigente.azioni_responsabile.each do |a|
      @target_array<< a
    end
	
	respond_to do |format|
	    format.js   { render :action => "viewstrutturaobiettivixdirigente" }
    end
  
  end
  
  def targetxdirigente
    @dirigenti = []
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
    @dirigenti = @dirigenti.sort_by{|d| d.cognome}
  end
  
  def obiettivixdirigente
   puts "OBIETTIVIXDIRIGENTE"
   puts params
   opzionepeg = params[:opzionepeg] 
   opzioneac = params[:opzioneac]
   opzioneopere = params[:opzioneopere]
   puts "PEG " + (opzionepeg != nil ? opzionepeg.to_s : "-")
   puts "AC  " + (opzioneac != nil ? opzioneac.to_s : "-")
   dirigente = Person.find(params[:person][:id])
   @risultati = []
   @opere = []
   obiettivi = dirigente.obiettivi_responsabile
   opere = dirigente.opere
   obiettivi.each do |o|
    if opzioneac && opzionepeg
	  
	    @risultati<< o
	  
	elsif opzioneac && !(opzionepeg)
	   if o.attivita_ordinaria
	    @risultati<< o
	   end
	elsif !(opzioneac) && (opzionepeg) 
	   if !o.attivita_ordinaria
	    @risultati<< o
	   end
	end
   
   end
   
   if opzioneopere
    opere.each do |op|
	 @opere<< op
	end
	
   end
   
   
  
   respond_to do |format|
	   format.js   { }
   end

  end
  
  def indexfiltroall
    @risultati = []
    if params[:operational_goal] != nil
     @stringa_ricerca = params[:operational_goal][:stringa]
	 @operational_goals = OperationalGoal.left_joins(:responsabile_principale).where("lower(operational_goals.denominazione) LIKE lower(?) OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	 @operational_goals.each do |o|
	  @risultati<< o
	 end
	 @phases = Phase.left_joins(:responsabile_principale).where("lower(phases.denominazione) LIKE lower(?) OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	 @phases.each do |f|
	  @risultati<< f
	 end
	 @simple_actions = SimpleAction.left_joins(:responsabile_principale).where("lower(simple_actions.denominazione) LIKE lower(?) OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	 @simple_actions.each do |a|
	  @risultati<< a
	 end
	 @operas = Opera.left_joins(:responsabile).where("lower(operas.descrizione) LIKE lower(?) OR operas.numero LIKE ? OR  people.cognome LIKE ? OR people.nome LIKE ? ", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%", "%#{@stringa_ricerca}%" ).order(:id)
	 @operas.each do |op|
	  @risultati<< op
	 end
	 
	else
     @operational_goals = OperationalGoal.all
	 @phases = Phase.all
	 @simple_actions = SimpleAction.all
	 @operas = Opera.all
	 @operational_goals.each do |o|
	  @risultati<< o
	 end
	 @phases.each do |f|
	  @risultati<< f
	 end
	 @simple_actions.each do |a|
	  @risultati<< a
	 end
	 @operas.each do |op|
	  @risultati<< op
	 end
	 @stringa_ricerca = ""
	end
  end
  
  def aggiungi_target
    @tipo_target = ""
    @target_creato = 0
	
  end
  
  def aggiungi_target_form
   puts "AGGIUNGI_TARGET_FORM"
   puts params
   @messaggio = ""
   @tipo_target = ""
   @target_creato = 0
   @obiettivo_attivo = 0
   
   @descrizione = ""
   @denominazione = ""
   @descrizione_fase_sottostante = ""
   @denominazione_fase_sottostante = ""
   @dirigente =  nil
   @obiettivo_padre = nil
   @fase_padre = nil
   @azione_creata = nil
   @scelta = ""
   @selezionato = ""
   
   
   #@lista_tipi = ["Obiettivo operativo", "Fase", "Azione", "Opera"]
   @lista_tipi = ["Obiettivo operativo"]
   @dirigente = Person.find(params[:person][:dirigente_id])
   puts "dirigente: " + @dirigente.nominativo
   
   operazione = params[:person][:operazione]
   if params[:person][:tipo_target] != nil
	 puts "setto tipo terget: " + params[:person][:tipo_target]
     @tipo_target = params[:person][:tipo_target] 
   end
   
   case operazione 
   when "scelta"
   
    
 	
	@obiettivo_padre = nil
    @fase_padre = nil
    @azione_creata = nil
	
	   
   when "crea_obiettivo"
		if params[:person][:descrizione_obiettivo] != nil 
			@descrizione = "" + params[:person][:descrizione_obiettivo]
		end
   
		if params[:person][:denominazione_obiettivo] != nil 
			@denominazione = "" + params[:person][:denominazione_obiettivo]
		end
		@dirigente = Person.find(params[:person][:dirigente_id])
		flag_obiettivo_di_ente = ( params[:person][:obiettivo_di_ente] == "1" )
		flag_obiettivo_di_gruppo = ( params[:person][:obiettivo_di_gruppo] == "1" )
		flag_obiettivo_di_struttura = ( params[:person][:obiettivo_di_struttura] == "1" )
		flag_obiettivo_individuale = ( params[:person][:obiettivo_individuale] == "1" )
		flag_attivita_ordinaria = ( params[:person][:attivita_ordinaria] == "1" )
		flag_obiettivo_extrapeg = ( params[:person][:obiettivo_extrapeg] == "1" )
		indice_strategicita = ( params[:person][:indice_strategicita] == "1" )
		flag_crea_indicatore_default = ( params[:person][:crea_indicatore_default] == "1" )
		if ! current_user_admin? 
		  flag_obiettivo_di_ente = false
		  flag_obiettivo_di_gruppo = false
		  flag_obiettivo_di_struttura = false
		  flag_obiettivo_individuale = false
		  flag_obiettivo_extrapeg = true
		  flag_attivita_ordinaria = ( params[:person][:attivita_ordinaria] == "1" )
		  @messaggio = @messaggio + " forzato obiettivo extrapeg"
		end
		@og = OperationalGoal.create(denominazione: @denominazione,
			                       descrizione: @descrizione,
								   		   
								   anno: Setting.where(denominazione: 'anno').first.value,
								   obiettivo_di_ente: flag_obiettivo_di_ente,
								   obiettivo_di_gruppo: flag_obiettivo_di_gruppo,
								   obiettivo_di_struttura: flag_obiettivo_di_struttura,
								   obiettivo_individuale: flag_obiettivo_individuale,
								   attivita_ordinaria: flag_attivita_ordinaria,
								   obiettivo_extrapeg: flag_obiettivo_extrapeg,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   responsabile_principale: @dirigente)
		if flag_crea_indicatore_default
			indicatore = Gauge.new
			indicatore.nome = "Avanzamento " + @denominazione
			indicatore.descrizione = "Indicatore automatico avanzamento obiettivo"
			indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
			indicatore.valore_misurazione = 0.0
			indicatore.save
			@og.indicatori<<  indicatore
			@og.save
		elsif params[:person][:indicatore_nome].to_s.length > 1
		    indicatore = Gauge.new
		    indicatore.nome = params[:person][:indicatore_nome].to_s
			indicatore.descrizione = params[:person][:indicatore_descrizione].to_s
			indicatore.descrizione_valore_misurazione = params[:person][:indicatore_descrizione_valore_misurazione].to_s
			indicatore.valore_misurazione = 0.0
			indicatore.save
			@og.indicatori<<  indicatore
			@og.save
		end
	    @target_creato = @og.id
	    @obiettivo_padre = @og.id
		@tipo_target = "Obiettivo operativo"
		@lista_tipi = ["Fase"]
		@obiettivo_attivo = @og.id
		@messaggio = @messaggio + " Obiettivo creato"
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "modifica_obiettivo"
        
		@target_creato = params[:person][:target_creato]
		@tipo_target = params[:person][:tipo_target]
		puts "modifica_obiettivo " + @target_creato.to_s
		if @tipo_target.to_s.length > 1
          tipo = "o"
	      
		  if tipo.eql? 'o'
		    if params[:person][:descrizione_obiettivo] != nil 
			  @descrizione = "" + params[:person][:descrizione_obiettivo]
		    end
   
		    if params[:person][:denominazione_obiettivo] != nil 
			  @denominazione = "" + params[:person][:denominazione_obiettivo]
		    end
		    
			flag_obiettivo_di_ente = ( params[:person][:obiettivo_di_ente] == "1" )
		    flag_obiettivo_di_gruppo = ( params[:person][:obiettivo_di_gruppo] == "1" )
		    flag_obiettivo_di_struttura = ( params[:person][:obiettivo_di_struttura] == "1" )
		    flag_obiettivo_individuale = ( params[:person][:obiettivo_individuale] == "1" )
		    flag_attivita_ordinaria = ( params[:person][:attivita_ordinaria] == "1" )
		    indice_strategicita = params[:person][:indice_strategicita] 
			flag_crea_indicatore_default = ( params[:person][:crea_indicatore_default] == "1" )
		    flag_obiettivo_extrapeg = ( params[:person][:obiettivo_extrapeg] == "1" )
		    @obiettivo = OperationalGoal.find(@target_creato)
			@obiettivo.denominazione = @denominazione
			@obiettivo.descrizione = @descrizione
			@obiettivo.obiettivo_di_ente = flag_obiettivo_di_ente
			@obiettivo.obiettivo_di_gruppo = flag_obiettivo_di_gruppo
			@obiettivo.obiettivo_di_struttura = flag_obiettivo_di_struttura
			@obiettivo.obiettivo_individuale = flag_obiettivo_individuale
			@obiettivo.attivita_ordinaria = flag_attivita_ordinaria
			@obiettivo.obiettivo_extrapeg = flag_obiettivo_extrapeg
			@obiettivo.indice_strategicita = indice_strategicita
			if current_user_admin? 
			 @obiettivo.save
			 @messaggio = @messaggio + " Obiettivo modificato"
			else
			 @messaggio = @messaggio + " utente non abilitato alla modifica"
			end 
			if !current_user_admin? && (@obiettivo.obiettivo_extrapeg)
			 @obiettivo.save
			 @messaggio = @messaggio + " Obiettivo modificato"
			end
			if !current_user_admin? && (@obiettivo.obiettivo_di_struttura || @obiettivo.obiettivo_individuale)
			  @messaggio = @messaggio + " utente non abilitato alla modifica"
			end
			
			@obiettivo_attivo = @obiettivo.id
			
			if flag_crea_indicatore_default
			  indicatore = Gauge.new
			  indicatore.nome = "Avanzamento " + @obiettivo.denominazione
			  indicatore.descrizione = "Indicatore automatico avanzamento fase"
			  indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
			  indicatore.valore_misurazione = 0.0
			  indicatore.save
			  @obiettivo.indicatori<<  indicatore
			  @obiettivo.save
			  @messaggio = @messaggio + " Indicatore default creato"
		    else 
		      puts "CREA INDICATORE PERSONALIZZATO (fase)"
			  if params[:person][:indicatore_nome].to_s.length > 0
			    indicatore = Gauge.new
			    indicatore.nome = params[:person][:indicatore_nome].to_s
			    indicatore.descrizione = params[:person][:indicatore_descrizione].to_s
			    indicatore.descrizione_valore_misurazione = params[:person][:indicatore_descrizione_valore_misurazione].to_s
			    indicatore.valore_misurazione = 0.0
			    indicatore.save
			    @obiettivo.indicatori<<  indicatore
			    @obiettivo.save
				@messaggio = @messaggio + " Indicatore personalizzato creato"
			  end
		    end
			
			
		  end
		end 
		@obiettivo_padre = @target_creato
        @obiettivo_attivo = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
	     
   when "rimuovi_obiettivo"	
        @target_creato = params[:person][:target_creato]
		@tipo_target = params[:person][:tipo_target]
		if @tipo_target.eql?("Obiettivo")
		  o = OperationalGoal.find(@target_creato)
		  if !o.ha_vincoli
		    o.destroy
			@messaggio = @messaggio + " Obiettivo rimosso"
		  else
		    @messaggio = @messaggio + " Obiettivo " + o.denominazione + " ha vincoli che impediscono la cancellazione."
		  end
		end
		@obiettivo_padre = params[:person][:obiettivo_padre]
		@tipo_target = ""
		@target_creato = 0
		@obiettivo_padre = nil
		@fase_padre = nil
		@azione_creata = nil
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = 0
	      @tipo_nodo_attivo = ""
   
   when "crea_fase"
		if params[:person][:descrizione_fase_sottostante] != nil 
			descrizione = "" + params[:person][:descrizione_fase_sottostante]
		end
   
		if params[:person][:denominazione_fase_sottostante] != nil 
			denominazione = "" + params[:person][:denominazione_fase_sottostante]
		end
		
		if params[:person][:peso_fase_sottostante] != nil 
			peso = "" + params[:person][:peso_fase_sottostante]
		end
		
		flag_crea_indicatore_default = ( params[:person][:crea_indicatore_default] == "1" )
		
		if params[:person][:obiettivo_padre] != nil 
			@obiettivo_padre = params[:person][:obiettivo_padre]
			@og = OperationalGoal.find(@obiettivo_padre)
		end
		
		@dirigente = Person.find(params[:person][:dirigente_id])
		@f = Phase.create(denominazione: denominazione,
			                       descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   								   
								   ente: Setting.where(denominazione: 'ente').first.value,
								   peso: peso,
								   obiettivo_operativo_fase: @og,
								   responsabile_principale: @dirigente)
		@messaggio = @messaggio + " Fase creata"
		if flag_crea_indicatore_default
			indicatore = Gauge.new
			indicatore.nome = "Avanzamento " + denominazione
			indicatore.descrizione = "Indicatore automatico avanzamento fase"
			indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
			indicatore.valore_misurazione = 0.0
			indicatore.save
			@messaggio = @messaggio + " Indicatore default creato"
			@f.indicatori<<  indicatore
			@f.save
		else 
		    puts "CREA INDICATORE PERSONALIZZATO (fase)"
			if params[:person][:indicatore_nome].to_s.length > 0
			 indicatore = Gauge.new
			 indicatore.nome = params[:person][:indicatore_nome].to_s
			 indicatore.descrizione = params[:person][:indicatore_descrizione].to_s
			 indicatore.descrizione_valore_misurazione = params[:person][:indicatore_descrizione_valore_misurazione].to_s
			 indicatore.valore_misurazione = 0.0
			 indicatore.save
			 @messaggio = @messaggio + " Indicatore personalizzato creato"
			 @f.indicatori<<  indicatore
			 @f.save
			end
		end
	    @target_creato = params[:person][:target_creato]
		@obiettivo_padre = params[:person][:obiettivo_padre]
        @fase_padre = @f.id 
		@obiettivo_attivo = @obiettivo_padre
        # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "modifica_fase"
        descrizione = ""
		denominazione = ""
        if params[:person][:descrizione_fase_sottostante] != nil 
			descrizione = "" + params[:person][:descrizione_fase_sottostante]
		end
   
		if params[:person][:denominazione_fase_sottostante] != nil 
			denominazione = "" + params[:person][:denominazione_fase_sottostante]
		end
		
		if params[:person][:peso_fase_sottostante] != nil 
			peso = "" + params[:person][:peso_fase_sottostante]
		end
		f = Phase.find(params[:person][:target_creato])
		f.descrizione = descrizione
		f.denominazione = denominazione
		f.peso = peso
		f.save
		@messaggio = @messaggio + " Fase modificata"
		@target_creato = f.id
		@tipo_target = params[:person][:tipo_target]
		@obiettivo_padre = params[:person][:obiettivo_padre]
        @fase_padre = f.id 
		@obiettivo_attivo = params[:person][:obiettivo_attivo]
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "rimuovi_fase"
        
		@target_creato = params[:person][:target_creato]
		@tipo_target = params[:person][:tipo_target]
		if @tipo_target.eql?("Fase")
		  f = Phase.find(@target_creato)
		  if !f.ha_vincoli
		    f.destroy
		    @messaggio = @messaggio + " Fase rimossa"
		  else
		    @messaggio = @messaggio + " Fase " + f.denominazione + " ha vincoli che impediscono la cancellazione."
		  end
		  
		end
		@obiettivo_padre = params[:person][:obiettivo_padre]
		@obiettivo_attivo = @obiettivo_padre
		@tipo_target = "Obiettivo"
		@target_creato = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "crea_azione"
		if params[:person][:obiettivo_padre] != nil 
			@obiettivo_padre = params[:person][:obiettivo_padre]
			@obiettivo_attivo = @obiettivo_padre
		end
		if params[:person][:fase_padre] != nil 
			@fase_padre = params[:person][:fase_padre]
			@f = Phase.find(@fase_padre)
		end
		if params[:person][:descrizione_azione_sottostante] != nil 
			descrizione = "" + params[:person][:descrizione_azione_sottostante]
		end
   
		if params[:person][:denominazione_azione_sottostante] != nil 
			denominazione = "" + params[:person][:denominazione_azione_sottostante]
		end
		
		if params[:person][:peso_azione_sottostante] != nil 
			peso = "" + params[:person][:peso_azione_sottostante]
		end
		
		flag_crea_indicatore_default = ( params[:person][:crea_indicatore_default] == "1" )
		
		@dirigente = Person.find(params[:person][:dirigente_id])
		@a = SimpleAction.create(denominazione: denominazione,
			                       descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   
								   ente: Setting.where(denominazione: 'ente').first.value,
								   peso: peso,
								   fase: @f,
								   responsabile_principale: @dirigente)
		@messaggio = @messaggio + " Azione creata"
		if flag_crea_indicatore_default
			indicatore = Gauge.new
			indicatore.nome = "Avanzamento " + denominazione
			indicatore.descrizione = "Indicatore automatico avanzamento azione"
			indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
			indicatore.valore_misurazione = 0.0
			indicatore.save
			@messaggio = @messaggio + " Indicatore default creato"
			@a.indicatori<<  indicatore
			@a.save
		else 
			puts "CREA INDICATORE PERSONALIZZATO (azione)"
			if params[:person][:indicatore_nome].to_s.length > 0
			 indicatore = Gauge.new
			 indicatore.nome = params[:person][:indicatore_nome].to_s
			 indicatore.descrizione = params[:person][:indicatore_descrizione].to_s
			 indicatore.descrizione_valore_misurazione = params[:person][:indicatore_descrizione_valore_misurazione].to_s
			 indicatore.valore_misurazione = 0.0
			 indicatore.save
			 @messaggio = @messaggio + " Indicatore personalizzato creato"
			 @a.indicatori<<  indicatore
			 @a.save
			end
		end
	    @target_creato = params[:person][:target_creato]
		@obiettivo_padre = params[:person][:obiettivo_padre]
        @fase_padre = @f.id 
		@obiettivo_attivo = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		  
   when "modifica_azione"
   
        descrizione = ""
		denominazione = ""
        if params[:person][:descrizione_azione_sottostante] != nil 
			descrizione = "" + params[:person][:descrizione_azione_sottostante]
		end
   
		if params[:person][:denominazione_azione_sottostante] != nil 
			denominazione = "" + params[:person][:denominazione_azione_sottostante]
		end
		
		if params[:person][:peso_azione_sottostante] != nil 
			peso = "" + params[:person][:peso_azione_sottostante]
		end
		a = SimpleAction.find(params[:person][:target_creato])
		a.descrizione = descrizione
		a.denominazione = denominazione
		a.peso = peso
		a.save
		@messaggio = @messaggio + " Azione modificata"
		@target_creato = a.id
		@tipo_target = params[:person][:tipo_target]
		@obiettivo_padre = params[:person][:obiettivo_padre]
        @fase_padre = a.fase.id 
		@obiettivo_attivo = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "rimuovi_azione"
        @target_creato = params[:person][:target_creato]
		@tipo_target = params[:person][:tipo_target]
		if @tipo_target.eql?("Azione")
		  a = SimpleAction.find(@target_creato)
		  if !a.ha_vincoli
		    a.destroy
		    @messaggio = @messaggio + " Azione rimossa"
		  else
		    @messaggio = @messaggio + " Azione " + a.denominazione + " ha vincoli che impediscono la cancellazione."
		  end
		  
		end
		@obiettivo_padre = params[:person][:obiettivo_padre]
		@obiettivo_attivo = @obiettivo_padre
		@tipo_target = "Obiettivo"
		@target_creato = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
   
   when "rimuovi_indicatore"
        @obiettivo_padre = params[:person][:obiettivo_padre]
		@obiettivo_attivo = @obiettivo_padre
		
        if params[:person][:indicatore_da_rimuovere] != nil 
		   i_id = params[:person][:indicatore_da_rimuovere]
		   i = Gauge.find(i_id)
		   t = i.target
		   i.delete
		   @messaggio = @messaggio + " Indicatore rimosso"
		   @obiettivo_padre = params[:person][:obiettivo_padre]
		   @obiettivo_attivo = @obiettivo_padre  
           @tipo_target = t.tipo
		   @target_creato = @obiettivo_padre		   
		end
		if t != nil 
          @target_creato = t.id
		  @tipo_target = t.tipo
		  @obiettivo_padre = params[:person][:obiettivo_padre]
		  params[:person][:target_creato]
        
		  @obiettivo_attivo = @obiettivo_padre	
        else # per qualche motivo indicatore senza padre
          @tipo_target = ""
          @target_creato = 0
          @obiettivo_attivo = 0

        end 
        # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = @tipo_target		
   
   when "aggiungi_indicatore"
        t =  nil
		@tipo_target = params[:person][:tipo_target]
		@target_creato = params[:person][:target_creato]
		
		flag_crea_indicatore_default = ( params[:person][:crea_indicatore_default] == "1" )
		
		puts "aggiungi_indicatore. tipo_target: " + @tipo_target.to_s
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = 0
	      @tipo_nodo_attivo = ""
		
		case @tipo_target
		when "Obiettivo"
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @target_creato
	      @tipo_nodo_attivo = "Obiettivo"
		when "Fase"
		 puts "Estrai la fase a cui aggiungere un indicatore"
		 t =  Phase.find(@target_creato)
		 # questi sono per che parte di albero mostrare 
		  @nodo_attivo = t.obiettivo_operativo_fase.id
	      @tipo_nodo_attivo = "Obiettivo"
		when "Azione"
		 puts "Estrai la azione a cui aggiungere un indicatore"
		 t =  SimpleAction.find(@target_creato)
		 # questi sono per che parte di albero mostrare 
		  @nodo_attivo = t.fase.obiettivo_operativo_fase.id
	      @tipo_nodo_attivo = "Obiettivo"
		when "Opera"
		 puts "Estrai la opera a cui aggiungere un indicatore"
		 t =  Opera.find(@target_creato)
		 # questi sono per che parte di albero mostrare 
		  @nodo_attivo = t.id
	      @tipo_nodo_attivo = "Opera"
		else
		
		end
		
		if flag_crea_indicatore_default && t != nil
			indicatore = Gauge.new
			indicatore.nome = "Avanzamento " + t.denominazione
			indicatore.descrizione = "Indicatore automatico avanzamento azione"
			indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
			indicatore.valore_misurazione = 0.0
			indicatore.save
			@messaggio = @messaggio + " Indicatore default creato"
			t.indicatori<<  indicatore
			t.save
		else 
			puts "CREA INDICATORE PERSONALIZZATO (azione)"
			if params[:person][:indicatore_nome].to_s.length > 0
			 indicatore = Gauge.new
			 indicatore.nome = params[:person][:indicatore_nome].to_s
			 indicatore.descrizione = params[:person][:indicatore_descrizione].to_s
			 indicatore.descrizione_valore_misurazione = params[:person][:indicatore_descrizione_valore_misurazione].to_s
			 indicatore.valore_misurazione = 0.0
			 indicatore.save
			 @messaggio = @messaggio + " Indicatore personalizzato creato"
			 t.indicatori<<  indicatore
			 t.save
			end
		end
		
		
		@obiettivo_attivo = params[:person][:obiettivo_attivo]
		@obiettivo_padre = params[:person][:obiettivo_padre]
        

   when "modifica_indicatore"
   
        indicatore_nome = ""
		indicatore_descrizione = ""
		indicatore_descrizione_valore_misurazione = ""
		
        if params[:person][:indicatore_nome] != nil 
			indicatore_nome = "" + params[:person][:indicatore_nome]
		end
   
		if params[:person][:indicatore_descrizione] != nil 
			indicatore_descrizione = "" + params[:person][:indicatore_descrizione]
		end
		
		if params[:person][:indicatore_descrizione_valore_misurazione] != nil 
			indicatore_descrizione_valore_misurazione = "" + params[:person][:indicatore_descrizione_valore_misurazione]
		end
		
		i = Gauge.find(params[:person][:target_creato])
		i.nome  = indicatore_nome
		i.descrizione = denominazione
		i.descrizione_valore_misurazione = indicatore_descrizione_valore_misurazione
		i.save
		@messaggio = @messaggio + " Indicatore modificato"
		t = i.target
		# mi posiziono sul target padre
		@target_creato = t.id
		@tipo_target = t.tipo
		if t.tipo.eql? "Obiettivo"
		  @obiettivo_padre = t.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		elsif t.tipo.eql? "Fase"
		  @obiettivo_padre = t.obiettivo_operativo_fase.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		elsif t.tipo.eql? "Azione"
		  @obiettivo_padre = t.fase.obiettivo_operativo_fase.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		elsif t.tipo.eql? "Opera"
		  @obiettivo_padre = t.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Opera"
		end 
        #@fase_padre = a.fase.id 
		@obiettivo_attivo = @obiettivo_padre  
        	
   
   else # ultimo caso del case sulle operazioni
   
		
		@obiettivo_padre = nil
		@fase_padre = nil
		@azione_creata = nil
   end
   
      
   # LINKO OBIETTIVO PADRE o  FASE PADRE
   
	puts "ESCO"
	puts "O: " + @obiettivo_padre.to_s
	puts "F: " + @fase_padre.to_s
	puts "tipo target: " + @tipo_target
    
   	
   
   respond_to do |format|
	   format.js   { render :action => "aggiungi_target_form_02" }
   end
  
  end
  
  def selected_target
    puts "selected_target"
	puts params
	@obiettivo_padre = nil
	@fase_padre = nil
	@azione_creata = nil
	@obiettivo_attivo = 0
	@nodo_attivo = 0
	@tipo_nodo_attivo = ""
	nodo = params[:nodo]
	dirigente_id = params[:dirigente_id]
	puts "id: " + dirigente_id
	puts "nodo: " + nodo
	@dirigente = Person.find(params[:dirigente_id])
	
	#@lista_tipi = ["Obiettivo operativo", "Fase", "Azione", "Opera"]
	@lista_tipi = ["Obiettivo operativo"]
	
	tipo = nodo.split("-")[0]
	id = nodo.split("-")[1]
	
	@selezionato = nodo
	case tipo
	when "o"
		@obiettivo_padre = OperationalGoal.find(id).id
		@target_creato = @obiettivo_padre
		@tipo_target = "Obiettivo"
		@obiettivo_attivo = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		@nodo_attivo = @obiettivo_padre
	    @tipo_nodo_attivo = "Obiettivo"
	when "f"
		f = Phase.find(id)
		@fase_padre = f.id
		@target_creato = @fase_padre
		@tipo_target = "Fase"
		@obiettivo_padre = f.obiettivo_operativo_fase.id
		@obiettivo_attivo = @obiettivo_padre
		# questi sono per che parte di albero mostrare 
		@nodo_attivo = @obiettivo_padre
	    @tipo_nodo_attivo = "Obiettivo"
	when "a"
		a = SimpleAction.find(id)
		@azione_creata = a.id
		@fase_padre = a.fase.id
		@target_creato = @azione_creata
		@obiettivo_padre = a.fase.obiettivo_operativo_fase.id
		@obiettivo_attivo = @obiettivo_padre
		@tipo_target = "Azione"
		# questi sono per che parte di albero mostrare 
		@nodo_attivo = a.fase.obiettivo_operativo_fase.id
	    @tipo_nodo_attivo = "Obiettivo"
	when "d"
		@dirigente = Person.find(id)
		@obiettivo_padre = nil
		@target_creato = 0 
		@tipo_target = ""
		@obiettivo_attivo = 0
		# questi sono per che parte di albero mostrare 
		@nodo_attivo = 0
	    @tipo_nodo_attivo = ""
	when "p"
	    p = Opera.find(id)
		@opera_creata = p.id
		
		@target_creato = @opera_creata
		@obiettivo_padre = p.id
		@obiettivo_attivo = @obiettivo_padre
		@tipo_target = "Opera"
		# questi sono per che parte di albero mostrare 
		@nodo_attivo = p.id
	    @tipo_nodo_attivo = "Opera"
	when "i"
		i = Gauge.find(id)
		t = i.target
		@tipo_padre = t.class.name
		@tipo_target = "Indicatore"
		@target_creato = i.id
		case @tipo_padre
		when "OperationalGoal"
		  @obiettivo_attivo = t.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_attivo
	      @tipo_nodo_attivo = "Obiettivo"
		when "Phase"
		  @obiettivo_padre = t.obiettivo_operativo_fase.id
		  @obiettivo_attivo = @obiettivo_padre
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		when "SimpleAction"
		  @obiettivo_padre = t.fase.obiettivo_operativo_fase.id
		  @obiettivo_attivo = @obiettivo_padre
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
		when "Opera"
		  @obiettivo_attivo = t.id
		  @obiettivo_padre = t.id
		  @tipo_target = "Indicatore"
		  @target_creato = i.id
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Opera"
		else
		  @obiettivo_attivo = 0
		
		end
		
	end
	
	respond_to do |format|
	    format.js   { render :action => "aggiungi_target_form_02" }
    end
  end
  
  def modifica_target
    puts "modfica_target"
	puts params
	@obiettivo_padre = nil
	@fase_padre = nil
	@azione_creata = nil
	nodo = params[:nodo]
	dirigente_id = params[:dirigente_id]
	puts "id: " + dirigente_id
	puts "nodo: " + nodo
	@dirigente = Person.find(params[:dirigente_id])
	
	#@lista_tipi = ["Obiettivo operativo", "Fase", "Azione", "Opera"]
	@lista_tipi = ["Obiettivo operativo"]
	
	tipo = nodo.split("-")[0]
	id = nodo.split("-")[1]
	
	@selezionato = nodo
	case tipo
	when "o"
		@obiettivo_padre = OperationalGoal.find(id).id
		@target_creato = @obiettivo_padre
		@tipo_target = "Obiettivo operativo"
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
	when "f"
		f = Phase.find(id)
		@fase_padre = f.id
		@target_creato = @fase_padre
		@tipo_target = "Fase"
		@obiettivo_padre = f.obiettivo_operativo_fase.id
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
	when "a"
		a = SimpleAction.find(id)
		@azione_creata = a.id
		@fase_padre = a.fase.id
		@target_creato = @azione_creata
		@obiettivo_padre = a.fase.obiettivo_operativo_fase.id
		@tipo_target = "Azione"
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
	when "p"
		p = Opera.find(id)
		@opera_creata = p.id
		
		@target_creato = @opera_creata
		@obiettivo_padre = @opera_creata
		@tipo_target = "Opera"
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Opera"
    when "i"
		i = Gauge.find(id)
		@azione_creata = i.id
		target = i.target
		case t.class.name 
		when "OperationalGoal" 
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = target.id
	      @tipo_nodo_attivo = "Obiettivo"
		when "Phase" 
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = target.obiettivo_operativo_fase.id
	      @tipo_nodo_attivo = "Obiettivo"
		when "SimpleAction" 
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = target.fase.obiettivo_operativo_fase.id
	      @tipo_nodo_attivo = "Obiettivo"
		when "Opera" 
		  # questi sono per che parte di albero mostrare 
		  @nodo_attivo = target.id
	      @tipo_nodo_attivo = "Opera"
		else 
		  
        end 	
		@target_creato = @azione_creata
		@obiettivo_padre = a.fase.obiettivo_operativo_fase.id
		@tipo_target = "Azione"
		# questi sono per che parte di albero mostrare 
		  @nodo_attivo = @obiettivo_padre
	      @tipo_nodo_attivo = "Obiettivo"
	when "d"
		@dirigente = Person.find(id)
		@obiettivo_padre = nil
		@target_creato = 0 
		@tipo_target = ""
	end
	
	respond_to do |format|
	    format.js   { render :action => "aggiungi_target_form" }
    end
  end
  
  def rimuovi_indicatore_aggiungi_target_form
    puts "rimuovi_indicatore_aggiungi_target_form"
	puts params
	
	@descrizione = ""
    @denominazione = ""
    @descrizione_fase_sottostante = ""
    @denominazione_fase_sottostante = ""
    @dirigente =  nil
    @obiettivo_padre = nil
    @fase_padre = nil
    @azione_creata = nil
	@target_creato = 1
    @scelta = ""
    @selezionato = ""
    
   
    @lista_tipi = ["Obiettivo operativo"]
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@indicatore = Gauge.find(params[:person][:indicatore_id])
	@obiettivo_padre = params[:person][:obiettivo_padre]
	@tipo_target = params[:person][:tipo_target]
	
	Gauge.find(params[:person][:indicatore_id]).destroy
	@selezionato = "o-" + @obiettivo_padre
	
	respond_to do |format|
	    format.js   { render :action => "aggiungi_target_form" }
    end
	
  end
  
  def rimuovi_target_form
    puts "rimuovi_target_form"
	puts params
	@dirigente = Person.find(params[:person][:dirigente_id])
	@selezionato = params[:person][:selezionato]
	@tipo_target = ""
	
	@lista_tipi = ["Obiettivo operativo"]
	
	tipo = @selezionato.split("-")[0]
	id = @selezionato.split("-")[1]
	
	# attenzione per rimuovere bisogna mettere a posto le assegnazioni
	# o evitare di rimuovere con assegnazioni
	case tipo
	when "o"
		o = OperationalGoal.find(id)
		o.indicatori.each do | i |
		  i.destroy
		end 
		o.fasi.each do |f|
		  f.indicatori.each do |indicatore|
		    indicatore.destroy
		  end
		  f.azioni.each do |azione|
		    azione.indicatori do | indicatore |
			 indicatore.destroy
			end
		    azione.destroy
		  end
		  f.destroy
		end 
		o.destroy
		@selezionato = "d-" + @dirigente.id.to_s
		@target_creato = 0 
	when "f"
		f = Phase.find(id)
		f.indicatori.each do |indicatore|
		    indicatore.destroy
		end
		f.azioni.each do |azione|
		    azione.indicatori do | indicatore |
			 indicatore.destroy
			end
		    azione.destroy
		end
		f.destroy
		@selezionato = "d-" + @dirigente.id.to_s
		@target_creato = 0 
		
	when "a"
		a = SimpleAction.find(id)
		a.indicatori do | indicatore |
		  indicatore.destroy
		end
		a.destroy
		@selezionato = "d-" + @dirigente.id.to_s
		@target_creato = 0 
		
	when "d"
		
		@obiettivo_padre = nil
		@target_creato = 0 
		@tipo_target = ""
	end
    
	@selezionato =""
	
	respond_to do |format|
	    format.js   { render :action => "aggiungi_target_form" }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operational_goal
      @operational_goal = OperationalGoal.find(params[:id])
    end
	
	def check_login
	 if !logged_in? then redirect_to root_url end
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operational_goal_params
      params.require(:operational_goal).permit(:denominazione, :descrizione, :responsabile_principale_id, :obiettivo_di_ente, :obiettivo_di_gruppo, :obiettivo_di_struttura, :obiettivo_individuale, :attivita_ordinaria, :flag_variazione_peg, :indice_strategicita, :anno, :ente)
    end
end
