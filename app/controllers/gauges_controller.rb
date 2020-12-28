class GaugesController < ApplicationController
  before_action :set_gauge, only: [:show, :edit, :update, :destroy]

  # GET /gauges
  # GET /gauges.json
  def index
    @gauges = Gauge.all
  end

  # GET /gauges/1
  # GET /gauges/1.json
  def show
  end

  # GET /gauges/new
  def new
    @gauge = Gauge.new
  end

  # GET /gauges/1/edit
  def edit
  end

  # POST /gauges
  # POST /gauges.json
  def create
    @gauge = Gauge.new(gauge_params)

    respond_to do |format|
      if @gauge.save
        format.html { redirect_to @gauge, notice: 'Gauge was successfully created.' }
        format.json { render :show, status: :created, location: @gauge }
      else
        format.html { render :new }
        format.json { render json: @gauge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gauges/1
  # PATCH/PUT /gauges/1.json
  def update
    respond_to do |format|
      if @gauge.update(gauge_params)
        format.html { redirect_to @gauge, notice: 'Gauge was successfully updated.' }
        format.json { render :show, status: :ok, location: @gauge }
      else
        format.html { render :edit }
        format.json { render json: @gauge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gauges/1
  # DELETE /gauges/1.json
  def destroy
    @gauge.destroy
    respond_to do |format|
      format.html { redirect_to gauges_url, notice: 'Gauge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def importa
    
    filename = params[:file].original_filename
	puts "FILENAME " + filename
	importati = Gauge.importa(params[:file]) # viene lanciato il metodo del model
    @indicatori_obiettivi = importati[0]
	@indicatori_fasi = importati[1]
	@indicatori_azioni = importati[2]
	@target_non_trovati = importati[3]
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def indice_x_target
    @og = OperationalGoal.all
	@fa = Phase.all
	@az = SimpleAction.all
	@op = Opera.all
  end
  
  def gaugesxdirigente
    @dirigenti = []
    #@dirigenti = Person.dirigenti
	@dirigenti = filtro_dirigenti
  end
  
  def searchgaugesxdirigente
    puts "searchgaugesxdirigente"
	puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
    @dirigente = Person.find(params[:person][:id])
	@dirigente.obiettivi_responsabile.each do |o|
     @obiettivi<< o
    end
	@listaindicatori = Gauge.all
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
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
    @listaindicatori = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:person][:id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
  end
  
  def add_indicatore_to_og
    puts "PARAMETRI add_indicatore_to_og"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:operational_goal][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@indicatore = Gauge.find(params[:operational_goal][:id])
	
	# @indicatore.target = @obiettivo
	# @indicatore.save
	@obiettivo.indicatori<< @indicatore
	@obiettivo.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
  
  end
  
  def remove_indicatore_from_og
    puts "PARAMETRI remove_indicatore_from_og"
    puts params  
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:operational_goal][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:operational_goal][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	@indicatore = Gauge.find(params[:operational_goal][:indicatore_id])
	
	@obiettivo.indicatori.delete(@indicatore)
	@obiettivo.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def add_new_indicatore_to_og
    puts "PARAMETRI add_new_indicatore_to_og"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:gauge][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:gauge][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	
	if (params[:gauge][:nome].length > 2) && (params[:gauge][:descrizione].length > 2) && (params[:gauge][:descrizione_valore_misurazione].length > 2)
	  puts "NUOVO INDICATORE"
      g = Gauge.new
	  g.nome = params[:gauge][:nome]
	  g.descrizione = params[:gauge][:descrizione]
	  g.descrizione_valore_misurazione = params[:gauge][:descrizione_valore_misurazione]
	  g.valore_misurazione = params[:gauge][:valore_misurazione]
	  # g.target = @obiettivo
	  g.save
	  @obiettivo.indicatori<< g
	  @obiettivo.save
    end	
	
	
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def selectfasexdirigente
    puts "PARAMETRI selectfasexdirigente"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:gauge][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:gauge][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@fase = Phase.find(params[:gauge][:id])
	@azioni = @fase.azioni
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def remove_indicatore_fase
    puts "PARAMETRI remove_indicatore_fase"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fase = Phase.find(params[:phase][:fase_id])
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	
	@indicatore = Gauge.find(params[:phase][:indicatore_id])
	
	@fase.indicatori.delete(@indicatore)
	@fase.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def add_indicatore_fase
    puts "PARAMETRI add_indicatore_fase"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fase = Phase.find(params[:phase][:fase_id])
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	
	@indicatore = Gauge.find(params[:phase][:id])
	
	@fase.indicatori<< @indicatore
	@fase.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def selectazionexdirigente
    puts "PARAMETRI selectazionexdirigente"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:phase][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:phase][:obiettivo_id])
	
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@fase = Phase.find(params[:phase][:fase_id])
	@azioni = @fase.azioni
	
	@azione = SimpleAction.find(params[:phase][:id])
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
  end
  
  def add_new_indicatore_to_fase
    puts "PARAMETRI add_new_indicatore_to_fase"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:gauge][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:gauge][:obiettivo_id])
	
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@fase = Phase.find(params[:gauge][:fase_id])
	@azioni = @fase.azioni
	
	
	@listaindicatori = Gauge.all
	
	if (params[:gauge][:nome].length > 2) && (params[:gauge][:descrizione].length > 2) && (params[:gauge][:descrizione_valore_misurazione].length > 2)
	  puts "NUOVO INDICATORE"
      g = Gauge.new
	  g.nome = params[:gauge][:nome]
	  g.descrizione = params[:gauge][:descrizione]
	  g.descrizione_valore_misurazione = params[:gauge][:descrizione_valore_misurazione]
	  g.valore_misurazione = params[:gauge][:valore_misurazione]
	  g.target = @fase
	  g.save
    end	
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
	
	
  end
  
  def remove_indicatore_azione
    puts "PARAMETRI remove_indicatore_azione"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:simple_action][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:simple_action][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fase = Phase.find(params[:simple_action][:fase_id])
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@azione = SimpleAction.find(params[:simple_action][:azione_id])
	@indicatore = Gauge.find(params[:simple_action][:indicatore_id])
	
	@azione.indicatori.delete(@indicatore)
	@azione.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
  end
  
  def add_indicatore_azione
    puts "PARAMETRI add_indicatore_azione"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:simple_action][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:simple_action][:obiettivo_id])
	@obiettivi = @dirigente.obiettivi_responsabile
	@fase = Phase.find(params[:simple_action][:fase_id])
	@fasi = @obiettivo.fasi
	@azioni = @fase.azioni
	@azione = SimpleAction.find(params[:simple_action][:azione_id])
	@indicatore = Gauge.find(params[:simple_action][:id])
	
	@azione.indicatori<< @indicatore
	@azione.save
	
	@listaindicatori = Gauge.all
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
  end
  
  def add_new_indicatore_to_azione
    puts "PARAMETRI add_new_indicatore_to_azione"
    puts params
	@dirigente = nil
    @obiettivi = []
    @obiettivo = nil
    @fasi = []
    @fase = nil
    @azioni = []
    @azione = nil
    @listaindicatori = []
	
	@dirigente = Person.find(params[:gauge][:dirigente_id])
	@obiettivo = OperationalGoal.find(params[:gauge][:obiettivo_id])
	
	@obiettivi = @dirigente.obiettivi_responsabile
	@fasi = @obiettivo.fasi
	
	@fase = Phase.find(params[:gauge][:fase_id])
	@azioni = @fase.azioni
	
	@azione = SimpleAction.find(params[:gauge][:azione_id])
	
	@listaindicatori = Gauge.all
	
	if (params[:gauge][:nome].length > 2) && (params[:gauge][:descrizione].length > 2) && (params[:gauge][:descrizione_valore_misurazione].length > 2)
	  puts "NUOVO INDICATORE"
      g = Gauge.new
	  g.nome = params[:gauge][:nome]
	  g.descrizione = params[:gauge][:descrizione]
	  g.descrizione_valore_misurazione = params[:gauge][:descrizione_valore_misurazione]
	  g.valore_misurazione = params[:gauge][:valore_misurazione]
	  g.target = @azione
	  g.save
    end	
	
	respond_to do |format|
	    format.js   { render :action => "searchgaugesxdirigente"  }
    end
  end
  
   def targetsxdirigente
    @dirigenti = []
    #@dirigenti = Person.dirigenti
	@dirigenti = filtro_dirigenti
  end
  
  def searchtargetxdirigente
    puts params
	@obiettivi = []
	@opere = []
    @dirigente = Person.find(params[:person][:id])
	
	@opzionepeg = params[:opzionepeg] 
    @opzioneac = params[:opzioneac]
	@opzioneopere = params[:opzioneopere]
    puts "PEG " + (@opzionepeg != nil ? @opzionepeg.to_s : "-")
    puts "AC  " + (@opzioneac != nil ? @opzioneac.to_s : "-")
	puts "OPERE " + (@opzioneopere != nil ? @opzioneopere.to_s : "-")
	
	lista = @dirigente.obiettivi_responsabile
	lista.each do |o|
      if @opzioneac && @opzionepeg
	  
	    @obiettivi<< o
	  
	  elsif @opzioneac && !(@opzionepeg)
	    if o.attivita_ordinaria
	      @obiettivi<< o
	    end
	  elsif !(@opzioneac) && (@opzionepeg) 
	    if !o.attivita_ordinaria
	      @obiettivi<< o
	    end
	  end
    end	
	
	if @opzioneopere
	  @opere = @dirigente.opere
	end
	
	respond_to do |format|
	   format.js   { }
    end
  end
  
  def setmisurazione
    puts "setmisurazione"
    puts params
    
    @dirigente = Person.find(params[:gauge][:dirigente_id])
    @obiettivi = @dirigente.obiettivi_responsabile
	@opere = @dirigente.opere
	@opzionepeg = params[:gauge][:opzionepeg]
	@opzioneac = params[:gauge][:opzioneac]
	@opzioneopere = params[:gauge][:opzioneopere]
	valore = params[:gauge][:value]
	indicatore = Gauge.find(params[:gauge][:indicatore_id])
	indicatore.valore_misurazione = valore
	indicatore.save
    respond_to do |format|
	    format.js   { render :action => "searchtargetxdirigente"  }
    end
  
  end
  
  def aggiungi_indicatore_default_target
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
  
  def set_aggiungi_indicatore_default_target
    
    @target = nil
	id = params[:gauge][:target_id]
	tipo = params[:gauge][:target_type]
	@stringa_ricerca = params[:gauge][:stringa_ricerca]
	@risultati = []
	
    puts "tipo: " + tipo	
	case tipo
    when "Obiettivo"
        @obiettivo = OperationalGoal.find(id)
		@target = @obiettivo
		g = Gauge.new
	    g.nome = "Indicatore automatico avanzamento obiettivo (id: " +  @obiettivo.id.to_s + " )"
	    g.descrizione = "Avanzamento di: " + @obiettivo.denominazione
	    g.descrizione_valore_misurazione = " "
	    g.valore_misurazione = 0
	    g.target = @obiettivo
	    g.save
		
		
    when "Fase"
        @fase = Phase.find(id)
		@target = @fase
		g = Gauge.new
	    g.nome = "Indicatore automatico avanzamento fase (id: " +  @fase.id.to_s + " )"
	    g.descrizione = "Avanzamento di: " + @fase.denominazione
	    g.descrizione_valore_misurazione = " "
	    g.valore_misurazione = 0
	    g.target = @fase
	    g.save
		
		
	when "Azione"
        @azione = SimpleAction.find(id)
		@target = @azione
		g = Gauge.new
		g.nome = "Indicatore automatico avanzamento azione (id: " +  @azione.id.to_s + " )"
	    g.descrizione = "Avanzamento di: " + @azione.denominazione
	    g.descrizione_valore_misurazione = " "
	    g.valore_misurazione = 0
	    g.target = @azione
	    g.save
		
	when "Opera"
        @opera = Opera.find(id)
		@target = @opera
		g = Gauge.new
		g.nome = "Indicatore automatico avanzamento opera (id: " +  @opera.id.to_s + " )"
	    g.descrizione = "Avanzamento di: " + @opera.denominazione
	    g.descrizione_valore_misurazione = " "
	    g.valore_misurazione = 0
	    g.target = @opera
	    g.save
		
	end
	
	
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
    # respond_to do |format|
	    
	    # format.js   {render :action => "set_aggiungi_indicatore_default_target" }
    # end
	
	render "aggiungi_indicatore_default_target"
  
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gauge
      @gauge = Gauge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gauge_params
      params.require(:gauge).permit(:nome, :descrizione, :descrizione_valore_misurazione, :valore_misurazione)
    end
end
