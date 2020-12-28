class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :check_login, only: [ :show, :edit, :update, :destroy, :index, :create, :importa_pesi_target, :importaorganico, :setvalue, :valutazionedipendente,
                                      :importazionepagella, :tabellaxdirigente ]

  require 'roo'
  require 'roo-xls'
  
  # GET /people
  # GET /people.json
  def index
    @people = Person.all.order("cognome asc")
  end
  
  def lavora_come
   puts "lavora_come"
   @people = Person.all.order("cognome asc")
   
  end
 
  def set_lavora_come
   puts params
   id = params[:person][:id]
   person = Person.find(id)
   change_user(person)
   
   
  end
  
  def index_x_matricola
    @people = Person.all.order("matricola asc")
  end

  # GET /people/1
  # GET /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # GET /people/1/edit
  def modifica
   puts params
  end
  
  def modifica_update
   puts params
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def password
    puts params
	#puts params[:person_id] + " - " + current_user.id.to_s 
	
	if logged_in? && (params[:person_id] == current_user.id.to_s)
	  @person = Person.find(current_user.id)
	elsif super_user?
	  @person = Person.find(params[:person_id])
	else
	  redirect_to root_url
	end
  end
  
  def setpassword
    puts "SETPASSWORD"
	puts params[:person_id]
	@person = Person.find(params[:person_id])
	#@person.update(person_params)
    registra('setpassword ')
  end
  
  def importazione_pesi_target
  
  end
  
  
  def importa_pesi_target
    filename = params[:file].original_filename
	opzione_crea_mancanti = params[:crea_mancanti]
	puts "FILENAME " + filename
    result = Person.importa_pesi_target(params[:file],opzione_crea_mancanti ) # viene lanciato il metodo del model
	@pesi_importati = result[0]
	@righe_tralasciate = result[1]
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importa
    
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    Person.import(params[:file]) #pure viene lanciato il metodo del model
	@aggiunte = Person.where(filename_importazione: filename)
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata

	
  end
  
  def importazione_csv
  
    
  end
  
  def importa_csv
    
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    result = Person.import_csv(params[:file]) #pure viene lanciato il metodo del model
	puts result[0].length
	puts result[1].length
	# @aggiunte = []
	# @doppi = []
	@aggiunte = result[0]
	@doppi = result[1]
    @uffici_nuovi = result[2]	
	
  end
  
 
  def importaorganico
    @dipendenti = []
	@dipendentinontrovati = []
	@dipendentiinsdope = []
	@porcherie = []
	@uffici = []
	@o = nil
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    
	xls = Roo::Spreadsheet.open(params[:file])
	xls.each_with_pagename do |name, sheet|
	 #last_row    = scheda_obiettivi.last_row
	 #for row in 1..last_row
     sheet.each do |riga| 
       cognome = riga[2]
	   if cognome != nil
	     cognome = cognome.upcase
	   else
	     cognome = ""
	   end
       nome = riga[3]
	   if nome != nil
	     nome = nome.upcase
	   else 
	     nome = ""
	   end
	   cos = riga[1] 
	   qualifica = riga[4]
	   categoria = riga[5]
	   ruolo = riga[6]
	   tempo = riga[7]
       trovato = Person.cerca(cognome + " " + nome)
	   # se troviamo un nome uguale
       if trovato != nil
         puts cognome + " " + nome
		 n = Hash.new
		 n[:matricola] = trovato.matricola
		 p=trovato
		 p.cos = cos
		 p.qualifica = qualifica
		 p.categoria = categoria
		 p.ruolo = ruolo
		 p.tempo = tempo
		 if @o != nil
		   p.ufficio = @o # ufficio è una relazione
		 end
		 p.save
		 n[:nomecognome] = trovato.nome  + " " + trovato.cognome
		 @dipendenti << n
	   # non troviamo un nome, potrebbe essere un ufficio
       elsif riga[2] != nil && riga[2].start_with?( 'DIP ', 'SERVIZIO', 'u.s', 'U.O.', 'UO', 'UN ORG', 'U. ORG', 'UOrg', 'UFFICIO')
	     ufficio =  riga[2]
		 if Office.where("lower(nome) LIKE lower(?)", ufficio).length == 0
		  @o = Office.create(:nome => ufficio.upcase)
		 else
		  @o = Office.where("lower(nome) LIKE lower(?)", ufficio).first
		 end
		 u = Hash.new
		 u[:nome] = ufficio.upcase
		 @uffici << u
	
	   
	   elsif riga[2] != nil && riga[3] != nil
	     # non trovato in People
	     # non è un ufficio ma ha qualcosa, cerco nello sdope
	     # vado a controllare nello SDOPE se esiste
		 trovato_in_sdope =  false
	     SdopeRow.all.each do |sr| 
            if sr.nominativo.gsub(/\s+/, "").upcase == (riga[2] + riga[3]).gsub(/\s+/, "").upcase 
			  # ho trovato lo stesso nome nello sdope
			  trovato_in_sdope = true
			  pr = Person.new
			  pr.cognome = cognome
			  pr.nome = nome
			  pr.matricola = sr.matricola.rjust(7,'0')
			   Office.all.each do |o|
			    if riga[2].gsub(/\s+/, "").upcase == o.nome.gsub(/\s+/, "").upcase
			      pr.ufficio = o
			    end
			   end
			  pr.password = 'comune'
			  pr.password_confirmation = 'comune'
			  if Person.where("matricola LIKE ?", pr.matricola).length == 0 
			   pr.save!
			  end
			  trovato = Hash.new
			  trovato[:nomecognome] = nome  + " " + cognome
			  @dipendentiinsdope << trovato
			
            end		 
	     end
		 if trovato_in_sdope == false
		    nt = Hash.new
            nt[:denominazione] = riga[2] + " " + riga[3]
            @dipendentinontrovati << nt
		 end
	  else
		 porcheria = Hash.new
		 porcheria[:riga2] = riga[2]
		 porcheria[:riga3] = riga[3]
		 @porcherie << porcheria
	  end
	   
	   
  end
 end # ciclo sui fogli di lavoro
end
	
def dipendenti_x_dirigente
 registra('dipendenti_x_dirigente ')
 @dirigenti = []
 
 @dirigenti = filtro_dirigenti.sort_by{|d| d.cognome}
end

def searchxdirigente
  puts params
  dirigente = Person.find(params[:person][:id])
  @dirigente = dirigente
  @risultati = []
  dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
	if s.dipendenti_ufficio.length > 0
     @risultati << item
	end
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      #@risultati << item
	  if o.dipendenti_ufficio.length > 0
        @risultati << item
	  end
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       #@risultati << item
	   if oo.dipendenti_ufficio.length > 0
        @risultati << item
	   end
	  end
    end
  end
  respond_to do |format|
	   format.js   { }
  end
end

def misurazionixpersonexdirigente
 @dirigenti = []
 @dirigenti = filtro_dirigenti

end

def misurazionisearchxdirigente
  puts params
  @dirigente = Person.find(params[:person][:id])
  @risultati = []
  @dirigenti = []
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti
  @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	  end
    end
  end
  respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" } 
  end
end

def conferma_tutti_misurazione
 registra('conferma_tutti_misurazione ')
 puts params
  @dirigente = Person.find(params[:person][:dirigente_id])
  @risultati = []
  @dirigenti = []
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti
  @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	  end
    end
  end
  
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti
	
  @dipendenti = @dirigente.dipendenti_sotto
  
  @dipendenti.each do |dipendente|  
	
	@targets = []
	lista1 = dipendente.obiettivi
	lista2 = dipendente.fasi
	lista3 = dipendente.azioni
	lista4 = dipendente.obiettivi_altro_responsabile
	
	lista5 = dipendente.obiettivi_responsabile
	lista6 = dipendente.fasi_responsabile
	lista7 = dipendente.azioni_responsabile
	
	lista8 = dipendente.opere_assegnate
	lista9 = dipendente.opere
	
	if lista1.length > 0
	 lista1.each do |t|
	   @targets<< t
	 end
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	
	lista5.each do |t|
	  @targets<< t
	end
	
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
	
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	@targets.each do |target|
	  target_type = target.tipo
	  # case target_type 
       # when "Obiettivo"    #compare to 1
        # target = OperationalGoal.find(target_id) 
       # when "Fase"    #compare to 2
        # target = Phase.find(target_id) 
	   # when "Azione"
	    # target = SimpleAction.find(target_id)
	   # when "Opera"
	    # target = Opera.find(target_id)
       # else
        # puts "it was something else"
      # end
	  puts "target_id: " + target.id.to_s
	  puts "target_type: " + target_type
	  val = TargetDipendenteEvaluation.where(target: target, dipendente: dipendente).first
	  if val == nil && target != nil && dipendente != nil
	    puts "Creo nuova valutazione target dipendente"
	    val = TargetDipendenteEvaluation.new
	       val.dipendente = dipendente
	       val.target = target
		   val.dirigente = @dirigente
		   val.valore = target.valore_totale
	       val.save
	  else
	    val.valore = target.valore_totale
		val.save
	  end
	end
    
	end
	
  
  
  respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" } 
  end

end

def pesixpersonexdirigente
 @dirigenti = []
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti

end

def pesisearchxdirigente
  puts params
  @dirigente = Person.find(params[:person][:id])
  @risultati = []
  @dirigenti = []
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti
  @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	  end
    end
  end
  respond_to do |format|
	   format.js   { }
  end
end


def tabellaxdirigente
 registra('tabellaxdirigente ')
 @dirigenti = []
 
 #if  current_user.cognome == "CHIANDONE"
  #@dirigenti = Person.dirigenti
  # con il filtro faccio vedere solo quello che deve vedere
  @dirigenti = filtro_dirigenti
 #else
 # @dirigenti<< current_user
 #end
 @dirigenti = @dirigenti.sort_by{|d| d.cognome}
end

def showtabellaxdirigente
  puts params
  @dirigente = Person.find(params[:person][:id])
  registra('showtabellaxdirigente ' + @dirigente.nominativo)
  @risultati = []
  @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
  end
  
  # nel caso del segretario vanno aggiunti tutti i dirigenti
  if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	dirigenti.each do |d|
	 if d.dirige.length > 0
	  item = Hash.new
      item[:ufficio] = d.dirige.first  #questo potrebbe essere vuoto 
      item[:dipendenti] = d
      @risultati << item
	 end
	end
  end
  respond_to do |format|
	   format.js   { }
  end
end

def show_tabella_dirigente
  # forse non serve
  puts params
  @dirigente = Person.find(params[:person][:id])
  @risultati = []
  @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
  end
  if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	dirigenti.each do |d|
	 item = Hash.new
     item[:ufficio] = d.dirige.first
     item[:dipendenti] = d
     @risultati << item
	end
  end
  respond_to do |format|
	   format.js   { }
  end
end


def valutazionedipendente

   @person = Person.find(params[:id])
   @dirigente = Person.find(params[:format])

end

 def valutazionedipendente
   puts "valutazionedipendente"
   puts params
   @valutazioni = []
   @person = Person.find(params[:id])
   @dirigente = Person.find(params[:format])
   registra('valutazionedipendente ' + @dirigente.nominativo + " " + @person.nominativo)
   if @person.qualification != nil
    tipo = @person.qualification.denominazione
    case tipo
    when "Dirigente"
     @fattori = Vfactor.where('peso_dirigenti > 0')
	when "Segretario"
     @fattori = Vfactor.where('peso_sg > 0')
    when "P.O."
     @fattori = Vfactor.where('peso_po > 0')
    when "Preposto"
     @fattori = Vfactor.where('peso_preposti > 0')
    when "NonPreposto"
     @fattori = Vfactor.where('peso_nonpreposti > 0')
    end
	# check se è coerente 
	@person.valutazioni.each do |v|
	 # cancello se ha un puntatore a nil
	 if v.vfactor == nil
	  v.destroy
	  @person.save
	 end
	 # per ogni valutazione controllo se è coerente con la qualifica
	 # quelle che non sono coerenti le cancello (potrebbe essere cambiata la qualifica
	 if v.vfactor != nil
	  tipo = @person.qualification.denominazione
      case tipo
      when "Dirigente"
	   if v.vfactor.peso_dirigenti <= 0
	    v.destroy
	    @person.save
	   end 
	  when "Segretario"
       if v.vfactor.peso_sg <= 0
	    v.destroy
	    @person.save
	   end 
      when "P.O."
	   if v.vfactor.peso_po <= 0
	    v.destroy
	    @person.save
	   end 
      when "Preposto"
	   if v.vfactor.peso_preposti <= 0
	    v.destroy
	    @person.save
	   end 
      when "NonPreposto"
       if v.vfactor.peso_nonpreposti <= 0
	    v.destroy
	    @person.save
	   end
     end
	end
	 
	end
	
    if @person.valutazioni.length != @fattori.length
	  @fattori.order("ordine_apparizione asc").each do |f|
	    if @person.valutazioni.where(vfactor: f).length == 0
	      v = Valutation.new
	      v.person = @person
	      v.vfactor = f
		  v.state = "open"
	      v.value = 0
	      v.year = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : ' - '
	      v.save
	    end  
	   end
	 end
	 
	 
	@person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc").each do |v|
	     @valutazioni << v
	end
   end
   render "valutazionedipendente_notextarea"	
 end 
 
 def setvalue
  puts params 
  
  @person = Person.find(params[:valutazione][:person_id])
  @dirigente = Person.find(params[:valutazione][:dirigente_id])
  registra('setvalue ' + @dirigente.nominativo)
  valutazione = Valutation.find(params[:valutazione][:valutation_id]) 
  factor = Vfactor.find(params[:valutazione][:vfactor_id]) 
  check = valutazione.person == @person && valutazione.vfactor == factor
  if check 
    puts "CORRETTO"
	valutazione.value = params[:valutazione][:value]
	valutazione.save
  end  
  @valutazioni = @person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
  respond_to do |format|
	   format.js   {render :action => "setvalue" }
  end
 end 
 
 def setvalueall
 
  puts "SETVALUEALL"
  puts params 
  
  @person = Person.find(params[:valutazione][:person_id])
  @dirigente = Person.find(params[:valutazione][:dirigente_id])
  registra('setvalueall ' + @dirigente.nominativo + " " + @person.nominativo)
 
  
  numero_voti = params[:valutazione][:numero_voti]
  person_id = params[:valutazione][:person_id]
  
  
  @valutazioni = @person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
  @valutazioni.each do |v|
    stringa = @person.id.to_s + "_" + v.id.to_s + "_" + v.vfactor.id.to_s
	puts "stringa :" + stringa
	valore = params[:valutazione][stringa]
	
	if valore != nil
	 v.value = valore
	 v.state = "open"
	 v.save
	 puts "valore " + params[:valutazione][stringa] + " " + valore.to_s
	else
	 puts "stringa non trovata: " + stringa
	end
  end
  @valutazioni = @person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
  @person = Person.find(params[:valutazione][:person_id])
  
  #render "valutazionedipendente2"
  respond_to do |format|
	   format.js   {render :action => "setvalueall_notextarea" }
	   format.html   {render  'valutazionedipendente' }
  end
 end 
 
 def setwheight
   puts params 
   @dipendente = nil
   destinazione = ""
   if params[:goal_assignment] != nil
    @dirigente = Person.find(params[:goal_assignment][:dirigente_id])
	destinazione = params[:goal_assignment][:from]
   end
   if params[:phase_assignment] != nil
    @dirigente = Person.find(params[:phase_assignment][:dirigente_id])
	destinazione = params[:phase_assignment][:from]
   end
   if params[:action_assignment] != nil
    @dirigente = Person.find(params[:action_assignment][:dirigente_id])
	destinazione = params[:action_assignment][:from]
   end
   if params[:opera_assignment] != nil
    @dirigente = Person.find(params[:opera_assignment][:dirigente_id])
	destinazione = params[:opera_assignment][:from]
   end
   
   @risultati = []
   @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	  end
    end
  end
  if params[:goal_assignment] != nil
    ga = GoalAssignment.find(params[:goal_assignment][:operational_goal_assignment_id])
	ga.wheight = params[:goal_assignment][:value]
	ga.save
	@dipendente = ga.persona
  end
  if params[:phase_assignment] != nil
    pa = PhaseAssignment.find(params[:phase_assignment][:phase_assignment_id])
	pa.wheight = params[:phase_assignment][:value]
	pa.save
	@dipendente = pa.persona
  end
  if params[:action_assignment] != nil
    aa = SimpleActionAssignment.find(params[:action_assignment][:simple_action_assignment_id])
	aa.wheight = params[:action_assignment][:value]
	aa.save
	@dipendente = aa.persona
  end
  if params[:opera_assignment] != nil
    opa = OperaAssignment.find(params[:opera_assignment][:opera_assignment_id])
	opa.wheight = params[:opera_assignment][:value]
	opa.save
	@dipendente = opa.persona
  end
  
  if destinazione == "targetdipendentixdirigente"
	 respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" }
	 end
  elsif destinazione == "modifica_valutazioni_target_dipendente"
	 respond_to do |format|
	 format.js   {render :action => "modifica_valutazioni_target_dipendente" }
	 end
  else 
	 respond_to do |format|
	    format.js   {render :action => "pesisearchxdirigente" }
     end
  end
   
 
 end
 
 def setvalutazionedirigente
    # setta la valutazione data dal dirigente di un obiettivo per un dipendente
	puts "SETVALUTAZIONEDIRIGENTE"
	puts params
	destinazione = params[:target_dipendente_evaluation][:from] 
    @dipendente = Person.find(params[:target_dipendente_evaluation][:person_id])
	@dirigente = Person.find(params[:target_dipendente_evaluation][:dirigente_id])
	@dipartimento = @dirigente.dirige.first
	@ufficio = @dipendente.ufficio
	
	
	target_id = params[:target_dipendente_evaluation][:target_id]
	target_type = params[:target_dipendente_evaluation][:target_type]
	
	valore = params[:target_dipendente_evaluation][:value]
	
	@risultati = []
    @dirigente.dirige.each do |s|
     item = Hash.new
     item[:ufficio] = s
     item[:dipendenti] = s.dipendenti_ufficio
     @risultati << item
     s.children.each do |o|
       item = Hash.new
       item[:ufficio] = o
       item[:dipendenti] = o.dipendenti_ufficio
       @risultati << item
       o.children.each do |oo|
	    item = Hash.new
        item[:ufficio] = oo
        item[:dipendenti] = oo.dipendenti_ufficio
        @risultati << item
	   end
     end
    end
	
	case target_type 
     when "Obiettivo"    #compare to 1
      target = OperationalGoal.find(target_id) 
     when "Fase"    #compare to 2
      target = Phase.find(target_id) 
	 when "Azione"
	  target = SimpleAction.find(target_id)
	 when "Opera"
	  target = Opera.find(target_id)
     else
      puts "it was something else"
    end
	puts "target_id: " + target.id.to_s
	puts "target_type: " + target_type
	val = TargetDipendenteEvaluation.where(target: target, dipendente: @dipendente).first
	if val == nil && target != nil && @dipendente != nil
	  puts "Creo nuova valutazione target dipendente"
	  val = TargetDipendenteEvaluation.new
	      val.dipendente = @dipendente
	      val.target = target
		  val.dirigente = @dirigente
		  val.valore = valore
	      val.save
		  registra('setvalutazionedirigente ' + @dirigente.nominativo + " " + @dipendente.nominativo + " target_id:" + target.id.to_s + "  valore:" + valore.to_s)
	else
	  puts "Modifico valutazione target dipendente : ID " + val.id.to_s
	  val.valore = valore
	  val.save
	  registra('setvalutazionedirigente ' + @dirigente.nominativo + " " + @dipendente.nominativo + " target_id:" + target.id.to_s + "  valore:" + valore.to_s)
	end
	
    @dipendenti = @dirigente.dipendenti_sotto
	
	@targets = []
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	
	lista8 = @dipendente.opere
	lista9 = @dipendente.opere_assegnate
	
	
	lista1.each do |t|
	  @targets<< t
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	lista5.each do |t|
	  @targets<< t
	end
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
	
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	puts "@targets.length"
	puts @targets.length
	#val = TargetDipendenteEvaluation.where(dipendente: @dipendente, target: t).first
	
	
	if destinazione == "targetdipendentixdirigente"
	 respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" }
	 end
    elsif destinazione == "modifica_valutazioni_target_dipendente"
	 respond_to do |format|
	 format.js   {render :action => "modifica_valutazioni_target_dipendente" }
	 end
	elsif destinazione == "scheda_valutazione_obiettivi_dipendente"
	 respond_to do |format|
	 format.js   {render :action => "scheda_valutazione_obiettivi_dipendente" }
	 end
    else 
	 respond_to do |format|
	    format.js   {render :action => "pesisearchxdirigente" }
     end
    end
    
 end
 
 def schedavalutazionedipendentexls 
 
    persona = Person.find(params[:schedaxls][:person_id])
	dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra('schedavalutazionedipendentexls ' + dirigente.nominativo + " " + persona.nominativo)
    data_scheda = Time.now.strftime("%d-%m-%Y")
    nomefile = "SchedaDipendente_" + persona.cognome + "_" + persona.nome + "_" + data_scheda + ".xlsx"
	exfile = WriteXLSX.new(nomefile)
	#worksheet_comportamento = exfile.add_worksheet(sheetname = 'Scheda comportamento')
	scheda_excel_comportamento(persona, dirigente, exfile)
	scheda_excel_obiettivi(persona, dirigente, exfile)
	
	
	# worksheet_obiettivi = exfile.add_worksheet(sheetname = 'Scheda obiettivi')
	
	# format1 = exfile.add_format # Add a format
	# format1.set_font('Century Gothic')
	# format1.set_size(10)
	# format1.set_align('center')
	# format1.set_valign('center')
	
	# format2 = exfile.add_format # Add a format
	# format2.set_font('Arial')
	# format2.set_size(10)
	# format2.set_align('center')
	# format3 = exfile.add_format({
    # 'bold': 1,
    # 'border': 1,
    # 'valign': 'vcenter',
    # 'fg_color': 'yellow'})

	# format3.set_font('Arial')
	# format3.set_size(8)
	# format3.set_align('right')
	# format3.set_bold
	
	# format3white = exfile.add_format({
    # 'bold': 1,
    # 'border': 1,
    # 'valign': 'vcenter'})

	# format3.set_font('Arial')
	# format3.set_size(8)
	# format3.set_align('right')
	# format3.set_bold
	
	
	
	# format4 = exfile.add_format # Add a format
	# format4.set_font('Century Gothic')
	# format4.set_size(10)
	# format4.set_align('left')
	# format4.set_bottom_color('cyan')
	# format4.set_bg_color('plum')
	# format4.set_top_color('black')
	# format4.set_bold
	# format4.set_text_wrap() ;
	
	# format5 = exfile.add_format # Add a format
	# format5.set_font('Century Gothic')
	# format5.set_size(8)
	# format5.set_align('left')
	# format5.set_bottom_color('gray')
	# format5.set_top_color('black')
	
	# format5right = exfile.add_format # Add a format
	# format5right.set_font('Arial')
	# format5right.set_size(8)
	# format5right.set_align('right')
	# format5right.set_bottom_color('gray')
	# format5right.set_top_color('black')
	
	# format6 = exfile.add_format
	# format6.set_font('Century Gothic')
	# format6.set_size(8)
	# format6.set_align('left')
	# format6.set_valign('vcenter')
	# format6.set_text_wrap() ;
	
	# format7firme = exfile.add_format # Add a format
	# format7firme.set_font('Century Gothic')
	# format7firme.set_size(6)
	# format7firme.set_align('left')
	# format7firme.set_bottom_color('cyan')
	# format7firme.set_bg_color('plum')
	# format7firme.set_top_color('black')
	# format7firme.set_bold
	# format7firme.set_valign('vcenter')
	# format7firme.set_text_wrap() ;
	# #format6.set_bold
	
	# # format6 = exfile.add_format({
    # # 'bold': 1,
    # # 'border': 1,
    # # 'align': 'center',
    # # 'valign': 'vcenter',
	# # 'font': 'Calibrì',
	# # 'size': 11,
    # # 'fg_color': 'cyan'})
	# # format6.set_text_wrap()
	
	# format7 = exfile.add_format({
    # 'bold': 1,
    # 'border': 1,
    # 'align': 'center',
    # 'valign': 'vcenter',
	# 'font': 'Calibrì',
	# 'size': 9})
	# format7.set_text_wrap()
	
	
	# # DA TOGLIERE
	# # worksheet_comportamento.set_column('A:A', 40)
	# # worksheet_comportamento.set_column('B:B', 10)
	# # worksheet_comportamento.set_column('C:C', 10)
	# # worksheet_comportamento.set_column('D:D', 10)
	# # worksheet_comportamento.set_column('E:E', 10)
	# # worksheet_comportamento.set_column('F:F', 10)
	# # worksheet_comportamento.set_column('G:G', 10)
	# # worksheet_comportamento.set_column('H:H', 10)
		
	# # worksheet_comportamento.merge_range('A1:D1', 'SCHEDA DI VALUTAZIONE INDIVIDUALE - AREA COMPORTAMENTALE ', format1)
	# # worksheet_comportamento.set_row(0, 50)
	
	# # worksheet_comportamento.write(1, 2, 'ANNO', format1)
	# # worksheet_comportamento.write(1, 3, (Setting.where(denominazione: 'anno').length >0 ?  Setting.where(denominazione: 'anno').first.value : " - "), format1)
	
	# # worksheet_comportamento.merge_range('A3:B3', 'Nome Cognome', format4)
	# # worksheet_comportamento.merge_range('C3:D3', persona.nome + " " + persona.cognome, format4)
	# # worksheet_comportamento.merge_range('A4:B4', 'Nr Matricola', format4)
	# # worksheet_comportamento.merge_range('C4:D4', persona.matricola, format4)
	# # worksheet_comportamento.merge_range('A5:B5', 'Qualifica', format4)
	# # worksheet_comportamento.merge_range('C5:D5', persona.qualification != nil ? persona.qualification.denominazione : '-', format4)
	# # worksheet_comportamento.merge_range('A6:B6', 'Categoria', format4)
	# # worksheet_comportamento.merge_range('C6:D6', persona.categoria != nil ? persona.categoria : '-', format4)
	# # worksheet_comportamento.merge_range('A7:B7', 'Dirigente', format4)
	# # worksheet_comportamento.merge_range('C7:D7', dirigente.nome + " " + dirigente.cognome, format4)
	
	# # worksheet_comportamento.merge_range('A9:D9', 'Valutazione comportamento', format1)
	
	# # worksheet_comportamento.write(10, 0, 'Denominazione Fattore', format4)
	# # worksheet_comportamento.write(10, 1, 'Peso', format4)
	# # worksheet_comportamento.write(10, 2, 'Voto', format4)
	# # worksheet_comportamento.write(10, 3, 'Voto pesato', format4)
	
	# # indice_riga = 11 
	# # numeratore = '(0'
	# # denominatore = '(0'
	# # somma_pesi = '(0'
	# # persona.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc").each do |v|
	 # # if v != nil
	    # # if v.vfactor != nil 
		 # # denominazione = v.vfactor.denominazione
		 # # #denominazione = v.vfactor.descrizione
		# # else 
		 # # denominazione = "-"
		# # end
		# # #worksheet_comportamento.merge_range('A7:D7', denominazione, format3)
		# # #d = denominazione.gsub(/|/, "\x0A")
		# # d = denominazione
		# # # righe = denominazione.split(/|/)
		# # # righe.each do |r|
		 # # # d = d + r + "\x0A"
		# # # end
		# # worksheet_comportamento.write(indice_riga, 0, d, format6)
		# # if v.vfactor != nil 
		 # # peso = v.vfactor.peso(persona) 
		# # else 
		 # # peso =  "-"
		# # end
		# # worksheet_comportamento.write(indice_riga, 1, peso, format3white)
	    # # if v.value != nil 
		 # # valore = v.value 
		 
		# # else 
		 # # valore =  "-"
		# # end
		# # worksheet_comportamento.write(indice_riga, 2, valore, format3)
		# # worksheet_comportamento.write(indice_riga, 3, '=0.1*B'+(indice_riga+1).to_s+'*C'+(indice_riga+1).to_s, format3white)
		# # indice_riga = indice_riga + 1
		# # numeratore = numeratore + '+C' + indice_riga.to_s + '*B' + indice_riga.to_s
		# # somma_pesi = somma_pesi + '+B'+ indice_riga.to_s 
		# # denominatore = denominatore + '+B'+ indice_riga.to_s + '*' + (v.vfactor.max).to_s
		# # worksheet_comportamento.set_row(indice_riga, 40)
	 # # end
	# # end
	# # numeratore = numeratore + ')' 
	# # denominatore = denominatore  + ')'
	# # somma_pesi = somma_pesi  + ')'
	# # # worksheet_comportamento.write(indice_riga, 0, 'Media pesata')
	# # # worksheet_comportamento.write(indice_riga, 3, '=' + numeratore + '/' + somma_pesi)
	# # # indice_riga = indice_riga + 1
	# # worksheet_comportamento.write(indice_riga, 0, 'Punteggio Finale')
	# # worksheet_comportamento.write(indice_riga, 3, '=(100*' + numeratore + '/' + denominatore + ')')
	# # indice_riga = indice_riga + 1
	
	# # indice_riga = indice_riga + 2
	# # worksheet_comportamento.write(indice_riga, 0, 'Data _____________________________ ', format7firme)
	# # worksheet_comportamento.set_row(indice_riga, 30)
	# # indice_riga = indice_riga + 1
	
	# # worksheet_comportamento.write(indice_riga, 0, "Firma del dipendente per presa visione della valutazione assegnata dal dirigente \x0A  \x0A ________________________________", format7firme)
	# # worksheet_comportamento.merge_range('C'+(indice_riga+1).to_s+':D'+(indice_riga+1).to_s, "firma del dirigentee \x0A \x0A _______________________", format7firme)
	
	# # worksheet_comportamento.set_row(indice_riga, 60)
	# # indice_riga = indice_riga + 1
	
	
	# # #indice_riga = indice_riga + 1
	# # descrizione = Setting.where(denominazione: "descrizione_punteggi").first 
    # # testo = (descrizione != nil ? descrizione.descrizione : " - " ) 

    # # testo.each_line do |s| 
       # # stringa_colonne = 'A' + indice_riga.to_s + ':D' + indice_riga.to_s
	   # # worksheet_comportamento.merge_range(stringa_colonne, s, format5)
	   # # indice_riga = indice_riga + 1
    # # end
	
	
	
	exfile.close
	send_file nomefile
   
 end
  
 def pagellapdf
    #registra('PAGELLAPDF')
    # 
	puts params
    
	person = Person.find(params[:pagellapdf][:person_id])
	
	pdf = crea_pagellapdf(person)
			 
    filename = "Valutazione_" + person.cognomenomenospaces + ".pdf"
	#pdf.render_file filename
	#file = File.open(filename, "rb")
    #contents = file.read
    #file.close
	#send_data file, filename: filename, type: 'application/pdf'
	send_data pdf.render, filename: filename, type: 'application/pdf'
	
  end
  
  def excel_organico
	registra('excel_organico')
    data_organico = Time.now.strftime("%d-%m-%Y")
    nomefile = "Organico_" + data_organico + ".xlsx"	
	exfile = WriteXLSX.new(nomefile)
	worksheet1 = exfile.add_worksheet(sheetname = 'Informazioni Generali')
	worksheet2 = exfile.add_worksheet(sheetname = 'Lista Dipendenti')
	worksheet3 = exfile.add_worksheet(sheetname = 'Lista Uffici')
	worksheet4 = exfile.add_worksheet(sheetname = 'Dipendenti x Ufficio')
	format1 = exfile.add_format # Add a format
	format1.set_font('Arial')
	format1.set_size(28)
	format1.set_align('center')
	format2 = exfile.add_format # Add a format
	format2.set_font('Arial')
	format2.set_size(14)
	format2.set_align('center')
	format3 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'yellow'})

	format3.set_font('Arial')
	format3.set_size(10)
	format3.set_align('left')
	format3.set_bold
	format3.set_bottom_color('cyan')
	format3.set_top_color('red')
	format4 = exfile.add_format # Add a format
	format4.set_font('Arial')
	format4.set_size(10)
	format4.set_align('left')
	
	format5 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'gray'})
	
	format6 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 11,
    'fg_color': 'cyan'})
	format6.set_text_wrap()
	
	
	
	format7 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()

	format8 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'right',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()
	
	format_servizio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'red',
	'size': 10})
	
	format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'yellow',
	'size': 10})
	
	format_dipendente = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'white',
	'size': 8})
	
	format_dipendente_right = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'right',
    'valign': 'vcenter',
    'fg_color': 'white',
	'size': 8})
	
	#worksheet1.set_column('A:J', nil, nil, 0, 1)
	
	worksheet1.merge_range('A3:J3', 'Organico', format1)
	ente = Setting.where(denominazione: "ente").first != nil ? Setting.where(denominazione: "ente").first.value : " - "
	anno = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : " - "
	worksheet1.merge_range('A4:J4', ente, format2)
	worksheet1.merge_range('A5:J5', anno, format2)
	
	
	worksheet2.set_column('A:A', 5)
	worksheet2.set_column('B:B', 30)
	worksheet2.set_column('C:C', 30)
	worksheet2.set_column('D:D', 10)
	worksheet2.set_column('E:E', 30)
	worksheet2.set_column('F:F', 50)
	worksheet2.set_column('G:G', 50)
	worksheet2.set_column('H:H', 30)
	worksheet2.set_column('I:I', 30)
	
	
	
	worksheet2.write(0, 0, "Nr", format6)
	worksheet2.write(0, 1, "Nome", format6)
	worksheet2.write(0, 2, "Cognome", format6)
	worksheet2.write(0, 3, "Matricola", format6)
	worksheet2.write(0, 4, "Ufficio", format6)
	worksheet2.write(0, 5, "Email", format6)
	worksheet2.write(0, 6, "Qualifica", format6)
	worksheet2.write(0, 7, "Categoria", format6)
	worksheet2.write(0, 8, "Ruolo", format6)
	worksheet2.write(0, 9, "Tempo", format6)
	
	
	lista = Person.order(matricola: :asc)
	lista.each_with_index do |r,i|
	 worksheet2.write(1+i, 0, (i+1).to_s, format7)
	 worksheet2.write(1+i, 1, r.nome, format7)
	 worksheet2.write(1+i, 2, r.cognome, format7)
	 worksheet2.write(1+i, 3, r.matricola.to_s, format8)
	 uff = '-'
	 if r.ufficio != nil
       uff = r.ufficio.nome
     else
	  if r.dirige.length != 0
         uff = r.dirige.first.nome
      else				 
          "-" 
	  end
	 end
	  
	worksheet2.write(1+i, 4, uff, format8) 
	worksheet2.write(1+i, 5, (r.email != nil ? r.email.to_s : ""), format8) 
    worksheet2.write(1+i, 6, r.qualifica, format8) 
    worksheet2.write(1+i, 7, r.stringa_categoria, format8) 
    worksheet2.write(1+i, 8, r.ruolo, format8)
    worksheet2.write(1+i, 9, r.tempo, format8)	
	end 
	
	
	
	worksheet3.set_column('A:A', 5)
	worksheet3.set_column('B:B', 30)
	worksheet3.set_column('C:C', 30)
	worksheet3.set_column('D:D', 30)
	worksheet3.set_column('E:E', 30)
	worksheet3.set_column('F:F', 30)
	worksheet3.set_column('G:G', 30)
	worksheet3.set_column('H:H', 30)
	worksheet3.set_column('I:I', 30)
	worksheet3.set_column('L:L', 30)
	worksheet3.set_column('M:M', 30)
	
	
	
	worksheet3.write(0, 0, "Nr", format6)
	worksheet3.write(0, 1, "Nome", format6)
	worksheet3.write(0, 2, "Tipo", format6)
	worksheet3.write(0, 3, "Direttore", format6)
	worksheet3.write(0, 4, "Ufficio padre", format6)
	worksheet3.write(0, 5, "Ufficio figlio", format6)
	
    lista = Office.order(nome: :asc)
	lista.each_with_index do |o,i|
	 worksheet3.write(1+i, 0, (i+1).to_s, format7)
	 worksheet3.write(1+i, 1, o.nome, format7)
	 worksheet3.write(1+i, 2, o.office_type != nil ? o.office_type.denominazione : " - ", format7)
	 worksheet3.write(1+i, 3, o.director != nil ? (o.director.cognome + " " + o.director.nome) : " - ", format7)
	 worksheet3.write(1+i, 4, o.parent !=nil ? o.parent.nome : " - ", format7)
	 o.children.each_with_index do |c,j|
	   worksheet3.write(1+i, 5+j, c.nome , format7)
	 end
	end 
	
	worksheet4.set_column('A:A', 60)
	worksheet4.set_column('B:B', 60)
	worksheet4.set_column('C:C', 30)
	worksheet4.set_column('D:D', 30)
	worksheet4.set_column('E:E', 20)
	worksheet4.set_column('F:F', 50)
	worksheet4.set_column('G:G', 30)
	worksheet4.set_column('H:H', 30)
	worksheet4.set_column('I:I', 30)
    lista = Office.order(nome: :asc)
	s = OfficeType.where(denominazione: 'Servizio').first
	servizi = Office.where(office_type: s).order(nome: :asc)
	index_ufficio = 0
	index = 0
    servizi.each do |s|	
	
	  
	  # visita dell'albero partendo dalla radice
	  array_uffici = []
	  stack = []
	  max_iterazioni = 20
	  index_iterazioni = 0 
	  stack <<  s
	  
	  while (! stack.empty?) && (index_iterazioni < max_iterazioni)
	    index_iterazioni = index_iterazioni + 1 
	    current = stack.last
		if current.children.length > 0
		  array_uffici << stack.pop
		  current.children.each do | u | stack << u end
		else
		  array_uffici << stack.pop
		end
	   
	  end
	
	
	
	
	
	  index = index + 1
	  worksheet4.write(1+index, 0, s.nome, format_servizio)
	  index = index + 1
	  
	  array_uffici.each do | o |
	     worksheet4.write(1+index, 1, o.nome, format_ufficio)
		 index = index + 1
	     o.dipendenti_ufficio.each do |p|
	       worksheet4.write(1+index, 2, p.cognome, format_dipendente)
		   worksheet4.write(1+index, 3, p.nome, format_dipendente)
		   worksheet4.write(1+index, 4, p.matricola, format_dipendente_right)
		   worksheet4.write(1+index, 5, (p.email != nil ? p.email.to_s : ""), format_dipendente_right)
		   worksheet4.write(1+index, 6, p.qualifica, format_dipendente_right) 
           worksheet4.write(1+index, 7, p.stringa_categoria, format_dipendente_right) 
           worksheet4.write(1+index, 8, p.ruolo, format_dipendente_right)
           worksheet4.write(1+index, 9, p.tempo, format_dipendente_right)
		   index = index + 1
        end		
	  
	  end
	  # s.children.each do |o|
	   # worksheet4.write(1+index, 1, o.nome, format_ufficio)
	   # index = index + 1
	   # o.dipendenti_ufficio.each do |p|
	    # worksheet4.write(1+index, 2, p.cognome, format_dipendente)
		# worksheet4.write(1+index, 3, p.nome, format_dipendente)
		# worksheet4.write(1+index, 4, p.matricola, format_dipendente_right)
		# worksheet4.write(1+index, 5, (p.email != nil ? p.email.to_s : ""), format_dipendente_right)
		# worksheet4.write(1+index, 6, p.qualifica, format_dipendente_right) 
        # worksheet4.write(1+index, 7, p.categoria, format_dipendente_right) 
        # worksheet4.write(1+index, 8, p.ruolo, format_dipendente_right)
        # worksheet4.write(1+index, 9, p.tempo, format_dipendente_right)	
		# index = index + 1
		 # o.children.each do |u|
	      # worksheet4.write(1+index, 1, u.nome, format_ufficio)
	      # index = index + 1
	      # u.dipendenti_ufficio.each do |p|
	       # worksheet4.write(1+index, 2, p.cognome, format_dipendente)
		   # worksheet4.write(1+index, 3, p.nome, format_dipendente)
		   # worksheet4.write(1+index, 4, p.matricola, format_dipendente_right)
		   # worksheet4.write(1+index, 5, p.qualifica, format_dipendente_right) 
           # worksheet4.write(1+index, 6, p.categoria, format_dipendente_right) 
           # worksheet4.write(1+index, 7, p.ruolo, format_dipendente_right)
           # worksheet4.write(1+index, 8, p.tempo, format_dipendente_right)	
		   # index = index + 1
	      # end
	     # end
	    # end
	  # end
	end

	exfile.close
	send_file nomefile
  end
  
  def esporta_excel_produttivita
	registra('esporta_excel_produttivita')
    data_organico = Time.now.strftime("%d-%m-%Y")
	ente = Setting.where(denominazione: "ente").first != nil ? Setting.where(denominazione: "ente").first.value : "_"
	anno = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : "_"
    nomefile = "Produttivita_" + ente + "_" + anno + "_" + data_organico + ".xlsx"	
	exfile = WriteXLSX.new(nomefile)
	worksheet1 = exfile.add_worksheet(sheetname = 'Informazioni Generali')
	worksheet2 = exfile.add_worksheet(sheetname = 'Valutazioni dipendenti')
	worksheet3 = exfile.add_worksheet(sheetname = 'Differenziazione')
	worksheet4 = exfile.add_worksheet(sheetname = 'Analitico')
	worksheet5 = exfile.add_worksheet(sheetname = 'Esportazione Ascot')
	worksheet6 = exfile.add_worksheet(sheetname = 'NON RUOLO Esportazione Ascot')
	
	format1 = exfile.add_format # Add a format
	format1.set_font('Arial')
	format1.set_size(28)
	format1.set_align('center')
	format2 = exfile.add_format # Add a format
	format2.set_font('Arial')
	format2.set_size(14)
	format2.set_align('center')
	format3 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'yellow'})

	format3.set_font('Arial')
	format3.set_size(10)
	format3.set_align('left')
	format3.set_bold
	format3.set_bottom_color('cyan')
	format3.set_top_color('red')
	format4 = exfile.add_format # Add a format
	format4.set_font('Arial')
	format4.set_size(10)
	format4.set_align('left')
	
	format5 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'gray'})
	
	format6 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 10,
    'fg_color': 'cyan'})
	format6.set_text_wrap()
	
	
	
	format7 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()

	format8 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'right',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()
	
	format_servizio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'red',
	'size': 10})
	
	format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'yellow',
	'size': 10})
	
	format_dipendente = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
    'fg_color': 'white',
	'size': 8})
	
	format_dipendente_right = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'right',
    'valign': 'vcenter',
    'fg_color': 'white',
	'size': 8})
	
	#worksheet1.set_column('A:J', nil, nil, 0, 1)
	
	worksheet1.merge_range('A3:J3', 'Calcolo Produttività', format1)
	ente = Setting.where(denominazione: "ente").first != nil ? Setting.where(denominazione: "ente").first.value : " - "
	anno = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : " - "
	worksheet1.merge_range('A4:J4', ente, format2)
	worksheet1.merge_range('A5:J5', anno, format2)
	
	
	@categorie = ["A", "B", "C", "D", "PLA", "PLB"]
	@quote_pesate = {}
    @numero_per_categoria = Person.where(flag_calcolo_produttivita: true).group('categoria').count
	@totale_dipendenti = Person.where(flag_calcolo_produttivita: true).count
    #@peso_categorie = {"A" => 1.0, "B" => 1.10, "C" => 1.21, "D" => 1.331, "PLA" => 1.21, "PLB" => 1.331}
	@peso_categorie = FtePercentage.peso_categorie
    @quote = {}
	@categorie.each {|c| @quote[c] = 0.0 }
    cats = Person.where(flag_calcolo_produttivita: true).select(:categoria).distinct
    cats.each {|c| 
       @quote[c[:categoria]] = 0}
    Person.where(flag_calcolo_produttivita: true).each { |e| @quote[e.categoria] = @quote[e.categoria] + e.servizio_percentuale.to_f*e.tempo.to_f }
	  
	@quote.each {|key, value| @quote_pesate[key] = value * (@peso_categorie[key] != nil ? @peso_categorie[key] : 0) } 
	  
	worksheet1.set_column('A:A', 5)
	worksheet1.set_column('B:B', 30)
	worksheet1.set_column('C:C', 30)
	worksheet1.set_column('D:D', 10)
	worksheet1.set_column('E:E', 30)
	
	worksheet1.write(10, 0, "Categoria", format6)
	worksheet1.write(10, 1, "#Dipendenti", format6)
	worksheet1.write(10, 2, "#UnitaEq", format6)
	worksheet1.write(10, 3, "Pesi", format6)
	worksheet1.write(10, 4, "#UnitaEqPesate", format6)
	
	i = 1
	@categorie.each do |cat|
	  worksheet1.write(10+i, 0, cat, format7)
	  worksheet1.write(10+i, 1, @numero_per_categoria[cat], format7)
	  worksheet1.write(10+i, 2, @quote[cat], format7)
	  worksheet1.write(10+i, 3, @peso_categorie[cat], format7)
	  worksheet1.write(10+i, 4, @quote_pesate[cat].round(2), format7)
	  i = i +1
	end
	
	stringa1 = "="
	stringa2 = "="
	(1..@categorie.length).each do |n|
	  stringa1 = stringa1 + "+B" + (11+n).to_s
	  stringa2 = stringa2 + "+E" + (11+n).to_s
	end
	worksheet1.write(12+@categorie.length, 1, stringa1, format7)
	worksheet1.write(12+@categorie.length, 4, stringa2, format7)
	
	
	worksheet1.write(20, 0, "Categoria", format6)
	worksheet1.write(20, 1, "Comportamento", format6)
	worksheet1.write(20, 2, "Obiettivi", format6)
	worksheet1.write(20, 3, "", format6)
	worksheet1.write(20, 4, "Totale", format6)
	i = 1
	@categorie.each do |cat|
	  cq = CategoriaQuotum.where(chiave: cat).first
	  worksheet1.write(20+i, 0, cat, format7)
	  worksheet1.write(20+i, 1, cq.quota_comportamento.round(2), format7)
	  worksheet1.write(20+i, 2, cq.quota_obiettivi.round(2), format7)
	  worksheet1.write(20+i, 3, "", format7)
	  worksheet1.write(20+i, 4, (cq.quota_comportamento + cq.quota_obiettivi).round(2), format7)
	  i = i +1
	end
	
	worksheet2.set_column('A:A', 5)
	worksheet2.set_column('B:B', 10)
	worksheet2.set_column('C:C', 20)
	worksheet2.set_column('D:D', 30)
	worksheet2.set_column('E:E', 5)
	worksheet2.set_column('F:F', 10)
	worksheet2.set_column('G:G', 10)
	worksheet2.set_column('H:H', 10)
	worksheet2.set_column('I:I', 30)
	worksheet2.set_column('L:L', 20)
	worksheet2.set_column('M:M', 20)
	worksheet2.set_column('N:N', 20)
	
	
	
	worksheet2.write(0, 0, "Nr", format6)
	worksheet2.write(0, 1, "Matricola", format6)
	worksheet2.write(0, 2, "Cognome", format6)
	worksheet2.write(0, 3, "Nome", format6)
	worksheet2.write(0, 4, "Categoria", format6)
	worksheet2.write(0, 5, "Assegnazione", format6)
	worksheet2.write(0, 6, "Tempo", format6)
	worksheet2.write(0, 7, "Servizio", format6)
	worksheet2.write(0, 8, "Dirigente", format6)
	worksheet2.write(0, 9, "Comportamento", format6)
	worksheet2.write(0, 10, "Obiettivi", format6)
	worksheet2.write(0, 11, "Premialità", format6)
	
	
	lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	 worksheet2.write(1+i, 0, (i+1).to_s, format7)
	 worksheet2.write(1+i, 1, r.matricola, format8)
	 worksheet2.write(1+i, 2, r.cognome, format7)
	 worksheet2.write(1+i, 3, r.nome, format7)
	 worksheet2.write(1+i, 4, r.stringa_categoria, format8)
	 worksheet2.write(1+i, 5, r.assegnazione, format8)
	 worksheet2.write(1+i, 6, r.tempo.to_f.round(2), format8)
	 worksheet2.write(1+i, 7, r.servizio_percentuale.to_f.round(2), format8)
	 dirigente = '-'
	 if r.ufficio != nil
       direttore = r.ufficio.dirigente
	   if direttore != nil
	    dirigente = direttore.nominativo2
	   end
     end
	 worksheet2.write(1+i, 8, dirigente, format8)
	 worksheet2.write(1+i, 9, r.valutazione, format8)
	 worksheet2.write(1+i, 10, r.raggiungimento_obiettivi, format8)
	 worksheet2.write(1+i, 11, r.premialita_effettiva, format8)
	 
	  
	
	end 
	
	medie_valutazioni = Hash.new
	medie_raggiungimento_obiettivi = Hash.new
	medie_punteggio_finale_totale = Hash.new
	
	valutazioni_numero_categoria = Hash.new
	
	raggiuntimento_obiettivi_numero_categoria = Hash.new
	punteggio_finale_totale_numero_categoria = Hash.new
	l = Person.where(flag_calcolo_produttivita: true).group(:categoria).count(:categoria).sort
	
	somme_valutazioni = Person.where(flag_calcolo_produttivita: true).group(:categoria).sum(:valutazione)
	avg_val = Person.where(flag_calcolo_produttivita: true).group(:categoria).average(:valutazione)
	somme_raggiungimento_obiettivi = Person.where(flag_calcolo_produttivita: true).group(:categoria).sum(:raggiungimento_obiettivi)
	
	# attenzione che l'operazione sotto non fa uscire una hash (contrariamente a quella sopra)
	# somme_punteggio_finale_totale = Person.where(flag_calcolo_produttivita: true).group(:categoria).sum(&:punteggio_finale_totale)
	
	l.each do |item|
	 if item[0] != nil
	  categoria = item[0]
	  somma_valore = somme_valutazioni[categoria]
	  
	  # questa non funziona in Postgres
	  #somma_punteggio_finale_totale = Person.where(flag_calcolo_produttivita: true).group(:categoria).sum(&:punteggio_finale_totale)
	  # faccio con questa
	  somma_punteggio_finale_totale = Person.where(flag_calcolo_produttivita: true, categoria: categoria).sum{ |p| p.punteggio_finale_totale }
	
	  media = (item[1] != 0 ? somma_valore / item[1] : 0)
	  media_punteggio_finale_totale = (item[1] != 0 ? somma_punteggio_finale_totale / item[1] : 0)
	  medie_valutazioni = medie_valutazioni.merge({categoria => media}) 
	  medie_punteggio_finale_totale = medie_punteggio_finale_totale.merge({categoria => media_punteggio_finale_totale})
	 end
	end
	
	soglia1 = 50
	soglia2 = 70
	soglia3 = 90
	soglia4 = 100
	
	intervallo4 = ">= " + soglia3.to_s + " e <= " + soglia4.to_s
	intervallo3 = ">= " + soglia2.to_s + " e < " + soglia3.to_s + ""
	intervallo2 = ">= " + soglia1.to_s + " e < " + soglia2.to_s + ""
	intervallo1 = "< " + soglia1.to_s + "" 
	
	l.each do |item|
	  if item[0] != nil 
	   categoria = item[0]
	   somma_valore = somme_raggiungimento_obiettivi[categoria]
	   media = (item[1] != 0 ? somma_valore / item[1] : 0)
	   medie_raggiungimento_obiettivi = medie_raggiungimento_obiettivi.merge({categoria => media}) 
	   valutazioni_numero = Hash.new
	   valutazioni_numero = valutazioni_numero.merge({intervallo4 => Person.where(flag_calcolo_produttivita: true).where("valutazione >= ? and valutazione <= ?", soglia3, soglia4).where(categoria: categoria).length })
	   valutazioni_numero = valutazioni_numero.merge({intervallo3 => Person.where(flag_calcolo_produttivita: true).where("valutazione >= ? and valutazione < ?", soglia2, soglia3).where(categoria: categoria).length })
	   valutazioni_numero = valutazioni_numero.merge({intervallo2 => Person.where(flag_calcolo_produttivita: true).where("valutazione >= ? and valutazione < ?", soglia1, soglia2).where(categoria: categoria).length })
	   valutazioni_numero = valutazioni_numero.merge({intervallo1 => Person.where(flag_calcolo_produttivita: true).where("valutazione < ?", soglia1).where(categoria: categoria).length })
	   valutazioni_numero_categoria = valutazioni_numero_categoria.merge({categoria => valutazioni_numero}) 
	   
	   raggiuntimento_obiettivi_numero = Hash.new
	   raggiuntimento_obiettivi_numero = raggiuntimento_obiettivi_numero.merge( {intervallo4 => Person.where(flag_calcolo_produttivita: true).where("raggiungimento_obiettivi >= ? and raggiungimento_obiettivi <= ?", soglia3, soglia4).where(categoria: categoria).length})
	   raggiuntimento_obiettivi_numero = raggiuntimento_obiettivi_numero.merge( {intervallo3 => Person.where(flag_calcolo_produttivita: true).where("raggiungimento_obiettivi >= ? and raggiungimento_obiettivi < ?", soglia2, soglia3).where(categoria: categoria).length})
	   raggiuntimento_obiettivi_numero = raggiuntimento_obiettivi_numero.merge( {intervallo2 => Person.where(flag_calcolo_produttivita: true).where("raggiungimento_obiettivi >= ? and raggiungimento_obiettivi < ?", soglia1, soglia2).where(categoria: categoria).length})
       raggiuntimento_obiettivi_numero = raggiuntimento_obiettivi_numero.merge( {intervallo1 => Person.where(flag_calcolo_produttivita: true).where("raggiungimento_obiettivi < ?", soglia1).where(categoria: categoria).length})
       raggiuntimento_obiettivi_numero_categoria = raggiuntimento_obiettivi_numero_categoria.merge({categoria => raggiuntimento_obiettivi_numero})
	  
	   punteggio_finale_totale_numero = Hash.new
	   punteggio_finale_totale_numero = punteggio_finale_totale_numero.merge( {intervallo4 => Person.where(flag_calcolo_produttivita: true, categoria: categoria).select{|c| ((c.punteggio_finale_totale >= soglia3) && (c.punteggio_finale_totale <= soglia4))}.length})
	   punteggio_finale_totale_numero = punteggio_finale_totale_numero.merge( {intervallo3 => Person.where(flag_calcolo_produttivita: true, categoria: categoria).select{|c| ((c.punteggio_finale_totale >= soglia2) && (c.punteggio_finale_totale < soglia3))}.length})
	   punteggio_finale_totale_numero = punteggio_finale_totale_numero.merge( {intervallo2 => Person.where(flag_calcolo_produttivita: true, categoria: categoria).select{|c| ((c.punteggio_finale_totale >= soglia1) && (c.punteggio_finale_totale < soglia2))}.length})
       punteggio_finale_totale_numero = punteggio_finale_totale_numero.merge( {intervallo1 => Person.where(flag_calcolo_produttivita: true, categoria: categoria).select{|c| ((c.punteggio_finale_totale < soglia1))}.length})
       punteggio_finale_totale_numero_categoria = punteggio_finale_totale_numero_categoria.merge({categoria => punteggio_finale_totale_numero})
	  
	  end
	end
	
	worksheet3.set_column('A:A', 10)
	worksheet3.set_column('B:B', 20)
	worksheet3.set_column('C:C', 20)
	worksheet3.set_column('D:D', 20)
	worksheet3.set_column('E:E', 20)
	worksheet3.set_column('F:F', 20)
	
	worksheet3.write(0, 0, "Categoria", format6)
	worksheet3.write(0, 1, "media valutazione ", format6)
	worksheet3.write(0, 2, intervallo4, format6)
	worksheet3.write(0, 3, intervallo3, format6)
	worksheet3.write(0, 4, intervallo2, format6)
	worksheet3.write(0, 5, intervallo1, format6)
	worksheet3.write(0, 6, "totali", format6)
	
	numero_voci = 0
	l.each_with_index do |r,i| 
	 if r[0] != nil
	  numero_voci = numero_voci + 1
	  worksheet3.write(1+i, 0, r[0], format6)
	  worksheet3.write(1+i, 1, medie_valutazioni[r[0]].round(0), format6)
	  vn = valutazioni_numero_categoria[r[0]]
	  worksheet3.write(1+i, 2, vn[intervallo4], format6)
	  worksheet3.write(1+i, 3, vn[intervallo3], format6)
	  worksheet3.write(1+i, 4, vn[intervallo2], format6)
	  worksheet3.write(1+i, 5, vn[intervallo1], format6)
	  worksheet3.write(1+i, 6, r[1], format6)
	  worksheet3.write(1+i, 8, "=C"+(i+2).to_s+"+D"+(i+2).to_s+"+E"+(i+2).to_s+"+F"+(i+2).to_s, format6)
	 end
	end
	stringa1 = "="
	stringa2 = "="
	(1..numero_voci).each do |n|
	  stringa1 = stringa1 + "+G" + (1+n).to_s
	  stringa2 = stringa2 + "+I" + (1+n).to_s
	end
	worksheet3.write(1+l.length, 6, stringa1, format6)
	worksheet3.write(1+l.length, 8, stringa2, format6)
	
	#########################
	
	worksheet3.write(10, 0, "Categoria", format6)
	worksheet3.write(10, 1, "media obiettivi ", format6)
	worksheet3.write(10, 2, intervallo4, format6)
	worksheet3.write(10, 3, intervallo3, format6)
	worksheet3.write(10, 4, intervallo2, format6)
	worksheet3.write(10, 5, intervallo1, format6)
	worksheet3.write(10, 6, "totali", format6)
	
	numero_voci = 0
	l.each_with_index do |r,i| 
	 if r[0] != nil
	  numero_voci = numero_voci + 1
	  worksheet3.write(11+i, 0, r[0], format6)
	  worksheet3.write(11+i, 1, medie_raggiungimento_obiettivi[r[0]].round(0), format6)
	  vo = raggiuntimento_obiettivi_numero_categoria[r[0]]
	  worksheet3.write(11+i, 2, vo[intervallo4], format6)
	  worksheet3.write(11+i, 3, vo[intervallo3], format6)
	  worksheet3.write(11+i, 4, vo[intervallo2], format6)
	  worksheet3.write(11+i, 5, vo[intervallo1], format6)
	  worksheet3.write(11+i, 6, r[1], format6)
	  worksheet3.write(11+i, 8, "=C"+(i+12).to_s+"+D"+(i+12).to_s+"+E"+(i+12).to_s+"+F"+(i+12).to_s, format6)
	 end
	end
	
	stringa1 = "="
	stringa2 = "="
	(1..numero_voci).each do |n|
	  stringa1 = stringa1 + "+G" + (11+n).to_s
	  stringa2 = stringa2 + "+I" + (11+n).to_s
	end
	worksheet3.write(11+l.length, 6, stringa1, format6)
	worksheet3.write(11+l.length, 8, stringa2, format6)
	
	#########################
	
	worksheet3.write(20, 0, "Categoria", format6)
	worksheet3.write(20, 1, "media finale ", format6)
	worksheet3.write(20, 2, intervallo4, format6)
	worksheet3.write(20, 3, intervallo3, format6)
	worksheet3.write(20, 4, intervallo2, format6)
	worksheet3.write(20, 5, intervallo1, format6)
	worksheet3.write(20, 6, "totali", format6)
	
	numero_voci = 0
	l.each_with_index do |r,i| 
	 if r[0] != nil
	  numero_voci = numero_voci + 1
	  worksheet3.write(21+i, 0, r[0], format6)
	  worksheet3.write(21+i, 1, medie_punteggio_finale_totale[r[0]].round(0), format6)
	  pt = punteggio_finale_totale_numero_categoria[r[0]]
	  worksheet3.write(21+i, 2, pt[intervallo4], format6)
	  worksheet3.write(21+i, 3, pt[intervallo3], format6)
	  worksheet3.write(21+i, 4, pt[intervallo2], format6)
	  worksheet3.write(21+i, 5, pt[intervallo1], format6)
	  worksheet3.write(21+i, 6, r[1], format6)
	  worksheet3.write(21+i, 8, "=C"+(i+2).to_s+"+D"+(i+2).to_s+"+E"+(i+2).to_s+"+F"+(i+2).to_s, format6)
	 end
	end
	stringa1 = "="
	stringa2 = "="
	(1..numero_voci).each do |n|
	  stringa1 = stringa1 + "+G" + (1+n).to_s
	  stringa2 = stringa2 + "+I" + (1+n).to_s
	end
	worksheet3.write(21+l.length, 6, stringa1, format6)
	worksheet3.write(21+l.length, 8, stringa2, format6)
	
	
	####################
	#   ANALITICO
	######################
	
	worksheet4.set_column('A:A', 5)
	worksheet4.set_column('B:B', 10)
	worksheet4.set_column('C:C', 30)
	worksheet4.set_column('D:D', 30)
	worksheet4.set_column('E:E', 5)
	worksheet4.set_column('F:F', 5)
	worksheet4.set_column('G:G', 5)
	worksheet4.set_column('H:H', 10)
	worksheet4.set_column('I:I', 10)
	worksheet4.set_column('J:J', 10)
	worksheet4.set_column('K:K', 10)
	worksheet4.set_column('L:L', 10)
	worksheet4.set_column('M:M', 10)
	worksheet4.set_column('N:N', 10)
	worksheet4.set_column('O:O', 10)
	worksheet4.set_column('P:P', 20)
	worksheet4.set_column('Q:Q', 20)
	worksheet4.set_column('R:R', 20)
	worksheet4.set_column('S:S', 20)
	worksheet4.set_column('T:T', 20)
	worksheet4.set_column('U:U', 20)
	
	
	
	worksheet4.write(0, 0, "Nr", format6)
	worksheet4.write(0, 1, "Matricola", format6)
	worksheet4.write(0, 2, "Cognome", format6)
	worksheet4.write(0, 3, "Nome", format6)
	worksheet4.write(0, 4, "Categoria", format6)
	worksheet4.write(0, 5, "Ruolo", format6)
	worksheet4.write(0, 6, "COS", format6)
	worksheet4.write(0, 7, "Assegnazione", format6)
	worksheet4.write(0, 8, "Totgg", format6)
	worksheet4.write(0, 9, "TotAssenze", format6)
	worksheet4.write(0, 10, "%Assenze", format6)
	worksheet4.write(0, 11, "flag_assenze_incidono", format6)
	worksheet4.write(0, 12, "Riduzione x assenze", format6)
	worksheet4.write(0, 13, "Tempo", format6)
	worksheet4.write(0, 14, "Servizio", format6)
	worksheet4.write(0, 15, "Comportamento", format6)
	worksheet4.write(0, 16, "Obiettivi", format6)
	worksheet4.write(0, 17, "Premialità", format6)
	worksheet4.write(0, 18, "QuotaObiettivi[€]", format6)
	worksheet4.write(0, 19, "QuotaEconomia[€]", format6)
	worksheet4.write(0, 20, "QuotaValutazione[€]", format6)
	worksheet4.write(0, 21, "TotalePremio[€]", format6)
	
	
	lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	 worksheet4.write(1+i, 0, (i+1).to_s, format7)
	 worksheet4.write(1+i, 1, r.matricola, format8)
	 worksheet4.write(1+i, 2, r.cognome, format7)
	 worksheet4.write(1+i, 3, r.nome, format7)
	 worksheet4.write(1+i, 4, r.stringa_categoria, format8)
	 worksheet4.write(1+i, 5, r.ruolo, format8)
	 worksheet4.write(1+i, 6, r.cos, format8)
	 worksheet4.write(1+i, 7, r.assegnazione, format8)
	 worksheet4.write(1+i, 8, r.totgg, format8)
	 worksheet4.write(1+i, 9, r.totassenze, format8)
	 worksheet4.write(1+i, 10, (((r.totassenze != nil) && (r.totgg != nil) && (r.totgg != 0)) ? (r.totassenze.to_f / r.totgg.to_f).round(2).to_s : "N.A."), format8)
	 worksheet4.write(1+i, 11, r.flag_assenze_incidono, format8)
	 worksheet4.write(1+i, 12, r.percentuale_riduzione_per_assenze.to_f.round(2), format8)
	 worksheet4.write(1+i, 13, r.tempo.to_f.round(2), format8)
	 worksheet4.write(1+i, 14, r.servizio_percentuale.to_f.round(2), format8)
	 worksheet4.write(1+i, 15, r.valutazione, format8)
	 worksheet4.write(1+i, 16, r.raggiungimento_obiettivi, format8)
	 worksheet4.write(1+i, 17, r.premialita_effettiva, format8)
	 worksheet4.write(1+i, 18, r.totale_premio_obiettivi, format8)
	 worksheet4.write(1+i, 19, r.quota_economia_area_obiettivi_dipendente.to_f.round(2), format8)
	 worksheet4.write(1+i, 20, r.totale_premio_valutazione, format8)
	 worksheet4.write(1+i, 21, r.totale_premio_produttivita, format8)
	 	
	end 
	
	inizio_statistiche = lista.length + 5
	worksheet4.write(inizio_statistiche + 1, 20, "Totale Erogato", format8)
	worksheet4.write(inizio_statistiche + 1, 21, "=SOMMA(V2:V" + (lista.length + 1).to_s + ")", format8)
	worksheet4.write(inizio_statistiche + 2, 20, "Fondo", format8)
	fondo = 0.0
	if Setting.where(denominazione: "fondo").first != nil
	   fondo = Setting.where(denominazione: "fondo").first.value.to_f
	end
	worksheet4.write(inizio_statistiche + 2, 21, fondo, format8)
	worksheet4.write(inizio_statistiche + 3, 20, "Economia", format8)
	worksheet4.write(inizio_statistiche + 3, 21, "=V" + (inizio_statistiche + 3).to_s + "-V" + (inizio_statistiche + 2).to_s, format8)
	
	worksheet4.write(inizio_statistiche + 5, 20, "MAX", format8)
	worksheet4.write(inizio_statistiche + 5, 21, "=MAX(V2:V" + (lista.length + 1).to_s + ")", format8)
	worksheet4.write(inizio_statistiche + 6, 20, "min", format8)
	worksheet4.write(inizio_statistiche + 6, 21, "=MIN(V2:V" + (lista.length + 1).to_s + ")", format8)
	worksheet4.write(inizio_statistiche + 7, 20, "Media", format8)
	worksheet4.write(inizio_statistiche + 7, 21, "=MEDIA(V2:V" + (lista.length + 1).to_s + ")", format8)
	
	####################
	#   ESPORTAZIONE ASCOT
	######################
	
	worksheet5.set_column('A:A', 30)
	worksheet5.set_column('B:B', 30)
	worksheet5.set_column('C:C', 30)
	worksheet5.set_column('D:D', 30)
	worksheet5.set_column('E:E', 30)
	worksheet5.set_column('F:F', 30)
	
	worksheet5.write(0, 0, "A", format6)
	worksheet5.write(0, 1, "B", format6)
	worksheet5.write(0, 2, "C", format6)
	worksheet5.write(0, 3, "D", format6)
	worksheet5.write(0, 4, "E", format6)
	worksheet5.write(0, 5, "F", format6)
	
	lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	 worksheet5.write(1+i, 0, r.matricola, format7)
	 worksheet5.write(1+i, 1, "388", format7)
	 worksheet5.write(1+i, 2, "20190101", format7)
	 worksheet5.write(1+i, 3, "+", format7)
	 worksheet5.write(1+i, 4, "00000000", format7)
	 worksheet5.write(1+i, 5, r.totale_premio_produttivita, format7)
	end
	
	####################
	#   ESPORTAZIONE ASCOT NON RUOLO
	######################
	
	worksheet6.set_column('A:A', 30)
	worksheet6.set_column('B:B', 30)
	worksheet6.set_column('C:C', 30)
	worksheet6.set_column('D:D', 30)
	worksheet6.set_column('E:E', 30)
	worksheet6.set_column('F:F', 30)
	
	worksheet6.write(0, 0, "A", format6)
	worksheet6.write(0, 1, "B", format6)
	worksheet6.write(0, 2, "C", format6)
	worksheet6.write(0, 3, "D", format6)
	worksheet6.write(0, 4, "E", format6)
	worksheet6.write(0, 5, "F", format6)
	
	data_impegno = Setting.get_data_impegno
	
	nonruolo = "N"
	lista = Person.where("flag_calcolo_produttivita = ? AND ruolo LIKE 'N%'", true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	 worksheet6.write(1+i, 0, r.matricola, format7)
	 worksheet6.write(1+i, 1, "388", format7)
	 worksheet6.write(1+i, 2, data_impegno, format7)
	 worksheet6.write(1+i, 3, "+", format7)
	 worksheet6.write(1+i, 4, "00000000", format7)
	 worksheet6.write(1+i, 5, r.totale_premio_produttivita, format7)
	end
	
	exfile.close
	send_file nomefile
  end
  
  
  def esporta_txt_ascot
    data_organico = Time.now.strftime("%d-%m-%Y")
    nomefile = "Produttivita_Ascot_" + data_organico + ".txt"	
	extfile = "" 
	
	#extfile = extfile + "A\tB\tC\tD\tE\tF" 
	data_impegno = Setting.get_data_impegno
	
	lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
		
	   extfile = extfile+  +"\r\n" + (r.matricola.last(6) + "\t" + "0388\t" + data_impegno + "\t+\t00000000\t" + r.totale_premio_produttivita.to_i.to_s.rjust(8,'0')) 
	
	end
    send_data extfile,  :filename => "Esportazione2Ascot.txt" 
  end
  
  def esporta_txt_ascot_all
    data_organico = Time.now.strftime("%d-%m-%Y")
    nomefile = "Produttivita_Ascot_ALL" + data_organico + ".txt"	
	extfile = "" 
	
	#extfile = extfile + "A\tB\tC\tD\tE\tF" 
	data_impegno = Setting.get_data_impegno
		
	lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	
	extfile = extfile+  +"\r\n" + (r.matricola.last(6) + "\t" + "0388\t" + data_impegno + "\t+\t00000000\t" + r.totale_premio_produttivita.to_i.to_s.rjust(8,'0')) 
	
	end
    send_data extfile,  :filename => "Esportazione2Ascot_ALL.txt" 
  end
  
  def esporta_txt_ascot_ruolo
    data_organico = Time.now.strftime("%d-%m-%Y")
    nomefile = "Produttivita_Ascot_RUOLO" + data_organico + ".txt"	
	extfile = "" 
	
	#extfile = extfile + "A\tB\tC\tD\tE\tF" 
	data_impegno = Setting.get_data_impegno
	
	#lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista = Person.where("flag_calcolo_produttivita = ? AND ((ruolo NOT LIKE 'N%') OR ( ruolo IS NULL))", true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	
	extfile = extfile+  +"\r\n" + (r.matricola.last(6) + "\t" + "0388\t" + data_impegno + "\t+\t00000000\t" + r.totale_premio_produttivita.to_i.to_s.rjust(8,'0')) 
	
	end
    send_data extfile,  :filename => "Esportazione2Ascot_RUOLO.txt" 
  end
  
  def esporta_txt_ascot_non_ruolo
    data_organico = Time.now.strftime("%d-%m-%Y")
    nomefile = "Produttivita_Ascot_NONRUOLO" + data_organico + ".txt"	
	extfile = "" 
	
	#extfile = extfile + "A\tB\tC\tD\tE\tF" 
	data_impegno = Setting.get_data_impegno
	
	lista = Person.where("flag_calcolo_produttivita = ? AND ruolo LIKE 'N%'", true).order(matricola: :asc)
	# lista = Person.where(flag_calcolo_produttivita: true).order(matricola: :asc)
	lista.each_with_index do |r,i|
	
	extfile = extfile+  +"\r\n" + (r.matricola.last(6) + "\t" + "0388\t" + data_impegno + "\t+\t00000000\t" + r.totale_premio_produttivita.to_i.to_s.rjust(8,'0')) 
	
	end
    send_data extfile,  :filename => "Esportazione2Ascot_NONRUOLO.txt" 
  end
  
  def esporta_txt_ascot_per_cos
    data_organico = Time.now.strftime("%d-%m-%Y")
	cos = "AMBITO"
    nomefile = "Produttivita_Ascot_" + data_organico + "_per_cos_" + cos +".txt"	
	extfile = "" 
	
	#extfile = extfile + "A\tB\tC\tD\tE\tF" 
	data_impegno = Setting.get_data_impegno
	
	lista = Person.where(flag_calcolo_produttivita: true, cos: cos).order(matricola: :asc)
	lista.each_with_index do |r,i|
		
	   extfile = extfile+  +"\r\n" + (r.matricola.last(6) + "\t" + "0388\t" + data_impegno + "\t+\t00000000\t" + r.totale_premio_produttivita.to_i.to_s.rjust(8,'0')) 
	
	end
    send_data extfile,  :filename => nomefile 
  end
  
  def view_leggi_file_borghese
  
  end
  
  def leggi_file_borghese
  
  file = params[:file]
  opzione1 = params[:opzione1]
  opzione2 = params[:opzione2]
  opzione3 = params[:opzione3]
  
  filename = params[:file].original_filename
  puts "FILENAME " + filename
  nome_file_out = filename + "_mx.xls"
  exfile = WriteXLSX.new(nome_file_out)
  #xls = Roo::Spreadsheet.open(file.path)
  xls = Roo::Spreadsheet.open(file.path)
  xls.info
  nome_foglio = xls.sheets[0]
  foglio_personale = xls.sheet(nome_foglio)
  worksheet1 = exfile.add_worksheet(sheetname = nome_foglio)
  last_row = foglio_personale.last_row
  indice = 1 

  format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	
  format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')

  format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
  format1center.set_text_wrap() ;

  format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'yellow',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

  format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	worksheet1.set_column('A:A', 3)
	worksheet1.set_column('B:B', 5)
	worksheet1.set_column('C:C', 10)
	worksheet1.set_column('D:D', 20)
	worksheet1.set_column('E:E', 20)
	worksheet1.set_column('F:F', 35)
	worksheet1.set_column('G:G', 20)
	worksheet1.set_column('H:H', 15)
	worksheet1.set_column('I:I', 20)
	worksheet1.set_column('J:J', 30)
	worksheet1.set_column('K:K', 30)
	
	nome_ufficio = ''
	@result = []
	@righe_non_trovate = []
		
	for row in indice..last_row
	 cognome = ''
	 nome = ''
	 # c =  foglio_personale.cell('C', row)
	 # n =  foglio_personale.cell('D', row)
	 matr = foglio_personale.cell('B', row)
	 c =  foglio_personale.cell('C', row)
	 n =  foglio_personale.cell('D', row)
	 if c != nil
	  cognome = c.strip
	 end
	 if n != nil
	  nome = n.strip
	 end
	 p = Person.where(cognome: cognome, nome: nome).first
	 if p != nil
	   #trovata la persona
	   # in c dovrei avere la stringa dell'ufficio
	   worksheet1.write(row, 0, foglio_personale.cell('A', row), format1center)
	   worksheet1.write(row, 1, foglio_personale.cell('B', row), format1center)
	   worksheet1.write(row, 2, p.matricola + " - " + matr.to_s, format1)
	   worksheet1.write(row, 3, p.cognome, format1)
	   worksheet1.write(row, 4, p.nome, format1)
	   worksheet1.write(row, 5, foglio_personale.cell('F', row), format1)
	   worksheet1.write(row, 6, foglio_personale.cell('G', row), format1)
	   worksheet1.write(row, 7, foglio_personale.cell('H', row), format1)
	   worksheet1.write(row, 8, foglio_personale.cell('I', row), format1)
	   worksheet1.write(row, 9, foglio_personale.cell('J', row), format1)
	   worksheet1.write(row, 10, foglio_personale.cell('K', row), format1)
	   worksheet1.set_row(row, 20)
	   
	   o = Office.ufficio_simile(nome_ufficio)
	   if opzione2
	    if o != nil
	      p.ufficio = o
	      p.save
	    end
	   end
	   
	   if opzione3
	   
	      p.ruolo = foglio_personale.cell('G', row)
	      p.save
	    
	   end
	   n = Hash.new
       n[:persona] = p.cognome
       n[:ufficio1] = nome_ufficio
       n[:ufficio2] = ( o != nil ? o.nome : 'non trovato')
       @result<< n	   
	    
	   
	   
	 else
	 # non ho trovato la persona 
	  @righe_non_trovate<< row 
	  a = foglio_personale.cell('A', row)
	  b = foglio_personale.cell('B', row)
	  c = foglio_personale.cell('C', row)
	  d = foglio_personale.cell('D', row)
	  e = foglio_personale.cell('E', row)
	  f = foglio_personale.cell('F', row)
	  g = foglio_personale.cell('G', row)
	  h = foglio_personale.cell('H', row)
	  i = foglio_personale.cell('I', row)
	  j = foglio_personale.cell('J', row)
	  k = foglio_personale.cell('K', row)
	  if a != nil && (b == nil || b == " ") && (c == nil || c == " ") && (d == nil || d == " ") && (e == nil || e == " ")
	   if (true if Float(a) rescue false)
	   # è il numero
		 worksheet1.write(row, 0, a != nil ? a : " ", format1center)
		 
	   else
		 # nome del servizio
		 worksheet1.merge_range('A'+(row+1).to_s+':K'+(row+1).to_s, a, format_titolo)
		 worksheet1.set_row(row, 40)
	   end
	  else
	   worksheet1.write(row, 0, a != nil ? a : " ", format1center)
	  end
	  
	  if (a == nil || a == " ") && (b == nil || b == " ") && (c != nil) && (d == nil || d == " ") && (e == nil || e == " ")
	  # ufficio
	   worksheet1.merge_range('C'+(row+1).to_s+':E'+(row+1).to_s, c, format_ufficio)
	   worksheet1.set_row(row, 30)
	   nome_ufficio = c
	   puts nome_ufficio
	  end
	  if (true if Float(b) rescue false) && (true if Float(a) rescue false) && !(true if Float(c) rescue false)
	  # un nome non conosciuto
		worksheet1.write(row, 0, a != nil ? a : " ", format1red)
		worksheet1.write(row, 1, b != nil ? b : " ", format1red)
		worksheet1.write(row, 2, c != nil ? c : " ", format1red)
		worksheet1.write(row, 3, d != nil ? d : " ", format1red)
		worksheet1.write(row, 4, e != nil ? e : " ", format1red)
		worksheet1.write(row, 5, f != nil ? f : " ", format1red)
		worksheet1.write(row, 6, g != nil ? g : " ", format1red)
		worksheet1.write(row, 7, h != nil ? h : " ", format1red)
		worksheet1.write(row, 8, i != nil ? i : " ", format1red)
		worksheet1.write(row, 9, j != nil ? j : " ", format1red)
		worksheet1.write(row, 10, k != nil ? k : " ", format1red)
	  end
	  if  (true if Float(a) rescue false) && (b == nil || b == " ") && (c == nil || c == " ")
	  # la somma
		worksheet1.write(row, 0, '=SOMMA(A1:A'+row.to_s+')', format1)
		worksheet1.write(row, 1, b != nil ? b : " ", format1)
		worksheet1.write(row, 2, c != nil ? c : " ", format1)
		worksheet1.write(row, 3, d != nil ? d : " ", format1)
		worksheet1.write(row, 4, e != nil ? e : " ", format1)
		worksheet1.write(row, 5, f != nil ? f : " ", format1)
		worksheet1.write(row, 6, g != nil ? g : " ", format1)
		worksheet1.write(row, 7, h != nil ? h : " ", format1)
		worksheet1.write(row, 8, i != nil ? i : " ", format1)
		worksheet1.write(row, 9, j != nil ? j : " ", format1)
		worksheet1.write(row, 10, k != nil ? k : " ", format1)
	  end
	  if (a == nil || a == " ") && (b != nil) && !(true if Float(a) rescue false) && (c != nil) && (d != nil) && (e != nil)
	   #riga dei titoli
	   if b.start_with? 'COS'
		
		worksheet1.write(row, 0, a != nil ? a : " ", format1center)
		worksheet1.write(row, 1, b != nil ? b : " ", format1center)
		worksheet1.write(row, 2, "MATRICOLA", format1center)
		worksheet1.write(row, 3, d != nil ? d : " ", format1center)
		worksheet1.write(row, 4, e != nil ? e : " ", format1center)
		worksheet1.write(row, 5, f != nil ? f : " ", format1center)
		#worksheet1.write(row, 6, g != nil ? g : " ", format1center)
		worksheet1.write(row, 6, "POSIZIONE \x0A ECONOMICA", format1center)
		

		worksheet1.write(row, 7, h != nil ? h : " ", format1center)
		worksheet1.write(row, 8, i != nil ? i : " ", format1center)
		worksheet1.write(row, 9, j != nil ? j : " ", format1center)
		worksheet1.write(row, 10, k != nil ? k : " ", format1center)
		worksheet1.set_row(row, 25)
	   end
	  end
	  
	 
	 
	 end
	end

	exfile.close
	if opzione1 
      send_file nome_file_out
	end
  
  end
  
  def esporta_personale_borghese
  
  anno = (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-")
  ente = (Setting.where(denominazione: 'ente').first != nil ? Setting.where(denominazione: 'ente').first.value : "-")
  filename = "Organico_" + ente + "_" + anno
  puts "FILENAME " + filename
  nome_file_out = filename + ".xlsx"
  exfile = WriteXLSX.new(nome_file_out)
  
  nome_ufficio = ''
  @result = []
  @righe_non_trovate = []
	
  lista_uffici = []
	
  tipo_servizio = OfficeType.where(denominazione: "Servizio").first
  tipo_dipartimento = OfficeType.where(denominazione: "Dipartimento").first
  tipo_area = OfficeType.where(denominazione: "Area").first
	
  Office.where(office_type: tipo_servizio).each do | o |
    lista_uffici<< o
  end
  Office.where(office_type: tipo_dipartimento).each do | o |
    lista_uffici<< o
  end
  # Office.where(office_type: tipo_area).each do | o |
    # lista_uffici<< o
  # end

  indice_ufficio = 1  
  format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'yellow',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	
	
	nome_ufficio = ''
	
	lista_uffici.each do |ufficio|
	
		worksheet1 = exfile.add_worksheet(sheetname = ufficio.nome.truncate(30))
	
	    worksheet1.set_column('A:A', 3)
		worksheet1.set_column('B:B', 10)
		worksheet1.set_column('C:C', 15)
		worksheet1.set_column('D:D', 20)
		worksheet1.set_column('E:E', 20)
		worksheet1.set_column('F:F', 35)
		worksheet1.set_column('G:G', 20)
		worksheet1.set_column('H:H', 15)
		worksheet1.set_column('I:I', 20)
		worksheet1.set_column('J:J', 20)
		worksheet1.set_column('K:K', 20)
		worksheet1.set_column('L:L', 20)
		worksheet1.set_column('M:M', 20)
	
		@risultati = []
		#@dirigente.dirige.each do |s|
	    s = ufficio
		item = Hash.new
		item[:ufficio] = s
		item[:dipendenti] = s.dipendenti_ufficio
		@risultati << item
		s.children.each do |o|
			item = Hash.new
			item[:ufficio] = o
			item[:dipendenti] = o.dipendenti_ufficio
			@risultati << item
			o.children.each do |oo|
				item = Hash.new
				item[:ufficio] = oo
				item[:dipendenti] = oo.dipendenti_ufficio
				@risultati << item
				oo.children.each do |ooo|
					item = Hash.new
					item[:ufficio] = ooo
					item[:dipendenti] = ooo.dipendenti_ufficio
					@risultati << item
				end
			end
		end
   
  
		row = 0 
		a = s.nome
		worksheet1.merge_range('A'+(row+1).to_s+':M'+(row+1).to_s, a, format_titolo)
		worksheet1.set_row(row, 40)
		row = row + 1
  
		worksheet1.write(row, 0, " ", format1center)
		worksheet1.write(row, 1, "COS ", format1center)
		worksheet1.write(row, 2, "MATRICOLA", format1center)
		worksheet1.write(row, 3, "COGNOME", format1center)
		worksheet1.write(row, 4, "NOME ", format1center)
		worksheet1.write(row, 5, "PROFILO", format1center)
		worksheet1.write(row, 6, "POSIZIONE \r ECONOMICA", format1center)
		worksheet1.write(row, 7, "TIPO \r CONTRATTO ", format1center)
		worksheet1.write(row, 8, "TEMPO ", format1center)
		worksheet1.write(row, 9, "SERVIZIO% ", format1center)
		worksheet1.write(row, 10, "- ", format1center)
		worksheet1.write(row, 11, "PUNTEGGIO OBIETTIVI \r " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
		worksheet1.write(row, 12, "PUNTEGGIO COMPORTAMENTI \r " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
		
		worksheet1.set_row(row, 25)
		row = row + 1
  
  # in risultati ho quelli da mettere nel foglio di riepilogo
		lista_fogli_dipendenti = []  
		@risultati.each do |r|
			c = r[:ufficio].nome #nome_ufficio 
			worksheet1.merge_range('C'+(row+1).to_s+':E'+(row+1).to_s, c, format_ufficio)
			worksheet1.set_row(row, 30)
			row = row + 1
	
	 
			lista_dipendenti = r[:dipendenti]
			lista_dipendenti.each do |p|
				
				if p != nil && p != @dirigente
					
					worksheet1.write(row, 0, '1', format1center)
					worksheet1.write(row, 1, p.cos, format1center)
					worksheet1.write(row, 2, p.matricola, format1)
					worksheet1.write(row, 3, p.cognome, format1)
					worksheet1.write(row, 4, p.nome, format1)
					worksheet1.write(row, 5, p.qualifica, format1)
					worksheet1.write(row, 6, p.stringa_categoria, format1)
					worksheet1.write(row, 7, p.ruolo, format1)
					worksheet1.write(row, 8, p.tempo, format1)
					worksheet1.write(row, 9, p.servizio_percentuale, format1)
					worksheet1.write(row, 10, " ", format1)
					worksheet1.write(row, 11, " ", format1)
					worksheet1.write(row, 12, " ", format1)
	   	
					row = row + 1
				end # if p != nil
			end # ciclo lista dipendenti
		end
    end # lista_uffici  servizi e dipartimenti

	exfile.close
	send_file nome_file_out
	  
  end
  
  def riassuntivo_pagelle_x_dirigente
    puts "PARMS" 
	puts params
	registra("riassuntivo_pagelle_x_dirigente")
    @dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra("riassuntivo_pagelle_x_dirigente " + @dirigente.nominativo )
	filename = "RiassuntivoValutazioni_" + @dirigente.cognome + "_" + @dirigente.nome
    nomefileout = filename + ".xlsx"
    exfile = WriteXLSX.new(nomefileout)
	
	servizio = @dirigente.dirige.first
  
    worksheet1 = exfile.add_worksheet(sheetname = servizio.nome.truncate(30))
	worksheet1.set_landscape
	worksheet1.fit_to_pages(1, 0)
    
    indice = 1 

    format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'magenta',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	worksheet1.set_column('A:A', 3)
	worksheet1.set_column('B:B', 10)
	worksheet1.set_column('C:C', 15)
	worksheet1.set_column('D:D', 20)
	worksheet1.set_column('E:E', 20)
	worksheet1.set_column('F:F', 35)
	worksheet1.set_column('G:G', 20)
	worksheet1.set_column('H:H', 15)
	worksheet1.set_column('I:I', 20)
	worksheet1.set_column('J:J', 20)
	worksheet1.set_column('K:K', 30)
	worksheet1.set_column('L:L', 30)
	worksheet1.set_column('M:M', 30)
	
	nome_ufficio = ''
	
	
	
    @risultati = []
    @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
    end
  
  # # nel caso del segretario vanno aggiunti tutti i dirigenti
  # if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    # dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	# dirigenti.each do |d|
	 # if d.dirige.length > 0
	  # item = Hash.new
      # item[:ufficio] = d.dirige.first  #questo potrebbe essere vuoto 
      # item[:dipendenti] = d
      # @risultati << item
	 # end
	# end
  # end
  
  row = 0 
  a = servizio.nome
  worksheet1.merge_range('A'+(row+1).to_s+':K'+(row+1).to_s, a, format_titolo)
  worksheet1.set_row(row, 40)
  row = row + 1
  
  worksheet1.write(row, 0, " ", format1center)
  worksheet1.write(row, 1, "COS ", format1center)
  worksheet1.write(row, 2, "MATRICOLA", format1center)
  worksheet1.write(row, 3, "COGNOME", format1center)
  worksheet1.write(row, 4, "NOME ", format1center)
  worksheet1.write(row, 5, "PROFILO", format1center)
  worksheet1.write(row, 6, "POSIZIONE \r ECONOMICA", format1center)
  worksheet1.write(row, 7, "TIPO \r CONTRATTO ", format1center)
  worksheet1.write(row, 8, "P.T. ", format1center)
  worksheet1.write(row, 9, "NOTE ", format1center)
  worksheet1.write(row, 10, "PUNTEGGIO \r " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 11, "PUNTEGGIO \r OBIETTIVI" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 12, "PUNTEGGIO \r TOTALE" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.set_row(row, 25)
  row = row + 1
  
  # in risultati ho quelli da mettere nel foglio di riepilogo
  lista_fogli_dipendenti = []  
  @risultati.each do |r|
    c = r[:ufficio].nome #nome_ufficio 
    worksheet1.merge_range('C'+(row+1).to_s+':E'+(row+1).to_s, c, format_ufficio)
	worksheet1.set_row(row, 30)
	row = row + 1
	
	# NON SERVE METTERE IL CAPO: ESCE GIA DA DIPENDENTI_UFFICIO
	# #prima metto il capoufficio, se c'è
	# p = r[:ufficio].director
	# if p != nil
	   # # #trovata la persona
	   # # # in c dovrei avere la stringa dell'ufficio
	   # worksheet1.write(row, 0, '1', format1center)
	   # worksheet1.write(row, 1, p.cos, format1center)
	   # worksheet1.write(row, 2, p.matricola, format1)
	   # worksheet1.write(row, 3, p.cognome, format1)
	   # worksheet1.write(row, 4, p.nome, format1)
	   # worksheet1.write(row, 5, p.qualifica, format1)
	   # worksheet1.write(row, 6, p.categoria, format1)
	   # worksheet1.write(row, 7, p.ruolo, format1)
	   # worksheet1.write(row, 8, p.tempo, format1)
	   # worksheet1.write(row, 9, " ", format1)
	   # worksheet1.write(row, 10, p.punteggiofinale.round(2).to_s, format1)
	   # worksheet1.set_row(row, 20)	
	   # row = row + 1
	 # end # if p != nil
	 
	lista_dipendenti = r[:dipendenti]
	lista_dipendenti.each do |p|
     # #p = Person.where(cognome: cognome, nome: nome).first
	 if p != nil && p != @dirigente
	   # #trovata la persona
	   # # in c dovrei avere la stringa dell'ufficio
	   
	   stringa_calcolo_punteggiocomplessivo = ""
	   if !Setting.disabilita_pagelle_singole
	    if !lista_fogli_dipendenti.include?(p)
	     stringa_calcolo_punteggiocomplessivo = scheda_excel_comportamento(p, @dirigente, exfile)
		 lista_fogli_dipendenti<< p
	    end
	   end
	   worksheet1.write(row, 0, '1', format1center)
	   worksheet1.write(row, 1, p.cos, format1center)
	   worksheet1.write(row, 2, p.matricola, format1)
	   worksheet1.write(row, 3, p.cognome, format1)
	   worksheet1.write(row, 4, p.nome, format1)
	   worksheet1.write(row, 5, p.qualifica, format1)
	   worksheet1.write(row, 6, p.stringa_categoria, format1)
	   worksheet1.write(row, 7, p.ruolo, format1)
	   worksheet1.write(row, 8, p.tempo, format1)
	   worksheet1.write(row, 9, " ", format1)
	   # worksheet1.write(row, 10, p.punteggiofinale.round(2).to_s, format1)
	   # calcolato
	   puts stringa_calcolo_punteggiocomplessivo
	   if Setting.disabilita_pagelle_singole
	    worksheet1.write(row, 10, p.valutazione, format1)
		worksheet1.write(row, 11, p.raggiungimento_obiettivi, format1)
	    moltiplicatore_valutazione_pagella = p.percentuale_obiettivi 
	    moltiplicatore_valutazione_obiettivi = p.percentuale_pagella 
		stringa = "=(K" + (row+1).to_s + "+L" + (row+1).to_s + ")/(" + moltiplicatore_valutazione_pagella.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + ")"
	    worksheet1.write(row, 12, stringa, format1)
	   else
	    worksheet1.write(row, 10, "=" + stringa_calcolo_punteggiocomplessivo, format1)
	    moltiplicatore_valutazione_pagella = p.percentuale_obiettivi 
	    moltiplicatore_valutazione_obiettivi = p.percentuale_pagella 
        valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  p.punteggiofinale  + moltiplicatore_valutazione_obiettivi * p.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
        stringa = "" + moltiplicatore_valutazione_pagella.to_s + "*" +p.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + p.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s 
        worksheet1.write(row, 11, p.valutazione_dirigente_obiettivi_fasi_azioni, format1)
	    worksheet1.write(row, 12, stringa, format1)
	   end
	   worksheet1.set_row(row, 20)	
	   row = row + 1
	   
	   # aggiungo un foglio con la valutazione
	   
	   
	   
	 end # if p != nil
	end # ciclo lista dipendenti
   end
  
  exfile.close
  send_file nomefileout
  

  
  end
  
  def riassuntivo_obiettivi_x_dirigente
    puts "PARMS" 
	puts params
	
    @dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra("riassuntivo_obiettivi_x_dirigente " + @dirigente.nominativo)
	filename = "RiassuntivoObiettivi_" + @dirigente.cognome + "_" + @dirigente.nome
    nomefileout = filename + ".xlsx"
    exfile = WriteXLSX.new(nomefileout)
	
	servizio = @dirigente.dirige.first
	
	worksheet1 = exfile.add_worksheet(sheetname = servizio.nome.truncate(30))
    worksheet1.set_landscape
	worksheet1.fit_to_pages(1, 0)
	
    indice = 1 

    format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'green',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	worksheet1.set_column('A:A', 3)
	worksheet1.set_column('B:B', 10)
	worksheet1.set_column('C:C', 15)
	worksheet1.set_column('D:D', 20)
	worksheet1.set_column('E:E', 20)
	worksheet1.set_column('F:F', 35)
	worksheet1.set_column('G:G', 20)
	worksheet1.set_column('H:H', 15)
	worksheet1.set_column('I:I', 20)
	worksheet1.set_column('J:J', 20)
	worksheet1.set_column('K:K', 30)
	worksheet1.set_column('L:L', 30)
	worksheet1.set_column('M:M', 30)
	#worksheet1.set_column('N:N', 30)
	
	nome_ufficio = ''
	
	
	
    @risultati = []
    @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
    end
  
  # # nel caso del segretario vanno aggiunti tutti i dirigenti
  # if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    # dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	# dirigenti.each do |d|
	 # if d.dirige.length > 0
	  # item = Hash.new
      # item[:ufficio] = d.dirige.first  #questo potrebbe essere vuoto 
      # item[:dipendenti] = d
      # @risultati << item
	 # end
	# end
  # end
  
  row = 0 
  a = servizio.nome
  worksheet1.merge_range('A'+(row+1).to_s+':K'+(row+1).to_s, a, format_titolo)
  worksheet1.set_row(row, 40)
  row = row + 1
  
  worksheet1.write(row, 0, " ", format1center)
  worksheet1.write(row, 1, "COS ", format1center)
  worksheet1.write(row, 2, "MATRICOLA", format1center)
  worksheet1.write(row, 3, "COGNOME", format1center)
  worksheet1.write(row, 4, "NOME ", format1center)
  worksheet1.write(row, 5, "PROFILO", format1center)
  worksheet1.write(row, 6, "POSIZIONE \r ECONOMICA", format1center)
  worksheet1.write(row, 7, "TIPO \r CONTRATTO ", format1center)
  worksheet1.write(row, 8, "P.T. ", format1center)
  worksheet1.write(row, 9, "NOTE ", format1center)
  #worksheet1.write(row, 10, "- ", format1center)
  worksheet1.write(row, 10, "PUNTEGGIO OBIETTIVI \r " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 11, "PUNTEGGIO \r COMPORTAMENTO" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 12, "PUNTEGGIO \r TOTALE" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.set_row(row, 25)
  row = row + 1
  
  # in risultati ho quelli da mettere nel foglio di riepilogo
  lista_fogli_dipendenti = []  
  @risultati.each do |r|
    c = r[:ufficio].nome #nome_ufficio 
    worksheet1.merge_range('C'+(row+1).to_s+':E'+(row+1).to_s, c, format_ufficio)
	worksheet1.set_row(row, 30)
	row = row + 1
	
	lista_dipendenti = r[:dipendenti]
	lista_dipendenti.each do |p|
     # #p = Person.where(cognome: cognome, nome: nome).first
	 if p != nil && p != @dirigente
	   # #trovata la persona
	   # # in c dovrei avere la stringa dell'ufficio
	   
	   stringa_calcolo_punteggiocomplessivo_obiettivi = ""
	   if !lista_fogli_dipendenti.include?(p)
	    #stringa_calcolo_punteggiocomplessivo = scheda_excel_comportamento(p, @dirigente, exfile)
		stringa_calcolo_punteggiocomplessivo_obiettivi = scheda_excel_obiettivi(p, @dirigente, exfile)
		lista_fogli_dipendenti<< p
	   end
	   worksheet1.write(row, 0, '1', format1center)
	   worksheet1.write(row, 1, p.cos, format1center)
	   worksheet1.write(row, 2, p.matricola, format1)
	   worksheet1.write(row, 3, p.cognome, format1)
	   worksheet1.write(row, 4, p.nome, format1)
	   worksheet1.write(row, 5, p.qualifica, format1)
	   worksheet1.write(row, 6, p.stringa_categoria, format1)
	   worksheet1.write(row, 7, p.ruolo, format1)
	   worksheet1.write(row, 8, p.tempo, format1)
	   worksheet1.write(row, 9, " ", format1)
	   #worksheet1.write(row, 10, " ", format1)
	   # worksheet1.write(row, 10, p.punteggiofinale.round(2).to_s, format1)
	   # calcolato
	   puts stringa_calcolo_punteggiocomplessivo_obiettivi
	   worksheet1.write(row, 10, "=" + stringa_calcolo_punteggiocomplessivo_obiettivi, format1)
	   moltiplicatore_valutazione_pagella = p.percentuale_obiettivi 
	   moltiplicatore_valutazione_obiettivi = p.percentuale_pagella
       valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  p.punteggiofinale  + moltiplicatore_valutazione_obiettivi * p.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
       # caso UTI2019 mezzo e mezzo non si fa
	   stringa = "" + moltiplicatore_valutazione_pagella.to_s + "*" +p.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + p.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s 
       worksheet1.write(row, 11, p.punteggiofinale, format1)
	   worksheet1.write(row, 12, stringa, format1)
	   
	   
	   worksheet1.set_row(row, 20)	
	   row = row + 1
	   
	   
	   
	 end # if p != nil
	end # ciclo lista dipendenti
   end
  
  exfile.close
  send_file nomefileout
 
 end

 def riassuntivo_pagelle_obiettivi_x_dirigente
 
    puts "PARMS" 
	puts params
		
    @dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra("riassuntivo_pagelle_obiettivi_x_dirigente " + @dirigente.nominativo)
	filename = "RiassuntivoGenerale_Valutazioni_Obiettivi_" + @dirigente.cognome + "_" + @dirigente.nome
    nomefileout = filename + ".xlsx"
    exfile = WriteXLSX.new(nomefileout)
	
	servizio = @dirigente.dirige.first
  
    worksheet1 = exfile.add_worksheet(sheetname = servizio.nome.truncate(30))
    worksheet1.set_landscape
	worksheet1.fit_to_pages(1, 0)
	
    indice = 1 

    format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'magenta',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	worksheet1.set_column('A:A', 3)
	worksheet1.set_column('B:B', 10)
	worksheet1.set_column('C:C', 15)
	worksheet1.set_column('D:D', 20)
	worksheet1.set_column('E:E', 20)
	worksheet1.set_column('F:F', 35)
	worksheet1.set_column('G:G', 20)
	worksheet1.set_column('H:H', 15)
	worksheet1.set_column('I:I', 20)
	worksheet1.set_column('J:J', 20)
	worksheet1.set_column('K:K', 30)
	worksheet1.set_column('L:L', 30)
	worksheet1.set_column('M:M', 30)
	
	nome_ufficio = ''
		
    @risultati = []
    @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
    end
  
  
  row = 0 
  a = servizio.nome
  worksheet1.merge_range('A'+(row+1).to_s+':K'+(row+1).to_s, a, format_titolo)
  worksheet1.set_row(row, 40)
  row = row + 1
  
  worksheet1.write(row, 0, " ", format1center)
  worksheet1.write(row, 1, "COS ", format1center)
  worksheet1.write(row, 2, "MATRICOLA", format1center)
  worksheet1.write(row, 3, "COGNOME", format1center)
  worksheet1.write(row, 4, "NOME ", format1center)
  worksheet1.write(row, 5, "PROFILO", format1center)
  worksheet1.write(row, 6, "POSIZIONE \r ECONOMICA", format1center)
  worksheet1.write(row, 7, "TIPO \r CONTRATTO ", format1center)
  worksheet1.write(row, 8, "P.T. ", format1center)
  worksheet1.write(row, 9, "NOTE ", format1center)
  worksheet1.write(row, 10, "PUNTEGGIO \r " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 11, "PUNTEGGIO \r OBIETTIVI" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.write(row, 12, "PUNTEGGIO \r TOTALE" + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-"), format1center)
  worksheet1.set_row(row, 25)
  row = row + 1
  
  # in risultati ho quelli da mettere nel foglio di riepilogo
  lista_fogli_dipendenti = []  
  @risultati.each do |r|
    c = r[:ufficio].nome #nome_ufficio 
    worksheet1.merge_range('C'+(row+1).to_s+':E'+(row+1).to_s, c, format_ufficio)
	worksheet1.set_row(row, 30)
	row = row + 1
	
	 
	lista_dipendenti = r[:dipendenti]
	lista_dipendenti.each do |p|
     # #p = Person.where(cognome: cognome, nome: nome).first
	 if p != nil && p != @dirigente
	   # #trovata la persona
	   # # in c dovrei avere la stringa dell'ufficio
	   
	   
	   stringa_calcolo_punteggiocomplessivo_pagella = ""
	   stringa_calcolo_punteggiocomplessivo_obiettivi = ""
	   if !lista_fogli_dipendenti.include?(p)
	    risultato_foglio = scheda_excel_pagella_obiettivi(p, @dirigente, exfile)
		stringa_calcolo_punteggiocomplessivo_pagella = risultato_foglio[0]
		stringa_calcolo_punteggiocomplessivo_obiettivi = risultato_foglio[1]
		lista_fogli_dipendenti<< p
	   end
	   worksheet1.write(row, 0, '1', format1center)
	   worksheet1.write(row, 1, p.cos, format1center)
	   worksheet1.write(row, 2, p.matricola, format1)
	   worksheet1.write(row, 3, p.cognome, format1)
	   worksheet1.write(row, 4, p.nome, format1)
	   worksheet1.write(row, 5, p.qualifica, format1)
	   worksheet1.write(row, 6, p.stringa_categoria, format1)
	   worksheet1.write(row, 7, p.ruolo, format1)
	   worksheet1.write(row, 8, p.tempo, format1)
	   worksheet1.write(row, 9, " ", format1)
	   # worksheet1.write(row, 10, p.punteggiofinale.round(2).to_s, format1)
	   # calcolato
	   
	   worksheet1.write(row, 10, "=" + stringa_calcolo_punteggiocomplessivo_pagella, format1)
	   moltiplicatore_valutazione_pagella = p.percentuale_pagella 
	   moltiplicatore_valutazione_obiettivi = p.percentuale_obiettivi 
       valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  p.punteggiofinale  + moltiplicatore_valutazione_obiettivi * p.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
       stringa = "=(" + moltiplicatore_valutazione_pagella.to_s + "*(" + stringa_calcolo_punteggiocomplessivo_pagella + ") + " + moltiplicatore_valutazione_obiettivi.to_s + "*(" + stringa_calcolo_punteggiocomplessivo_obiettivi + "))/(" + moltiplicatore_valutazione_pagella.to_s + "+" + moltiplicatore_valutazione_obiettivi.to_s + ")" 
       worksheet1.write(row, 11, "=" + stringa_calcolo_punteggiocomplessivo_obiettivi, format1)
	   worksheet1.write(row, 12, stringa, format1)
	   
	   worksheet1.set_row(row, 20)	
	   row = row + 1
	   
	   
	 end # if p != nil
	 end # ciclo lista dipendenti
    end
  
  exfile.close
  send_file nomefileout
  
    
 end
  
  def view_check_matricole
  
  end
  
  def check_matricole
    file = params[:file]
    filename = params[:file].original_filename
    puts "FILENAME " + filename
    
    xls = Roo::Spreadsheet.open(file.path)
    xls.info
    nome_foglio = xls.sheets[0]
    foglio_personale = xls.sheet(nome_foglio)
    
    last_row = foglio_personale.last_row
    indice = 1 
	nome_ufficio = ''
	@result = []
	@righe_non_trovate = []
		
	for row in indice..last_row
	 cognome = ''
	 nome = ''
	 
	 matr = foglio_personale.cell('A', row)
	 cognome =  foglio_personale.cell('B', row)
	 nome =  foglio_personale.cell('C', row)
	 matricola = matr.to_i.to_s.rjust(7, '0')
	 p = Person.where(matricola: matricola).first
	 if p != nil
	   if cognome != p.cognome || nome != p.nome
	    @result<< "DIFFERENZA " + matricola + " " + cognome + " " + nome + " " + p.cognome + " " + p.nome 
	   end
	 else
	   @result<< "MATRICOLA NON TROVATA " + matricola + " " + cognome + " " + nome
	 end
	 
	 plist =  Person.where(cognome: cognome, nome: nome)
	 if plist.length > 1
	   @result<< "OMONIMIO O DOPPIO " +  cognome + " " + nome
	 end
	 if plist.length == 0
	   @result<< "NOMINATIVO NON TROVATO " + matricola + " " + cognome + " " + nome
	 end
	 
	   # #if p.cognome+p.nome
	 # end
	 
	end
  end
  
  def importafrompeg
  
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    
	ris = Person.import_from_peg(params[:file]) #pure viene lanciato il metodo del model
	@nontrovate = ris[1]
	@persone = ris[0]
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  
  end
  
  def importazionefrompeg
  
  end
  
  def importapagella
  
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    
	res = Person.importapagella(params[:file]) #pure viene lanciato il metodo del model
	 
	@Errori = res[0]
	@Importati =  res[1]
	
	# qua va automaticamente alla vista importa con la variabile valorizzata
  
  end
  
  def importazionepagella
  
  end
  
  
  def importa_organico
  
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    
	ris = Person.importa_organico(params[:file]) #pure viene lanciato il metodo del model
	
	@aggiunte = ris[0]
	@scartate = ris[2]
	@modificate = ris[3]
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  
  end
  
  def importazione_organico
  
  end
  
  
  
  def assegnaobiettivi
  
   @dirigente = nil
   @target_array = []
   @assegnatari = []
   
   @testo = ""
   @dirigenti = []
   
   #@dirigenti = Person.dirigenti
   # con il filtro faccio vedere solo quello che deve vedere
   @dirigenti = filtro_dirigenti
   
	
  end
  
  def assegnaobiettivi_sel
  
   @dirigente = nil
   @target_array = []
   @assegnatari = []
   
   @testo = ""
   @dirigenti = []
   
   #@dirigenti = Person.dirigenti
   # con il filtro faccio vedere solo quello che deve vedere
   @dirigenti = filtro_dirigenti
   
	
  end
  
  def searchassegnaobiettivixdirigente
    puts params
	@dirigente = nil
    @target_array = []
	@assegnatari = []
	
  
    @dirigente = Person.find(params[:person][:id])
	
    @target_array = @dirigente.target_array
    
    
	respond_to do |format|
	   
	   format.js   {render :action => "assegnaobiettivi" }
    end
	
  end
  
  def searchassegnaobiettivixdirigente_sel
    puts params
	@dirigente = nil
    @target_array = []
	@assegnatari = []
	@opzione_obiettivi = ""
	@opzione_fasi = ""
	@opzione_azioni = ""
	@opzione_opere = ""
	@sel = ""
	
	puts params[:opzione_obiettivi]
	@opzione_obiettivi = params[:opzione_obiettivi]
	@opzione_fasi = params[:opzione_fasi]
	@opzione_azioni = params[:opzione_azioni]
	@opzione_opere = params[:opzione_opere]
  
    @dirigente = Person.find(params[:person][:id])
	
    if @opzione_obiettivi.eql? "1"
	 @sel = "o"
	 @target_array += @dirigente.target_array_select(@sel)
	end
	if @opzione_fasi.eql? "1"
	 @sel = "f"
     @target_array += @dirigente.target_array_select(@sel)
	end
	if @opzione_azioni.eql? "1"
	 @sel = "a"
	 @target_array += @dirigente.target_array_select(@sel)
	end
	if @opzione_opere.eql? "1"
	 @sel = "p"
	 @target_array += @dirigente.target_array_select(@sel)
	end
    
    
	respond_to do |format|
	   
	   format.js   {render :action => "assegnaobiettivi_sel" }
    end
	
  end
  
  def selecttarget
    puts "parametri selecttarget"
	puts params
	@dirigente = nil
    @target_array = []
    @assegnatari = []
    @scelta = nil
	@sel = ""
	
    @testo = ""
    @dirigenti = []
	
	if params[:sel] != nil
	 @sel = params[:sel]
	else
     if params[:person] != nil
	   @sel = params[:person][:sel]
	 end
	end
	
	if params[:dirigente] != nil
	 @dirigente = Person.find(params[:dirigente])
	else
	 @dirigente = Person.find(params[:person][:dirigente_id])
	end
	puts @dirigente.cognome
	
	if params[:target] != nil
	  ricevuto = params[:target]
	  puts ricevuto
	  spezza = ricevuto.split("-")
	  puts spezza[0]
	  case spezza[0]
	  when "o"
	   a = spezza[1] + " " + "OperationalGoal"
	  when "f"
	   a = spezza[1] + " " + "Phase" 
	  when "a"
	   a = spezza[1] + " " + "SimpleAction" 
	  when "p"
	   a = spezza[1] + " " + "Opera"
	  end
	else
	 a = params[:person][:selected]
	end
	puts a
	valori = a.split(" ")
	
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
    
	
	
	case valori[1]
    when "OperationalGoal"
      @scelta = OperationalGoal.find(valori[0])
    when "Phase"
      @scelta = Phase.find(valori[0])
    when "SimpleAction"
	  @scelta = SimpleAction.find(valori[0])
	when "Opera"
	  @scelta = Opera.find(valori[0])
	end
	if @scelta != nil
	 @assegnatari = @scelta.assegnatari
	 puts "assegnatari"
	 #@target_array<< @scelta
	end
	
	puts "TARGET = " + @scelta.id.to_s + " " + @scelta.class.name
	#puts "TARGET = " + @target_array.first.id.to_s + " " + @target_array.first.class.name
	
	if @sel.length > 0
	  @target_array = @dirigente.target_array_select(@sel)
	else 
      @target_array = @dirigente.target_array
	end
	puts "TARGET = " + @scelta.id.to_s + " " + @scelta.class.name
	respond_to do |format|
	   if @sel.length > 0
	    format.js   { render :action => "assegnaobiettivi_sel" }
	    format.html   { render :action => "assegnaobiettivi" }
	   else
	    format.js   { render :action => "assegnaobiettivi" }
	   end
	    
    end
	
  end
  
  def removeassegnazione
    puts "parametri removeassegnazione"
	puts params
	@dirigente = nil
    @target_array = []
    @assegnatari = []
    @scelta = nil
    @testo = ""
    @dirigenti = []
	@sel = ""
	
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    
	@sel = params[:person][:sel]
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	
	@assegnatario = Person.find(params[:person][:assegnatario_id])
	
	@target_array = @dirigente.target_array_select(@sel)
    
	
	case params[:person][:target_type]
    when "OperationalGoal"
      @scelta = OperationalGoal.find(params[:person][:target_id])
    when "Phase"
      @scelta = Phase.find(params[:person][:target_id])
    when "SimpleAction"
	  @scelta = SimpleAction.find(params[:person][:target_id])
	when "Opera"
	  @scelta = Opera.find(params[:person][:target_id])
	end
	
	@scelta.assegnatari.delete(@assegnatario)
	registra("REMOVEASSEGNAZIONE " + @assegnatario.nominativo + " t.id:" + @scelta.id.to_s + " " + @scelta.denominazione_completa )
	
	
	if @scelta != nil
	 @assegnatari = @scelta.assegnatari
	end

	respond_to do |format|
	   if @sel.length > 0
	    format.js   { render :action => "assegnaobiettivi_sel" }
	    
	   else
	    format.js   { render :action => "assegnaobiettivi" }
	   end
	    
    end
	
  end
  
  def aggiungiassegnazioni
     puts "parametri aggiungiassegnazioni"
    registra("AGGIUNGI ASSEGNAZIONI")
	puts params
	@dirigente = nil
    @target_array = []
    @assegnatari = []
    @scelta = nil
    @testo = ""
    @dirigenti = []
	@sel = ""
	
	@sel += params[:person][:sel].to_s
	
	#@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	
	@target_array = @dirigente.target_array_select(@sel)
	
	@valore = params[:person][:value]
    
	lista = []
	if params[:person][:text] != nil
	  @testo = params[:person][:text]
	  @testo_attuale = @testo
	  righe = @testo_attuale.split(/(\n)/)
	  @testo = ""
	  righe.each do |r|
	   cognome_nome = r.strip.upcase
	   p = Person.cerca(cognome_nome)
       if p != nil
         lista<< p
       end		 
	  end 
	end
	
	if params[:person][:person_id] != nil
	  p = Person.find(params[:person][:person_id])
	  @valore = params[:person][:value]
	  if p != nil
	    lista<< p
      end
	end
	
	lista.each do |p|
	    if p != nil
	     case params[:person][:target_type]
         when "OperationalGoal"
           @scelta = OperationalGoal.find(params[:person][:target_id])
		   # l'assegnazione è valida solo se non esiste già 
		   if !@scelta.assegnatari.include?(p)
		    @scelta.assegnatari<< p
		    @scelta.save
		   end
		   ga = GoalAssignment.where(persona: p, obiettivo: @scelta).first
		   if ga != nil
			ga.wheight = @valore
			ga.save
			registra("Modifica assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
         when "Phase"
           @scelta = Phase.find(params[:person][:target_id])
		   # l'assegnazione è valida solo se non esiste già 
		   if !@scelta.assegnatari.include?(p)
		      @scelta.assegnatari<< p
		      @scelta.save
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end 
		   fa = PhaseAssignment.where(persona: p, fase: @scelta).first
		   if fa != nil
			fa.wheight = @valore
			fa.save
			registra("Modifica assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
         when "SimpleAction"
	       @scelta = SimpleAction.find(params[:person][:target_id])
		   # l'assegnazione è valida solo se non esiste già 
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
		   saa = SimpleActionAssignment.where(persona: p, azione: @scelta).first
		   if saa != nil
			saa.wheight = @valore
			saa.save
			registra("Modifica assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
	     when "Opera"
	       @scelta = Opera.find(params[:person][:target_id])
		   # l'assegnazione è valida solo se non esiste già 
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
		   oa = OperaAssignment.where(persona: p, opera: @scelta).first
		   if oa != nil
			oa.wheight = @valore
			oa.save
			registra("Modifica assegnazione " + p.nominativo + " " + @scelta.denominazione + " peso: " + @valore.to_s)
		   end
	     end
		
        else
         # non ho trovato la persona la rimetto nella text area
		 @testo = @testo + r
		end		
	
	end
	
	if @scelta != nil
	 @assegnatari = @scelta.assegnatari
	end
	
		
	respond_to do |format|
	   if @sel.length > 0
	    format.js   { render :action => "assegnaobiettivi_sel" }
	    
	   else
	    format.js   { render :action => "assegnaobiettivi" }
	   end
	    
    end
	
  end
  
  def aggiungitargetadipendente
    #aggiunge un obiettivo ad un dipendente
	puts params
	@risultati = []
	
    @dirigente = Person.find(params[:person][:dirigente_id])
	p = Person.find(params[:person][:person_id])
	scelta = params[:person][:selected]
	array = scelta.split(" ")
	
	if p != nil
	  case array[1]
         when "OperationalGoal"
           @scelta = OperationalGoal.find(array[0])
		   # non permette la doppia assegnazione
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		     registra("Aggiunta assegnazione " + p.nominativo + " " + @scelta.denominazione)
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione )
		   end
		   
		   # ga = GoalAssignment.where(persona: p, obiettivo: @scelta).first
		   # if ga != nil
			# ga.wheight = @valore
			# ga.save
		   # end
         when "Phase"
           @scelta = Phase.find(array[0])
		   # non permette la doppia assegnazione
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		     registra("Aggiunta assegnazione " + p.nominativo + " " + @scelta.denominazione)
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione )
		   end
		   # fa = PhaseAssignment.where(persona: p, fase: @scelta).first
		   # if fa != nil
			# fa.wheight = @valore
			# fa.save
		   # end
         when "SimpleAction"
	       @scelta = SimpleAction.find(array[0])
		   # non permette la doppia assegnazione
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		     registra("Aggiunta assegnazione " + p.nominativo + " " + @scelta.denominazione)
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione )
		   end
		   # saa = SimpleActionAssignment.where(persona: p, azione: @scelta).first
		   # if saa != nil
			# saa.wheight = @valore
			# saa.save
		   # end
	     when "Opera"
	       @scelta = Opera.find(array[0])
		   # non permette la doppia assegnazione
		   if !@scelta.assegnatari.include?(p)
		     @scelta.assegnatari<< p
		     @scelta.save
		     registra("Aggiunta assegnazione " + p.nominativo + " " + @scelta.denominazione)
		   else
		      registra("Tentativo doppia assegnazione " + p.nominativo + " " + @scelta.denominazione )
		   end
		   # oa = OperaAssignment.where(persona: p, opera: @scelta).first
		   # if oa != nil
			# oa.wheight = @valore
			# oa.save
		   # end
	     end
	end
	
	@dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	  end
     end
    end
	
	respond_to do |format|
	    format.js   {render :action => "pesisearchxdirigente" }
    end
	
  end
  
  def scheda_valutazione_dirigente
   #@dirigenti = Person.dirigenti
   # con il filtro faccio vedere solo quello che deve vedere
   @dirigenti = filtro_dirigenti
	
  end
  
  def scheda_valutazione_select_dirigente
    @dirigente = Person.find(params[:person][:id])
	@obiettivi_individuali_digruppo = []
	@obiettivi_strategici = []
	@obiettivi_di_ente = []
	@obiettivi_individuali = []
	@servizi = []
	
	lista1 = @dirigente.obiettivi_responsabile
	lista1.each do |o|
	  	 
	  if o.obiettivo_di_gruppo
	    @obiettivi_individuali_digruppo<< o
	  end
	  if o.obiettivo_di_ente
	    @obiettivi_di_ente<< o
	  end
	  if o.obiettivo_individuale
	    @obiettivi_individuali<< o
	  end
	  if o.indice_strategicita
	    @obiettivi_strategici<< o
		if ! @servizi.include?(o.struttura_organizzativa) 
         @servizi<< o.struttura_organizzativa
        end	
	  end
	end
	
	lista1 = @dirigente.obiettivi_altro_responsabile
	lista1.each do |o|
	  if o.obiettivo_di_gruppo
	    @obiettivi_individuali_digruppo<< o
	  end
	  if o.obiettivo_di_ente
	    @obiettivi_di_ente<< o
	  end
	  if o.indice_strategicita
	    @obiettivi_strategici<< o
	  end
	  if o.obiettivo_individuale
	    @obiettivi_individuali<< o
	  end
	end 
	
	ufficio = @dirigente.dirige.first
	if ufficio != nil 
	 if ufficio.parent == nil
	   @dipartimento = ufficio
	 else
	   @dipartimento = ufficio.parent
	 end
	else
	   @dipartimento = nil
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	@obiettivi = @dirigente.obiettivi_responsabile
	
	respond_to do |format|
	   format.js   {render :action => "scheda_valutazione_select_dirigente" }
    end
	
  end
  
  def valutazione_obiettivi_dipendente
    @dirigente =  nil
	@dipendente = nil
    #@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
		
  end
  
  def copia_assegnazione_obiettivi
    @dirigente =  nil
	@dipendente = nil
    #@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
  end
  
  
  def copia_assegnazione_obiettivi_dipendente
        
	@dirigente =  nil
	@dipendente = nil
	@destinatario = nil
	@dipendenti = []
	@targets_da = []
	@targets_a = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@destinatario = Person.find(params[:person][:destinatario_id])
	@dipendente = Person.find(params[:person][:dipendente_id])
	@dirigenti = Person.dirigenti
	
	if ((@dipendente != nil) && (@destinatario != nil))
	  lista = @dipendente.obiettivi
	  lista.each do |t|
	   @destinatario.obiettivi<< t
	   @destinatario.save
	   peso = (GoalAssignment.where(persona: @dipendente, obiettivo: t).first != nil ? GoalAssignment.where(persona: @dipendente, obiettivo: t).first.wheight : 0 )
	   ga = GoalAssignment.where(persona: @destinatario, obiettivo: t).first 
       ga.wheight = peso
       ga.save	   
	  end
	  lista = @dipendente.fasi
	  lista.each do |t|
	   @destinatario.fasi<< t
	   @destinatario.save
	   peso = (PhaseAssignment.where(persona: @dipendente, fase: t).first != nil ? PhaseAssignment.where(persona: @dipendente, fase: t).first.wheight : 0 )
	   fa = PhaseAssignment.where(persona: @destinatario, fase: t).first 
       fa.wheight = peso
       fa.save	   
	  end
	  lista = @dipendente.azioni
	  lista.each do |t|
	   @destinatario.azioni<< t
	   @destinatario.save
	   peso = (SimpleActionAssignment.where(persona: @dipendente, azione: t).first != nil ? SimpleActionAssignment.where(persona: @dipendente, azione: t).first.wheight : 0 )
	   saa = SimpleActionAssignment.where(persona: @destinatario, azione: t).first 
       saa.wheight = peso
       saa.save	   
	  end
	  
	  lista = @dipendente.obiettivi_altro_responsabile
	  lista.each do |t|
	   @destinatario.obiettivi_altro_responsabile<< t
	   @destinatario.save
	   peso = (GoalAssignment.where(persona: @dipendente, obiettivo: t).first != nil ? GoalAssignment.where(persona: @dipendente, obiettivo: t).first.wheight : 0 )
	   ga = GoalAssignment.where(persona: @destinatario, obiettivo: t).first 
       ga.wheight = peso
       ga.save	   
	  end
	
	  # forse non ha senso copiare anche le assegnazioni come responsabile
	  # lista = @dipendente.obiettivi_responsabile
	  # lista.each do |t|
	   # @destinatario.obiettivi_responsabile<< t
	   # @destinatario.save
	   # peso = (GoalAssignment.where(persona: @dipendente, obiettivo: t).first != nil ? GoalAssignment.where(persona: @dipendente, obiettivo: t).first.wheight : 0 )
	   # ga = GoalAssignment.where(persona: @destinatario, obiettivo: t).first 
       # ga.wheight = peso
       # ga.save	   
	  # end
	  
	  # lista = @dipendente.fasi_responsabile
	  # lista.each do |t|
	   # @destinatario.fasi_responsabile<< t
	   # @destinatario.save
	   # peso = (PhaseAssignment.where(persona: @dipendente, fase: t).first != nil ? PhaseAssignment.where(persona: @dipendente, fase: t).first.wheight : 0 )
	   # fa = PhaseAssignment.where(persona: @destinatario, fase: t).first 
       # fa.wheight = peso
       # fa.save	   
	  # end
	  
	  # lista = @dipendente.azioni_responsabile
	  # lista.each do |t|
	   # @destinatario.azioni_responsabile<< t
	   # @destinatario.save
	   # peso = (SimpleActionAssignment.where(persona: @dipendente, azione: t).first != nil ? SimpleActionAssignment.where(persona: @dipendente, azione: t).first.wheight : 0 )
	   # saa = SimpleActionAssignment.where(persona: @destinatario, azione: t).first 
       # saa.wheight = peso
       # saa.save	   
	  # end
	
	  lista = @dipendente.opere
	  lista.each do |t|
	   @destinatario.opere<< t
	   @destinatario.save
	   peso = (OperaAssignment.where(persona: @dipendente, opera: t).first != nil ? OperaAssignment.where(persona: @dipendente, opera: t).first.wheight : 0 )
	   opa = OperaAssignment.where(persona: @destinatario, opera: t).first 
       opa.wheight = peso
       opa.save	   
	  end
	  
	  lista = @dipendente.opere_assegnate
	  lista.each do |t|
	   @destinatario.opere_assegnate<< t
	   @destinatario.save
	   peso = (OperaAssignment.where(persona: @dipendente, opera: t).first != nil ? OperaAssignment.where(persona: @dipendente, opera: t).first.wheight : 0 )
	   opa = OperaAssignment.where(persona: @destinatario, opera: t).first 
       opa.wheight = peso
       opa.save	   
	  end
	 
	
	end
		
	if @dipendente != nil
	  lista1 = @dipendente.obiettivi
	  lista2 = @dipendente.fasi
	  lista3 = @dipendente.azioni
	  lista4 = @dipendente.obiettivi_altro_responsabile
	
	  lista5 = @dipendente.obiettivi_responsabile
	  lista6 = @dipendente.fasi_responsabile
	  lista7 = @dipendente.azioni_responsabile
	
	  lista8 = @dipendente.opere
	  lista9 = @dipendente.opere_assegnate
	
	
	  lista1.each do |t|
	    @targets_da<< t
	  end
	
	  lista2.each do |t|
	    @targets_da<< t
	  end
	
	  lista3.each do |t|
	    @targets_da<< t
	  end
	
	  lista4.each do |t|
	    @targets_da<< t
	  end
	
	  lista5.each do |t|
	    @targets_da<< t
	  end
	
	  lista6.each do |t|
	    @targets_da<< t
	  end
	
	  lista7.each do |t|
	    @targets_da<< t
	  end
    
	  lista8.each do |t|
	    @targets_da<< t
	  end
	
	  lista9.each do |t|
	    @targets_da<< t
	  end
	end
	
	if @destinatario != nil
	  lista1 = @destinatario.obiettivi
	  lista2 = @destinatario.fasi
	  lista3 = @destinatario.azioni
	  lista4 = @destinatario.obiettivi_altro_responsabile
	
	  lista5 = @destinatario.obiettivi_responsabile
	  lista6 = @destinatario.fasi_responsabile
	  lista7 = @destinatario.azioni_responsabile
	
	  lista8 = @destinatario.opere
	  lista9 = @destinatario.opere_assegnate
	
	
	  lista1.each do |t|
	    @targets_a<< t
	  end
	
	  lista2.each do |t|
	    @targets_a<< t
	  end
	
	  lista3.each do |t|
	    @targets_a<< t
	  end
	
	  lista4.each do |t|
	    @targets_a<< t
	  end
	
	  lista5.each do |t|
	    @targets_a<< t
	  end
	
	  lista6.each do |t|
	    @targets_a<< t
	  end
	
	  lista7.each do |t|
	    @targets_a<< t
	  end
    
	  lista8.each do |t|
	    @targets_a<< t
	  end
	
	  lista9.each do |t|
	    @targets_a<< t
	  end
	end
	
	@ufficio = @dipendente.ufficio
	if @ufficio != nil
	 if @ufficio.parent == nil
	   @dipartimento = @ufficio
	 else
	   @dipartimento = @ufficio.parent
	 end
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	
	respond_to do |format|
	    format.js   {render :action => "scheda_copia_assegnazione_obiettivi_dipendente" }
    end
  
		
  end
  
  def scelta_dirigente_copia_assegnazione_obiettivi_dipendente
    puts "scelta_dirigente_copia_assegnazione_obiettivi_dipendente"
    @dirigente =  nil
	@dipendente = nil
	@dipendenti = []
	@targets_da = []
	@targets_a = []
	
	@dirigente = Person.find(params[:person][:id])
	puts @dirigente.cognome
	@dipendenti = @dirigente.dipendenti_sotto
	puts @dipendenti.length
	
	respond_to do |format|
	   format.js   {render :action => "scheda_copia_assegnazione_obiettivi_dipendente" }
    end
  
  end
  
  def scelta_dipendente_copia_assegnazione_obiettivi
  
    puts "SCELTA_DIPENDENTE_COPIA_OBIETTIVI_DIPENDENTE"
	puts params
	
    @dirigente =  nil
	@dipendente = nil
	@destinatario = nil
	@dipendenti = []
	@targets_da = []
	@targets_a = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@dipendente = Person.find(params[:person][:id])
	
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	
	lista8 = @dipendente.opere
	lista9 = @dipendente.opere_assegnate
	
	
	lista1.each do |t|
	  @targets_da<< t
	end
	
	lista2.each do |t|
	  @targets_da<< t
	end
	
	lista3.each do |t|
	  @targets_da<< t
	end
	
	lista4.each do |t|
	  @targets_da<< t
	end
	
	lista5.each do |t|
	  @targets_da<< t
	end
	
	lista6.each do |t|
	  @targets_da<< t
	end
	
	lista7.each do |t|
	  @targets_da<< t
	end
    
	lista8.each do |t|
	  @targets_da<< t
	end
	
	lista9.each do |t|
	  @targets_da<< t
	end
	
	@ufficio = @dipendente.ufficio
	if @ufficio != nil
	 if @ufficio.parent == nil
	   @dipartimento = @ufficio
	 else
	   @dipartimento = @ufficio.parent
	 end
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	
	respond_to do |format|
	    format.js   {render :action => "scheda_copia_assegnazione_obiettivi_dipendente" }
    end
  
  end 
  
  def scelta_destinatario_copia_assegnazione_obiettivi
  
    puts "SCELTA_DESTINATARIO_COPIA_OBIETTIVI_DIPENDENTE"
	puts params
	
    @dirigente =  nil
	@dipendente = nil
	@destinatario = nil
	@dipendenti = []
	@targets_da = []
	@targets_a = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@destinatario = Person.find(params[:person][:id])
	@dipendente = Person.find(params[:person][:dipendente_id])
	
	if @dipendente != nil
	  lista1 = @dipendente.obiettivi
	  lista2 = @dipendente.fasi
	  lista3 = @dipendente.azioni
	  lista4 = @dipendente.obiettivi_altro_responsabile
	
	  lista5 = @dipendente.obiettivi_responsabile
	  lista6 = @dipendente.fasi_responsabile
	  lista7 = @dipendente.azioni_responsabile
	
	  lista8 = @dipendente.opere
	  lista9 = @dipendente.opere_assegnate
	
	
	  lista1.each do |t|
	    @targets_da<< t
	  end
	
	  lista2.each do |t|
	    @targets_da<< t
	  end
	
	  lista3.each do |t|
	    @targets_da<< t
	  end
	
	  lista4.each do |t|
	    @targets_da<< t
	  end
	
	  lista5.each do |t|
	    @targets_da<< t
	  end
	
	  lista6.each do |t|
	    @targets_da<< t
	  end
	
	  lista7.each do |t|
	    @targets_da<< t
	  end
    
	  lista8.each do |t|
	    @targets_da<< t
	  end
	
	  lista9.each do |t|
	    @targets_da<< t
	  end
	end
	
	if @destinatario != nil
	  lista1 = @destinatario.obiettivi
	  lista2 = @destinatario.fasi
	  lista3 = @destinatario.azioni
	  lista4 = @destinatario.obiettivi_altro_responsabile
	
	  lista5 = @destinatario.obiettivi_responsabile
	  lista6 = @destinatario.fasi_responsabile
	  lista7 = @destinatario.azioni_responsabile
	
	  lista8 = @destinatario.opere
	  lista9 = @destinatario.opere_assegnate
	
	
	  lista1.each do |t|
	    @targets_a<< t
	  end
	
	  lista2.each do |t|
	    @targets_a<< t
	  end
	
	  lista3.each do |t|
	    @targets_a<< t
	  end
	
	  lista4.each do |t|
	    @targets_a<< t
	  end
	
	  lista5.each do |t|
	    @targets_a<< t
	  end
	
	  lista6.each do |t|
	    @targets_a<< t
	  end
	
	  lista7.each do |t|
	    @targets_a<< t
	  end
    
	  lista8.each do |t|
	    @targets_a<< t
	  end
	
	  lista9.each do |t|
	    @targets_a<< t
	  end
	end
	
	@ufficio = @dipendente.ufficio
	if @ufficio != nil
	 if @ufficio.parent == nil
	   @dipartimento = @ufficio
	 else
	   @dipartimento = @ufficio.parent
	 end
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	
	respond_to do |format|
	    format.js   {render :action => "scheda_copia_assegnazione_obiettivi_dipendente" }
    end
  
  end 
  
  def copia_assegnazioni_dipendente
    
	@dirigente =  nil
	@dipendente = nil
	@destinatario = nil
	@dipendenti = []
	@targets = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@dipendente = Person.find(params[:person][:id])
	
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	
	lista8 = @dipendente.opere
	lista9 = @dipendente.opere_assegnate
	
	
	lista1.each do |t|
	  @targets<< t
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	lista5.each do |t|
	  @targets<< t
	end
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
    
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	@ufficio = @dipendente.ufficio
	if @ufficio != nil
	 if @ufficio.parent == nil
	   @dipartimento = @ufficio
	 else
	   @dipartimento = @ufficio.parent
	 end
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
    
	respond_to do |format|
	    format.js   {render :action => "scheda_copia_assegnazione_obiettivi_dipendente" }
    end	
	
  end
  
  def scelta_dirigente_valutazione_obiettivi_dipendente
    puts "SCELTA_DIRIGENTE_VALUTAZIONE_OBIETTIVI_DIPENDENTE"
    @dirigente =  nil
	@dipendente = nil
	@dipendenti = []
	
	@dirigente = Person.find(params[:person][:id])
	puts @dirigente.cognome
	@dipendenti = @dirigente.dipendenti_sotto
	puts @dipendenti.length
	
	respond_to do |format|
	   format.js   {render :action => "scheda_valutazione_obiettivi_dipendente" }
    end
  
  end
  
  def scelta_dipendente_valutazione_obiettivi_dipendente
    puts "scelta_dipendente_valutazione_obiettivi_dipendente"
	puts params
	
    @dirigente =  nil
	@dipendente = nil
	@dipendenti = []
	@targets = []
	
	@dirigente = Person.find(params[:person][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@dipendente = Person.find(params[:person][:id])
	
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	
	lista8 = @dipendente.opere
	lista9 = @dipendente.opere_assegnate
	
	
	lista1.each do |t|
	  @targets<< t
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	lista5.each do |t|
	  @targets<< t
	end
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
    
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	@ufficio = @dipendente.ufficio
	if @ufficio != nil
	 if @ufficio.parent == nil
	   @dipartimento = @ufficio
	 else
	   @dipartimento = @ufficio.parent
	 end
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	
	
	
	respond_to do |format|
	   format.js   {render :action => "scheda_valutazione_obiettivi_dipendente" }
    end
	
  end
  
  def scheda_valutazione_obiettivi_dipendente
    
	@dirigente =  nil
	@dipendente = nil
    
    @dipendente = Person.find(params[:person][:id])
	@targets = []
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	lista8 = @dipendente.opere_assegnate
	lista9 = @dipendente.opere
	
	
	lista1.each do |t|
	  @targets<< t
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	lista5.each do |t|
	  @targets<< t
	end
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
	
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	
	
	
	@ufficio = @dipendente.ufficio
	if @ufficio.parent == nil
	  @dipartimento = @ufficio
	else
	  @dipartimento = @ufficio.parent
	end
	
	respond_to do |format|
	   format.js   {render :action => "scheda_valutazione_obiettivi_dipendente" }
    end
	
  end
  
  def conferma_misurazione_dirigente_x_dipendente
    puts "CONFERMA_MISURAZIONE_DIRIGENTE_X_DIPENDENTE"
	puts params
	
    @dirigente =  nil
	@dipendente = nil
	@dipendenti = []
	@targets = []
	
	@dirigenti = Person.dirigenti
	
	destinazione = params[:target_dipendente_evaluation][:from]
	@dirigente = Person.find(params[:target_dipendente_evaluation][:dirigente_id])
	@dipendenti = @dirigente.dipendenti_sotto
	@dipendente = Person.find(params[:target_dipendente_evaluation][:person_id])
	registra("conferma_misurazione_dirigente_x_dipendente" + " dirigente_id: " + @dirigente.id.to_s + "  dipendente_id: " + @dipendente.id.to_s + "-" + @dipendente.nominativo)
	
	@risultati = []
	
    @dirigente.dirige.each do |s|
      item = Hash.new
      item[:ufficio] = s
      item[:dipendenti] = s.dipendenti_ufficio
      @risultati << item
      s.children.each do |o|
         item = Hash.new
         item[:ufficio] = o
         item[:dipendenti] = o.dipendenti_ufficio
         @risultati << item
         o.children.each do |oo|
	       item = Hash.new
           item[:ufficio] = oo
           item[:dipendenti] = oo.dipendenti_ufficio
           @risultati << item
	     end
      end
    end
	
	lista1 = @dipendente.obiettivi
	lista2 = @dipendente.fasi
	lista3 = @dipendente.azioni
	lista4 = @dipendente.obiettivi_altro_responsabile
	
	lista5 = @dipendente.obiettivi_responsabile
	lista6 = @dipendente.fasi_responsabile
	lista7 = @dipendente.azioni_responsabile
	
	lista8 = @dipendente.opere_assegnate
	lista9 = @dipendente.opere
	
	lista1.each do |t|
	  @targets<< t
	end
	
	lista2.each do |t|
	  @targets<< t
	end
	
	lista3.each do |t|
	  @targets<< t
	end
	
	lista4.each do |t|
	  @targets<< t
	end
	
	lista5.each do |t|
	  @targets<< t
	end
	
	lista6.each do |t|
	  @targets<< t
	end
	
	lista7.each do |t|
	  @targets<< t
	end
	
	lista8.each do |t|
	  @targets<< t
	end
	
	lista9.each do |t|
	  @targets<< t
	end
	
	@targets.each do |target|
	  target_type = target.tipo
	  # case target_type 
       # when "Obiettivo"    #compare to 1
        # target = OperationalGoal.find(target_id) 
       # when "Fase"    #compare to 2
        # target = Phase.find(target_id) 
	   # when "Azione"
	    # target = SimpleAction.find(target_id)
	   # when "Opera"
	    # target = Opera.find(target_id)
       # else
        # puts "it was something else"
      # end
	  puts "target_id: " + target.id.to_s
	  puts "target_type: " + target_type
	  val = TargetDipendenteEvaluation.where(target: target, dipendente: @dipendente).first
	  if val == nil && target != nil && @dipendente != nil
	    puts "Creo nuova valutazione target dipendente"
	    val = TargetDipendenteEvaluation.new
	       val.dipendente = @dipendente
	       val.target = target
		   val.dirigente = @dirigente
		   val.valore = target.valore_totale
	       val.save
	  else
	    val.valore = target.valore_totale
		val.save
	  end
	end
    
	@ufficio = @dipendente.ufficio
	if @ufficio.parent == nil
	  @dipartimento = @ufficio
	else
	  @dipartimento = @ufficio.parent
	end
	@servizio = @dirigente.dirige.first.office_type.denominazione.eql?("Servizio") ? @dirigente.dirige.first.nome : " - "
	
	if destinazione == "targetdipendentixdirigente"
	 respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" }
     end
	elsif destinazione == "modifica_valutazioni_target_dipendente"
	 respond_to do |format|
	 format.js   {render :action => "modifica_valutazioni_target_dipendente" }
	 end
	else 
	 respond_to do |format|
	    format.js   {render :action => "scheda_valutazione_obiettivi_dipendente" }
     end
	end
	
  end
  
  def view_importa_riassuntivo_pagelle_valutazioni
  
  end
  
  def importa_riassuntivo_pagelle_valutazioni
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    result = Person.importa_riassuntivo_pagelle_valutazioni(params[:file]) #pure viene lanciato il metodo del model
	@valutazioni = result
	
  end
  
  def view_setta_assegnazione_ufficio
  
  end
  
  def setta_assegnazione_ufficio
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    result = Person.setta_assegnazione_ufficio(params[:file]) #pure viene lanciato il metodo del model
	@valutazioni = result
	
  end
  
  def view_calcolo_produttivita2020
  
  end  
  
  def calcolo_produttivita2020
  
     registra("calcolo_produttivita2020")
	 puts "calcolo_produttivita2020"
     aggiorna_raggiungimento_obiettivi = params[:aggiorna_raggiungimento_obiettivi]
	 aggiorna_valutazione = params[:aggiorna_valutazione]
	 aggiorna_aggiorna_quota_categoria = params[:aggiorna_quota_categoria]
  
     if (Person.where(flag_calcolo_produttivita: true).where('valutazione = ?', nil).length > 0) || (Person.where(flag_calcolo_produttivita: true).where('raggiungimento_obiettivi = ?', nil).length > 0)
	  return render "error_valutazione_raggiungimento_obiettivi.html.erb"
	 end
	 
	 tutti = Person.where(flag_calcolo_produttivita: true)
	 
     # per ciascun dipendente calcolo la quota area obiettivi
     # per quelli con piu di 60 gg di assenza calcolo la quota che va in economia (che verrà suddivisa fra gli altri)	 
	 tutti.each {|e|
	   categoria = e.categoria
	   if !Setting.disabilita_pagelle_singole
	    if aggiorna_raggiungimento_obiettivi
	      e.raggiungimento_obiettivi = e.valutazione_dirigente_obiettivi_fasi_azioni
		  e.save
	    end
	    if aggiorna_valutazione
	      e.valutazione = e.punteggiofinale
		  e.save
	    end
	   end
	   raggiungimento_obiettivi = e.raggiungimento_obiettivi != nil ? e.raggiungimento_obiettivi : 0
	   
	   tempo = e.tempo != nil ? e.tempo : 0
	   servizio_percentuale = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	   if e.totassenze != nil && e.totgg != nil
	   	   presenza_netto_assenze =  1.0 - (e.totassenze)/((e.totgg != 0) ? e.totgg : 1)
	   else
	       presenza_netto_assenze = 0
	   end
	   # 2020 non c'è più una vera e propria quota obiettivi
	   totassenze = (e.totassenze != nil ? e.totassenze : 0)
	   # 2020 la quota economia si calcola sull'intero premio
	   if (CategoriaQuotum.where(chiave: e.categoria).first != nil) && (CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi != nil) && (CategoriaQuotum.where(chiave: e.categoria).first.quota_comportamento != nil)
	       quota_totale = CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi + CategoriaQuotum.where(chiave: e.categoria).first.quota_comportamento
	   else 
		   quota_totale = 0
	   end
	   
	    # la detrazione è una percentuale di quello spettante per la categoria e il serzizio_percentuale e il tempo
		tempo = e.tempo != nil ? e.tempo : 0
	    serv_perc = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	    
		#calcolo il terico per quella categoria, quel servizio e quel tempo e quella valutazione globale
		# 
		quota_obiettivi = CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi*serv_perc*tempo*e.premialita_effettiva
		quota_comportamento = CategoriaQuotum.where(chiave: e.categoria).first.quota_comportamento*serv_perc*tempo*e.premialita_effettiva
		quota_totale = (quota_obiettivi + quota_comportamento)
		
		# a questo teorico si applica una eventuale riduzione per le assenze
		# potrei applicare la riduzione al teorico prima della valutazione
		# scelta più favorevole al dipendente
		if e.flag_assenze_incidono 
		 
		 # qua ci sono due strade
		 # in economia per spartire agli altri va tutto quello che viene tolto all'assente
		 # in economia per spartire agli altri va solo la quota di riduzione relativa agli obiettivi
		 # scelgo la più favorevole ai dipendenti
		 # NO MAURO DICE SOLO COMPORTAMENTO
         e.quota_economia_area_obiettivi_dipendente = quota_obiettivi * e.percentuale_riduzione_per_assenze
		 # e.quota_economia_area_obiettivi_dipendente = quota_totale * e.percentuale_riduzione_per_assenze
		 quota_totale = quota_totale - quota_totale * e.percentuale_riduzione_per_assenze
		
		 e.save
		else 
		 e.quota_economia_area_obiettivi_dipendente = 0.0
		 e.save
		end
	    e.totale_premio_obiettivi = quota_obiettivi
	    e.totale_premio_valutazione = quota_comportamento
		e.totale_premio_produttivita = quota_totale.ceil
		e.save
	   
     }
	 
	 # ora faccio le somme delle economie e dei servizi percentuali per ogni assegnazione
	 quota_economia_x_assegnazione = Person.where(flag_calcolo_produttivita: true).group(:assegnazione).sum(:quota_economia_area_obiettivi_dipendente)
	 # per accedere
	 # quota_economia_x_assegnazione['G010']
	 
	 listaAss =  Person.where(flag_calcolo_produttivita: true).group(:assegnazione).count
	 percentualeServizioAssegnazione = []
	 listaAss.each { |v|
	   codiceassegnazione = v[0]
	   
	   lista = Person.where(flag_calcolo_produttivita: true).where('assegnazione LIKE ? ', codiceassegnazione)
	   totale = 0.0
	   lista.each {|e|
	    #faccio la somma solo su quelli che non hanno le assenze che incidono
	    if !e.flag_assenze_incidono
	     tempo = e.tempo != nil ? e.tempo : 0
	     serv_perc = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	     totale = totale + tempo*serv_perc * 1.0
		end
	   }
	   
	   #puts "AAA " + codiceassegnazione.to_s + " : " + totale.to_s
	   if percentualeServizioAssegnazione.select{ |a| a[codiceassegnazione] != nil }.length > 1
	   then 
	     p = percentualeServizioAssegnazione.select{ |a| a[codiceassegnazione] != nil}.first
		 p[codiceassegnazione] = totale
		 
	   else
	     ass = Hash.new
		 ass[codiceassegnazione] = totale
		 percentualeServizioAssegnazione<< ass
	   end
	 }
	 
	 # qua il calcolo finale
	 # il totale viene aggiunto della quota proveniente dalle economie
	 tutti.each {|e|
	   puts "ID: " + e.id.to_s
	   tempo = e.tempo != nil ? e.tempo : 0
	   serv_perc = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	   # la questione assenze conta solo per la distribuzione delle economie
	   # ho già fatto la riduzione se serve
	   if e.totassenze != nil && e.totgg != nil
	   	   presenza_netto_assenze =  1.0 - (e.totassenze)/((e.totgg != 0) ? e.totgg : 1)
	   else
	       presenza_netto_assenze = 0
	   end
	   
	   ser_perc_ass = 1.0
	   if percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.length > 0
	       puts "DENTRO"
		   puts percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.length
	   	   ser_perc_ass = percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.first[e.assegnazione]
	   else 
	       ser_perc_ass = 1.0
	   end
	   if ser_perc_ass == 0.0
	       ser_perc_ass = 1.0
	   end
	   
	   quota_economia_ass = (e.assegnazione != nil ? quota_economia_x_assegnazione[e.assegnazione] : 0)
	      
	   #il lavoro va fatto solo per quelli che non hanno assenze che incidono 
	   # è la parte proporzionale a servizio_percentuale e tempo per la paercentuale di presenza
	   if !e.flag_assenze_incidono
	     totale_premio = e.totale_premio_produttivita + (quota_economia_ass / ser_perc_ass) * serv_perc * tempo * presenza_netto_assenze
		 e.totale_premio_produttivita = totale_premio.ceil
	     e.save()
	   end
	   
	 }
	 
	 @employees = Person.where(flag_calcolo_produttivita: true).order(assegnazione: :asc) 
	 @totale_generale_obiettivi = Person.where(flag_calcolo_produttivita: true).sum(:totale_premio_obiettivi)
	 @totale_generale_valutazione = Person.where(flag_calcolo_produttivita: true).sum(:totale_premio_valutazione)
	 @totale_generale_produttivita = Person.where(flag_calcolo_produttivita: true).sum(:totale_premio_produttivita)
	 @fondo = Setting.where(denominazione: 'fondo').first.value.to_f
	 @economia = @fondo - @totale_generale_produttivita
     	 
  end
  
  def view_calcolo_produttivita2019
  
  end
  
  def calcolo_produttivita2019
  
     aggiorna_raggiungimento_obiettivi = params[:aggiorna_raggiungimento_obiettivi]
  
     if (Person.where(flag_calcolo_produttivita: true).where('valutazione = ?', nil).length > 0) || (Person.where(flag_calcolo_produttivita: true).where('raggiungimento_obiettivi = ?', nil).length > 0)
	  return render "error_valutazione_raggiungimento_obiettivi.html.erb"
	 end
	 
	 tutti = Person.where(flag_calcolo_produttivita: true)
	 
     # per ciascun dipendente calcolo la quota area obiettivi
     # per quelli con piu di 60 gg di assenza calcolo la quota che va in economia (che verrà suddivisa fra gli altri)	 
	 tutti.each {|e|
	   categoria = e.categoria
	   if aggiorna_raggiungimento_obiettivi
	     e.raggiungimento_obiettivi = e.valutazione_dirigente_obiettivi_fasi_azioni
	   end
	   raggiungimento_obiettivi = e.raggiungimento_obiettivi != nil ? e.raggiungimento_obiettivi : 0
	   
	   tempo = e.tempo != nil ? e.tempo : 0
	   servizio_percentuale = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	   if e.totassenze != nil && e.totgg != nil
	   	   presenza_netto_assenze =  1.0 - (e.totassenze)/((e.totgg != 0) ? e.totgg : 1)
	   else
	       presenza_netto_assenze = 0
	   end
	   if (CategoriaQuotum.where(chiave: e.categoria).first != nil) && (CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi != nil)
	    quota_obiettivi = CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi
	   else 
	    quota_obiettivi = 0
	   end 
	   #e.area_obiettivi_dipendente = quota_obiettivi * presenza_netto_assenze * raggiungimento_obiettivi * tempo * serv_perc
	   #e.area_obiettivi_dipendente = quota_obiettivi * (raggiungimento_obiettivi / 100) * tempo * serv_perc
	   totassenze = (e.totassenze != nil ? e.totassenze : 0)
	   if totassenze >= 60
	   # variante 2020
	   # if e.flag_assenze_incidono 
	    # controllare se deve incidere solo per la quota obiettivi
	    e.quota_economia_area_obiettivi_dipendente = quota_obiettivi * totassenze/e.totgg
        #e.area_obiettivi_dipendente = e.area_obiettivi_dipendente * presenza_netto_assenze		
	   else
	    e.quota_economia_area_obiettivi_dipendente = 0
	   end 
	   e.save
	 }
	 
	 quota_economia_x_assegnazione = Person.where(flag_calcolo_produttivita: true).group(:assegnazione).sum(:quota_economia_area_obiettivi_dipendente)
	 # per accedere
	 # quota_economia_x_assegnazione['G010']
	 
	 listaAss =  Person.where(flag_calcolo_produttivita: true).group(:assegnazione).count
	 percentualeServizioAssegnazione = []
	 listaAss.each { |v|
	   codiceassegnazione = v[0]
	   
	   lista = Person.where(flag_calcolo_produttivita: true).where('assegnazione LIKE ? AND totassenze  < ?', codiceassegnazione, 60)
	   totale = 0.0
	   lista.each {|e|
	    tempo = e.tempo != nil ? e.tempo : 0
	    serv_perc = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	    totale = totale + tempo*serv_perc * 1.0
	   }
	   
	   #puts "AAA " + codiceassegnazione.to_s + " : " + totale.to_s
	   if percentualeServizioAssegnazione.select{ |a| a[codiceassegnazione] != nil }.length > 1
	   then 
	     p = percentualeServizioAssegnazione.select{ |a| a[codiceassegnazione] != nil}.first
		 p[codiceassegnazione] = totale
		 
	   else
	     ass = Hash.new
		 ass[codiceassegnazione] = totale
		 percentualeServizioAssegnazione<< ass
	   end
	 }
	 
	 tutti.each {|e|
	   puts "ID: " + e.id.to_s
	   if e.totassenze != nil && e.totgg != nil
	   	   presenza_netto_assenze =  1.0 - (e.totassenze)/((e.totgg != 0) ? e.totgg : 1)
	   else
	       presenza_netto_assenze = 0
	   end
	   
	   if percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.length > 0
	       puts "DENTRO"
		   puts percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.length
	   	   ser_perc_ass = percentualeServizioAssegnazione.select{ |a| a[e.assegnazione] != nil }.first[e.assegnazione]
	   else 
	       ser_perc_ass = 1.0
	   end
	   if ser_perc_ass == 0.0
	       ser_perc_ass = 1.0
	   end
	   if (CategoriaQuotum.where(chiave: e.categoria).first != nil) && (CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi != nil)
	    quota_obiettivi = CategoriaQuotum.where(chiave: e.categoria).first.quota_obiettivi
	   else 
	    quota_obiettivi = 0
	   end
	   puts raggiungimento_obiettivi = e.raggiungimento_obiettivi_discretizzato
	   puts quota_economia_ass = e.assegnazione != nil ? quota_economia_x_assegnazione[e.assegnazione] : 0
	   puts serv_perc = e.servizio_percentuale != nil ? e.servizio_percentuale : 0
	   puts tempo = e.tempo != nil ? e.tempo : 0
	   puts "ser_perc_ass " + ser_perc_ass.to_s
	   
	   if e.totassenze != nil && e.totgg != nil
	   	   presenza_netto_assenze =  1.0 - (e.totassenze)/((e.totgg != 0) ? e.totgg : 1)
	   else
	       presenza_netto_assenze = 0
	   end
	   
	   if (e.totassenze != nil ? e.totassenze : 0) < 60
	     totale_obiettivi = (quota_obiettivi * (raggiungimento_obiettivi/100.0) * presenza_netto_assenze * serv_perc * tempo + (quota_economia_ass / ser_perc_ass) * serv_perc * tempo).ceil
	   else
	     totale_obiettivi = (quota_obiettivi * (raggiungimento_obiettivi/100.0) * presenza_netto_assenze * serv_perc * tempo).ceil
	   end	 
		
	   if (CategoriaQuotum.where(chiave: e.categoria).first != nil) && (CategoriaQuotum.where(chiave: e.categoria).first.quota_comportamento != nil)
	    quota_comportamento = (CategoriaQuotum.where(chiave: e.categoria).first.quota_comportamento).ceil
	   else 
	    quota_comportamento = 0
	   end 
	   valutazione = (e.valutazione != nil ? e.valutazione : 0)
	   totale_valutazione = (quota_comportamento *  (valutazione / 100.0) * presenza_netto_assenze * serv_perc * tempo).ceil
	   
	   e.totale_premio_obiettivi = totale_obiettivi
	   e.totale_premio_valutazione = totale_valutazione
	   e.totale_premio_produttivita = totale_obiettivi + totale_valutazione
	   e.save()
	   
	 }
	 
	 @employees = Person.where(flag_calcolo_produttivita: true).order(assegnazione: :asc) 
	 @totale_generale_obiettivi = Person.where(flag_calcolo_produttivita: true).sum(:totale_premio_obiettivi)
	 @totale_generale_valutazione = Person.where(flag_calcolo_produttivita: true).sum(:totale_premio_valutazione)
	 @totale_generale_produttivita = @totale_generale_obiettivi + @totale_generale_valutazione
	 @fondo = Setting.where(denominazione: 'fondo').first.value.to_f
	 @economia = @fondo - @totale_generale_produttivita
     	 
  end
  
  def quotacategorie
      f = Setting.where(denominazione: 'fondo')
	  @ripartizione = {}
	  if f.first != nil
	   @fondo = f.first.value.to_f
	  else
	   @fondo = 0
	  end
      #@categorie = ["A", "B", "C", "D", "PLA", "PLB"]
	  @categorie = []
	  Category.all.each do |c|
	    @categorie |= [c.denominazione]
	  end
	  
	  @numero_per_categoria = Person.where(flag_calcolo_produttivita: true).group('categoria').count
	  @totale_dipendenti = Person.where(flag_calcolo_produttivita: true).count
	  
	  #obiettivi è 0 comportamento 1, obiettivi è il più alto , comportamento è il più basso 
      # così nel 2019
	  #@ripartizione ={"A" => [75,25], "B" => [70,30], "C" => [65,35], "D" => [60,40], "PA" => [65,35], "PB" => [60,40]}
	  # così nel 2020
	  #@ripartizione ={"A" => [40,60], "B" => [45,55], "C" => [50,50], "D" => [55,45], "PLA" => [50,50], "PLB" => [55,45]}
	  # così prendo dalla tabella
	  @ripartizione["A"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("A"), ValuationQualificationPercentage.percentuale_pagella_categoria("A")]
	  @ripartizione["B"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("B"), ValuationQualificationPercentage.percentuale_pagella_categoria("B")]
	  @ripartizione["C"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("C"), ValuationQualificationPercentage.percentuale_pagella_categoria("C")]
	  @ripartizione["D"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("D"), ValuationQualificationPercentage.percentuale_pagella_categoria("D")]
	  @ripartizione["PLA"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("PLA"), ValuationQualificationPercentage.percentuale_pagella_categoria("PLA")]
	  @ripartizione["PLB"] = [ValuationQualificationPercentage.percentuale_obiettivi_categoria("PLB"), ValuationQualificationPercentage.percentuale_pagella_categoria("PLB")]
	  
	  #@peso_categorie = {"A" => 1.0, "B" => 1.10, "C" => 1.20, "D" => 1.30}
	  #@peso_categorie = {"A" => 1.0, "B" => 1.10, "C" => 1.21, "D" => 1.331, "PLA" => 1.21, "PLB" => 1.331}
	  @peso_categorie = FtePercentage.peso_categorie
	  @quote_pesate = {}
	  
	  # questi sono due modi di fare la stessa cosa, se quota è aggiornata
      #@quote = Employee.group('categoria').sum(:quota)
	  
	  @quote = {}
	  @categorie.each {|c| @quote[c] = 0.0 }
      cats = Person.where(flag_calcolo_produttivita: true).select(:categoria).distinct
      cats.each {|c| 
       @quote[c[:categoria]] = 0}
      Person.where(flag_calcolo_produttivita: true).each { |e| @quote[e.categoria] = @quote[e.categoria] + e.servizio_percentuale.to_f*e.tempo.to_f }
	  
	  @quote.each {|key, value| @quote_pesate[key] = value * (@peso_categorie[key] != nil ? @peso_categorie[key] : 0) } 
	  
	  
	  #@totale = Person.sum(:quota)
	  @totale_pesato = 0 
	  @quote_pesate.each {|key, value| @totale_pesato = @totale_pesato + value } 
	  
	  
	  @categorie.each {|key|
	   if CategoriaQuotum.where(chiave: key).length == 0
	   then
	    cq = CategoriaQuotum.new
		cq.chiave = key
	    cq.quota_comportamento = (@fondo / @totale_pesato) * @peso_categorie[key] * ((@ripartizione[key] != nil ? @ripartizione[key][1] : 0)/100.0)
	    cq.quota_obiettivi = (@fondo / @totale_pesato) * @peso_categorie[key] * ((@ripartizione[key] != nil ? @ripartizione[key][0] : 0)/100.0)
		cq.save
		# se faccio con le righe sotto ho il totale per la categoria
		# cq = CategoriaQuotum.new
		# cq.chiave = key
	    # cq.quota_comportamento = (@fondo / @totale_pesato) * @quote_pesate[key] * ((@ripartizione[key] != nil ? @ripartizione[key][1] : 0)/100.0)
	    # cq.quota_obiettivi = (@fondo / @totale_pesato) * @quote_pesate[key] *  ((@ripartizione[key] != nil ? @ripartizione[key][0] : 0)/100.0)
		# cq.save
	   else 
	    cq = CategoriaQuotum.where(chiave: key).first
		cq.quota_comportamento = (@fondo / @totale_pesato) * @peso_categorie[key] * ((@ripartizione[key] != nil ? @ripartizione[key][1] : 0)/100.0)
	    cq.quota_obiettivi = (@fondo / @totale_pesato) * @peso_categorie[key] * ((@ripartizione[key] != nil ? @ripartizione[key][0] : 0)/100.0)
		cq.save
		# se faccio con le righe sotto ho il totale per la categoria
		# cq = CategoriaQuotum.where(chiave: key).first
		# cq.quota_comportamento = (@fondo / @totale_pesato) * @quote_pesate[key] * ((@ripartizione[key] != nil ? @ripartizione[key][1] : 0)/100.0)
	    # cq.quota_obiettivi = (@fondo / @totale_pesato) * @quote_pesate[key] * ((@ripartizione[key] != nil ? @ripartizione[key][0] : 0)/100.0)
		# cq.save
	   end
	  }
	  
	  
	  
  end
  
  def flagproduttivita
    @people = Person.all.order( assegnazione: :asc )
  
  end
  
  def setflagproduttivita
    puts "SETFLAGPRODUTTIVITA"
    puts params
	id = params[:content]
	@p = Person.find(id)
	#if p != nil
	  @p.flag_calcolo_produttivita = ! @p.flag_calcolo_produttivita
	  @p.save
	  registra("setflagproduttivita " + @p.nominativo + " " +  @p.flag_calcolo_produttivita.to_s)
	#end
	#@people = Person.all
    puts @p.matricola
	#render :flagproduttivita
     respond_to do |format|
	    #format.js   {render :action => "flagproduttivita" }
		format.js   {render :action => "flagproduttivita_single" }
     end
  end
  
  def view_servizio_tempo
    @people = Person.all.order( assegnazione: :desc )
  end
  
  def set_servizio_tempo
    puts "SET_SERVIZIO_TEMPO"
    puts params
	id = params[:person][:person_id]
	servizio_percentuale = params[:person][:value_servizio_percentuale]
	tempo = params[:person][:value_tempo]
	@p = Person.find(id)
	
	if servizio_percentuale != nil
	 servizio_percentuale = servizio_percentuale.to_f 
	 @p.servizio_percentuale = servizio_percentuale 
	 @p.save
	 registra("set_servizio_tempo servizio_percentuale" + @p.nominativo + " " +  @p.servizio_percentuale.to_s)
	end
	
	if tempo != nil
	 @p.tempo = tempo
	 @p.save
	 registra("set_servizio_tempo tempo" + @p.nominativo + " " +  @p.tempo.to_s)
	end
	
	#end
	#@people = Person.all
    #@people = Person.all.order( assegnazione: :desc )
	#render :flagproduttivita
     respond_to do |format|
	    format.js   {render :action => "view_servizio_tempo" }
     end
  end
  
  def view_assegnazione
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
  end
  
  def view_assenze
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
  end
  
  def set_assegnazione
    puts "SET_ASSEGNAZIONE"
    puts params
	id = params[:person][:person_id]
	assegnazione = params[:person][:assegnazione]
	
	@p = Person.find(id)
	
	if assegnazione != nil
	 
	 @p.assegnazione = assegnazione 
	 @p.save
	 registra("set_assegnazione" + @p.nominativo + " " +  @p.assegnazione.to_s)
	end
	
	
	#end
	#@people = Person.all
    #@people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	#render :flagproduttivita
     respond_to do |format|
	    format.js   {render :action => "view_assegnazione" }
     end
  end
  
  def set_categoria
    puts "SET_CATEGORIA"
    puts params
	id = params[:person][:person_id]
	categoria = params[:person][:categoria]
	cat = categoria
	
	@p = Person.find(id)
	
	c = Category.find(categoria)
	if c != nil
	  cat = c.denominazione
	end
	
	
	if cat.length > 0
	 
	 @p.categoria = cat 
	 @p.save
	 registra("set_categoria" + @p.nominativo + " " +  @p.categoria.to_s)
	end
	
	
    respond_to do |format|
	    format.js   {render :action => "view_assegnazione" }
    end
  
  end
  
  def set_categoria_formale
    puts "SET_CATEGORIA_FORMALE"
    puts params
	id = params[:person][:person_id]
	categoria = params[:person][:categoria_formale]
	cat = categoria
	
	@p = Person.find(id)
	
	c = Category.find(categoria)
	if c != nil
	  cat = c.denominazione
	end
	
	
	if cat.length > 0
	 
	 @p.categoria_formale = cat 
	 @p.save
	 registra("set_categoria_formale " + @p.nominativo + " " +  @p.categoria_formale.to_s)
	end
	
	
    respond_to do |format|
	    format.js   {render :action => "view_assegnazione" }
    end
  
  end
  
  
  def set_qualifica
    puts "SET_QUALIFICA"
    puts params
	id = params[:person][:person_id]
	qid = params[:person][:qualification_type_id]
	
	@p = Person.find(id)
	@q = QualificationType.find(qid)
	@p.qualification = @q
	@p.save
	registra("set_qualifica" + @p.nominativo + " " +  @p.qualification.to_s)
	
	respond_to do |format|
	    format.js   {render :action => "view_assegnazione" }
    end
  
  end 
  
  def set_qualifica_people_x_index
    puts "SET_QUALIFICA"
    puts params
	id = params[:person][:person_id]
	qid = params[:person][:qualification_type_id]
	
	@p = Person.find(id)
	@q = QualificationType.find(qid)
	@p.qualification = @q
	@p.save
	
	respond_to do |format|
	    format.js   {render :action => "set_qualifica_people_x_index" }
    end
  
  end 
  
  def set_assenze
    puts "SET_ASSEGNAZIONE"
    puts params
	id = params[:person][:person_id]
	totgg = params[:person][:totgg]
	totassenze = params[:person][:totassenze]
	
	@p = Person.find(id)
	
	if totgg != nil
	 
	 @p.totgg = totgg 
	 @p.save
	 registra("set_assenze totgg" + @p.nominativo + " " +  @p.totgg.to_s)
	end
	
	if totassenze != nil
	 
	 @p.totassenze = totassenze 
	 @p.save
	 registra("set_assenze totassenze" + @p.nominativo + " " +  @p.totassenze.to_s)
	end
	
	
	#end
	#@people = Person.all
    #@people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	#render :flagproduttivita
     respond_to do |format|
	    format.js   {render :action => "view_assenze" }
     end
  end
  
  def tabellone_valutazioni_obiettivi
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
  
  end
  
  def set_finale_valutazione
    puts "set_finale_valutazione"
	puts params
	valore = params[:person][:value]
	person = Person.find(params[:person][:person_id])
	person.valutazione = valore
	person.save
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	 respond_to do |format|
	    format.js   {render :action => "tabellone_valutazioni_obiettivi" }
     end
  end
  
  def set_finale_raggiungimento_obiettivi
    puts "set_finale_raggiungimento_obiettivi"
	puts params
	valore = params[:person][:value]
	person = Person.find(params[:person][:person_id])
	person.raggiungimento_obiettivi = valore
	person.save
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	 respond_to do |format|
	    format.js   {render :action => "tabellone_valutazioni_obiettivi" }
     end
  end
  
  def importazione_raggiungimento_obiettivi
  
  end
  
  def importa_raggiungimento_obiettivi
    filename = params[:file].original_filename
	colonna_valore = params[:value]
	puts "FILENAME " + filename
    risultato = Person.importa_raggiungimento_obiettivi(params[:file],colonna_valore) #pure viene lanciato il metodo del model
	@result = risultato[0]
	@scartate = risultato[1]
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_dati_generali
  
  end
  
  def importa_dati_generali
    puts params
    @modificate = []
	opzioni = {}  # un dictionary o hash
    filename = params[:file].original_filename
	opzioni["colonna_matricola"] = params[:colonna_matricola]
	opzioni["colonna_categoria"] = params[:colonna_categoria]
	opzioni["colonna_ruolo"] = params[:colonna_ruolo]
	opzioni["colonna_servizio_percentuale"] = params[:colonna_servizio_percentuale]
	opzioni["colonna_figura_giuridica"] = params[:colonna_figura_giuridica]
	
	puts "FILENAME " + filename
    risultato = Person.importa_dati_generali(params[:file], opzioni) #pure viene lanciato il metodo del model
	@modificate = risultato[0]
	@scartate = risultato[1]
  
  end
  
  
  def importazione_assenze
  
  end
  
  def importa_assenze
    filename = params[:file].original_filename
	somma_righe = params[:somma_righe]
	puts "FILENAME " + filename
    @result = Person.importa_assenze(params[:file], somma_righe) #pure viene lanciato il metodo del model
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_categorie
  
  end
  
  def importa_categorie
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    @result = Person.importa_categorie(params[:file]) #pure viene lanciato il metodo del model
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_servizio_percentuale
  
  end
  
  def importa_servizio_percentuale
    filename = params[:file].original_filename
	puts "FILENAME " + filename
    risultato = Person.importa_servizio_percentuale(params[:file]) #pure viene lanciato il metodo del model
	@result = risultato[0]
	scaricate = risultato[1]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_2020
  
  end
  
  def importa_2020
    filename = params[:file].original_filename
	sposta_persona = params[:sposta_persona]
	crea_ufficio = params[:crea_ufficio]
	solo_prova = params[:solo_prova]
	puts "FILENAME " + filename
    risultato = Person.importa_2020(params[:file], sposta_persona, crea_ufficio, solo_prova ) #pure viene lanciato il metodo del model
	@result = risultato[0]
	@scartate = risultato[1]
	@aggiunte = risultato[2]
	@diverse = risultato[3]
	@nuovi_uffici = risultato[4]
	@spostati_di_ufficio = risultato[5]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_check_uffici
  
  end
  
  def importa_check_uffici
    filename = params[:file].original_filename
	sposta_persona = params[:sposta_persona]
	crea_ufficio = params[:crea_ufficio]
	solo_prova = params[:solo_prova]
	puts "FILENAME " + filename
    risultato = Person.importa_check_uffici(params[:file], sposta_persona, crea_ufficio, solo_prova ) #pure viene lanciato il metodo del model
	@result = risultato[0]
	@scartate = risultato[1]
	@aggiunte = risultato[2]
	@diverse = risultato[3]
	@nuovi_uffici = risultato[4]
	@spostati_di_ufficio = risultato[5]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def importazione_servizio_tempo
  
  end
  
  def importa_servizio_tempo
    registra("importa_servizio_tempo")
    filename = params[:file].original_filename
	aggiungi_mancanti = params[:aggiungi_mancanti]
	correggi_matricole = params[:correggi_matricole]
	puts "FILENAME " + filename
    risultato = Person.importa_servizio_tempo(params[:file], aggiungi_mancanti, correggi_matricole) #pure viene lanciato il metodo del model
	@result = risultato[0]
	@scartate = risultato[1]
	
	# qua va automaticamente alla vista importa con la variabile @aggiunta valorizzata
  end
  
  def rimuovi_assegnazione_target
    puts "RIMUOVI_ASSEGNAZIONE_TARGET"
    puts params 
	destinazione = params[:person][:from]
	@dirigente = Person.find(params[:person][:dirigente_id])
	@risultati = []
	@dirigenti = []
    @dirigente.dirige.each do |s|
      item = Hash.new
      item[:ufficio] = s
      item[:dipendenti] = s.dipendenti_ufficio
      @risultati << item
      s.children.each do |o|
         item = Hash.new
         item[:ufficio] = o
         item[:dipendenti] = o.dipendenti_ufficio
         @risultati << item
         o.children.each do |oo|
	       item = Hash.new
           item[:ufficio] = oo
           item[:dipendenti] = oo.dipendenti_ufficio
           @risultati << item
	     end
      end
    end
	
	@dirigenti = Person.dirigenti
	
	if params[:person][:operational_goal_assignment_id] != nil
      ga = GoalAssignment.where(id: params[:person][:operational_goal_assignment_id]).first
	  @dipendente = ga.persona
	  ga.delete
    end
    if params[:person][:phase_assignment_id] != nil
      pa = PhaseAssignment.where(id: params[:person][:phase_assignment_id]).first
	  @dipendente = pa.persona
	  pa.delete
    end
    if params[:person][:simple_action_assignment_id] != nil
      aa = SimpleActionAssignment.where(id: params[:person][:simple_action_assignment_id]).first
	  @dipendente = aa.persona
	  aa.delete
    end
	if params[:person][:opera_assignment_id] != nil
      opa = OperaAssignment.where(id: params[:person][:opera_assignment_id]).first
	  @dipendente = opa.persona
	  opa.delete
    end
	
	if destinazione == "targetdipendentixdirigente"
	 respond_to do |format|
	   format.js   {render :action => "targetdipendentixdirigente" }
	 end
    elsif destinazione == "modifica_valutazioni_target_dipendente"
	 respond_to do |format|
	 format.js   {render :action => "modifica_valutazioni_target_dipendente" }
	 end
    else 
	 respond_to do |format|
	    format.js   {render :action => "pesisearchxdirigente" }
     end
    end
  end
  
  def dipendenti_uffici_dirigente
    @dirigenti = []
 
    @dirigenti = filtro_dirigenti.sort_by{|d| d.cognome}
  end
  
  def set_dipendenti_uffici_dirigente
    puts "SET_DIPENDENTI_UFFICI_DIRIGENTE"
    puts params
    @dirigente = Person.find(params[:person][:dirigente_id])
	operation = params[:person][:operation]
	dipendente_id = params[:person][:person_id]
	ufficio_id = params[:person][:office_id]
	testo = params[:person][:text]
    @risultati = []
    @dirigente.dirige.each do |s|
      item = Hash.new
      item[:ufficio] = s
      item[:dipendenti] = s.dipendenti_ufficio
      @risultati << item
      s.children.each do |o|
        item = Hash.new
        item[:ufficio] = o
        item[:dipendenti] = o.dipendenti_ufficio
        @risultati << item
        o.children.each do |oo|
	      item = Hash.new
          item[:ufficio] = oo
          item[:dipendenti] = oo.dipendenti_ufficio
          @risultati << item
	    end
      end
    end
	
	if operation != nil
	  case operation
	  when "rm"
	    dip = Person.find(dipendente_id)
	    uff = Office.find(ufficio_id)
		if dip != nil && uff != nil
		  dip = Person.find(dipendente_id)
		  dip.ufficio = nil
		  dip.save
		end
		
	  when "add"
	    if dipendente_id != nil
	       dip = Person.find(dipendente_id)
		end
		if testo != nil
	       dip = Person.cerca(testo)
		end
		   
		uff = Office.find(ufficio_id)
		if dip != nil && uff != nil
		  dip.ufficio = uff
		  dip.save
		end
	  else
	    puts "Operazione non riconosciuta " + operation.to_s
	  end
	
	end
    
	respond_to do |format|
	   format.js   { }
    end
  
  end
  
  def assegnaopere
    @dirigente = nil
    @target_array = []
    @assegnatari = []
   
    @testo = ""
    @dirigenti = []
   
    #@dirigenti = Person.dirigenti
    # con il filtro faccio vedere solo quello che deve vedere
    @dirigenti = filtro_dirigenti
  end
  
  def searchassegnaoperexdirigente
  
    puts params
	@dirigente = nil
    @opere_array = []
	@dipendente = nil
	
  
    @dirigente = Person.find(params[:person][:id])
	
    @opere_array = @dirigente.opere_array.sort_by{|o| o.numero}
    #@opere_array<< @dirigente.opere_array.first
  
    respond_to do |format|
	   format.js   {render :action => "assegnaopere" }
    end
  end
  
  def aggiungiassegnazioniopere
    puts "AGGIUNGIASSEGNAZIONIOPERE"
	registra("AGGIUNGIASSEGNAZIONIOPERE")
    puts params
	@dirigente = nil
    @opere_array = []
	@dipendente = nil
	
	
	if params[:valore] != nil
	  @valore = params[:valore]
	else
	 @valore = params[:person][:valore]
	end
	puts @valore.to_s
	
	
	if params[:dirigente] != nil
	 # arrivo da ajax 
	 dirigente_id = params[:dirigente]
	else 
	 dirigente_id = params[:person][:dirigente_id]
	end
	
	if params[:dipendente] != nil
	 # arrivo da ajax 
	 dipendente_id = params[:dipendente]
	else 
	 dipendente_id = params[:person][:person_id]
	end
	
	if params[:opera] != nil
	 # arrivo da ajax 
	 opera_id = params[:opera]
	else 
	 opera_id = nil
	end
	
	@dirigente = Person.find(dirigente_id)
	@dipendente = Person.find(dipendente_id)
	
	@opere_array = @dirigente.opere_array.sort_by{|o| o.numero}
    #@opere_array<< @dirigente.opere_array.first
  
    if opera_id != nil
	 opera = Opera.find(opera_id)
	 assegnazione = OperaAssignment.where(persona: @dipendente, opera: opera).first
	 if assegnazione != nil
	   assegnazione.delete
	 else
	  opera.assegnatari<< @dipendente
	  opera.save
	  assegnazione = OperaAssignment.where(persona: @dipendente, opera: opera).first
	  assegnazione.wheight = @valore
	  assegnazione.save
	  registra("AGGIUNGI ASSEGNAZIONI OPERE " + @dipendente.nominativo + " " + opera.denominazione)
	 end
	end
    respond_to do |format|
	   format.js   {render :action => "assegnaopere" }
    end
  end
  
  # 
  def modifica_valutazioni_target_dipendente
   puts "MODIFICA_VALUTAZIONI_TARGET_DIPENDENTE"
   puts params
   dipendente_id = params[:format]
   puts "id : " + dipendente_id.to_s
   @dipendente = Person.find(dipendente_id)
   @dirigente = @dipendente.dirigente
   registra('modifica_valutazioni_target_dipendente ' + @dipendente.nominativo) 
   render :action => "modifica_valutazioni_target_dipendente" 
   # respond_to do |format|
	   # format.js   {render :action => "modifica_valutazioni_target_dipendente" }
   # end
  end
  
  def action_modifica_valutazioni_target_dipendente
    
   respond_to do |format|
	   format.js   {render :action => "modifica_valutazioni_target_dipendente" }
   end
  end
  
  def set_flag_assenze_incidono
    puts params
	dipendente_id = params[:person][:person_id]
    @dipendente = Person.find(dipendente_id)
	
	@dipendente.flag_assenze_incidono = ! @dipendente.flag_assenze_incidono
	@dipendente.save
	registra('set_flag_assenze_incidono ' + @dipendente.nominativo + " flag_assenze_incidono:" + @dipendente.flag_assenze_incidono.to_s) 
  end
  
  def chiusura_valutazione
    puts params
	dipendente_id = params[:person][:person_id]
    @dipendente = Person.find(dipendente_id)
	
    @dirigente = Person.find(params[:person][:dirigente_id])
	registra('chiusura_valutazione ' + @dipendente.nominativo)
	@dipendente.flag_valutazione_chiusa = true
	@dipendente.data_chiusura_valutazione = DateTime.now
	@dipendente.save
	
	@person = @dipendente
	@valutazioni = @person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
	
	#respond_to do |format|
	#   format.js   {render :action => "setvalueall" }
    #end
	render 'people/valutazionedipendente_notextarea'
	
  end
  
  def chiudi_tutte_valutazioni
    puts params
	@dirigente = Person.find(params[:person][:dirigente_id])
	registra('chiudi_tutte_valutazioni ' + @dirigente.nominativo)
	@risultati = []
    @dirigente.dirige.each do |s|
      item = Hash.new
      item[:ufficio] = s
      item[:dipendenti] = s.dipendenti_ufficio
	  item[:dipendenti].each do |dip|
	    dip.flag_valutazione_chiusa = true
	    dip.data_chiusura_valutazione = DateTime.now
	    dip.save
	  end
      @risultati << item
      s.children.each do |o|
        item = Hash.new
        item[:ufficio] = o
        item[:dipendenti] = o.dipendenti_ufficio
		item[:dipendenti].each do |dip|
	      dip.flag_valutazione_chiusa = true
	      dip.data_chiusura_valutazione = DateTime.now
	      dip.save
	    end
        @risultati << item
        o.children.each do |oo|
	     item = Hash.new
         item[:ufficio] = oo
         item[:dipendenti] = oo.dipendenti_ufficio
		 item[:dipendenti].each do |dip|
	       dip.flag_valutazione_chiusa = true
	       dip.data_chiusura_valutazione = DateTime.now
	       dip.save
	     end
         @risultati << item
	     oo.children.each do |ooo|
	      item = Hash.new
          item[:ufficio] = ooo
          item[:dipendenti] = ooo.dipendenti_ufficio
		  item[:dipendenti].each do |dip|
	       dip.flag_valutazione_chiusa = true
	       dip.data_chiusura_valutazione = DateTime.now
	       dip.save
	      end
          @risultati << item
	     end
	    end
       end
    end
  
  # nel caso del segretario vanno aggiunti tutti i dirigenti
  if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	dirigenti.each do |d|
	 if d.dirige.length > 0
	  item = Hash.new
      item[:ufficio] = d.dirige.first  #questo potrebbe essere vuoto 
      item[:dipendenti] = d
	  d.flag_valutazione_chiusa = true
	  d.data_chiusura_valutazione = DateTime.now
	  d.save
	  
      @risultati << item
	 end
	end
  end
	
	respond_to do |format|
	   format.js   {render :action => 'showtabellaxdirigente' }
    end
	
  end
  
  def apri_tutte_valutazioni
    puts params
	@dirigente = Person.find(params[:person][:dirigente_id])
	registra('apri_tutte_valutazioni ' + @dirigente.nominativo)
	@risultati = []
    @dirigente.dirige.each do |s|
      item = Hash.new
      item[:ufficio] = s
      item[:dipendenti] = s.dipendenti_ufficio
	  item[:dipendenti].each do |dip|
	    dip.flag_valutazione_chiusa = false
	    dip.data_chiusura_valutazione = DateTime.now
	    dip.save
	  end
      @risultati << item
      s.children.each do |o|
        item = Hash.new
        item[:ufficio] = o
        item[:dipendenti] = o.dipendenti_ufficio
		item[:dipendenti].each do |dip|
	      dip.flag_valutazione_chiusa = false
	      #dip.data_chiusura_valutazione = DateTime.now
	      dip.save
	    end
        @risultati << item
        o.children.each do |oo|
	     item = Hash.new
         item[:ufficio] = oo
         item[:dipendenti] = oo.dipendenti_ufficio
		 item[:dipendenti].each do |dip|
	       dip.flag_valutazione_chiusa = false
	       dip.data_chiusura_valutazione = DateTime.now
	       dip.save
	     end
         @risultati << item
	     oo.children.each do |ooo|
	      item = Hash.new
          item[:ufficio] = ooo
          item[:dipendenti] = ooo.dipendenti_ufficio
		  item[:dipendenti].each do |dip|
	       dip.flag_valutazione_chiusa = false
	       dip.data_chiusura_valutazione = DateTime.now
	       dip.save
	      end
          @risultati << item
	     end
	    end
       end
    end
  
  # nel caso del segretario vanno aggiunti tutti i dirigenti
  if @dirigente.qualification == QualificationType.where(denominazione: "Segretario").first
    dirigenti = QualificationType.where(denominazione: "Dirigente").first.people
	dirigenti.each do |d|
	 if d.dirige.length > 0
	  item = Hash.new
      item[:ufficio] = d.dirige.first  #questo potrebbe essere vuoto 
      item[:dipendenti] = d
	  d.flag_valutazione_chiusa = false
	  d.data_chiusura_valutazione = DateTime.now
	  d.save
	  
      @risultati << item
	 end
	end
  end
	
	respond_to do |format|
	   format.js   {render :action => 'showtabellaxdirigente' }
    end
	
  end
  
  def set_flag_valutazione_chiusa
    puts params
	id = params[:content]
	@p = Person.find(id)
	@p.flag_valutazione_chiusa = ! @p.flag_valutazione_chiusa
	@p.save
	respond_to do |format|
	    #format.js   {render :action => "flagproduttivita" }
		format.js   {render :action => "flag_valutazione_chiusa_single" }
    end
  end
  
  def flag_valutazione_chiusa
    @people = Person.all.order( cognome: :asc )
  
  end
  
  def valutazionedipendente_indicazioni_considerazioni
  
    @from = params[:person][:from]
    dipendente_id =  params[:person][:person_id]
	dirigente_id =  params[:person][:dirigente_id]
	@dipendente = Person.find(dipendente_id)
	@dirigente = Person.find(params[:person][:dirigente_id])
	@person = @dipendente
  
  end
  
  def valutazionedipendenteobiettivi_indicazioni_considerazioni
  
    @from = params[:person][:from]
    dipendente_id =  params[:person][:person_id]
	dirigente_id =  params[:person][:dirigente_id]
	@dipendente = Person.find(dipendente_id)
	@dirigente = Person.find(params[:person][:dirigente_id])
	@person = @dipendente
  
  end
  
  def salva_indicazioni
    puts params
	from = ""
	from = params[:person][:from]
	indicazioni_miglioramento_prestazione = params[:person][:indicazioni_miglioramento_prestazione]
	considerazioni_del_valutato = params[:person][:considerazioni_del_valutato]
	dipendente_id =  params[:person][:person_id]
	dirigente_id_id =  params[:person][:dirigente_id]
	
	@dipendente = Person.find(dipendente_id)
	@dirigente = Person.find(params[:person][:dirigente_id])
	registra('salva_indicazioni ' + @dipendente.nominativo)
	
	@dipendente.indicazioni_miglioramento_prestazione = indicazioni_miglioramento_prestazione
	@dipendente.considerazioni_del_valutato = considerazioni_del_valutato
	@dipendente.save
	
	@person = @dipendente
	@valutazioni = @person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
	
	if from == "scheda_valutazione_obiettivi_dipendente"
       #render :action => "window_closer"
       render 'people/window_closer'	   
	else 
	# respond_to do |format|
	   # format.html   {render :action => "valutazionedipendente_notextarea" }
    # end
	  render 'people/valutazionedipendente_notextarea'
	end
	
  end
  
  def sposta_persona
    person_id = params[:person][:person_id]
	office_id = params[:person][:office_id]
	p = Person.find(person_id)
	o = Office.find(office_id)
	puts "SPOSTO " + p.cognome + " in " + o.nome
	p.ufficio = o
	p.save
  end
  
  def ricalcola_tutti_finale_valutazione
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	@people.each do |p|
	  p.valutazione = p.punteggiofinale
	  p.save
	end
	 respond_to do |format|
	    format.js   {render :action => "tabellone_valutazioni_obiettivi" }
     end
  end
  
  def ricalcola_tutti_finale_obiettivi
    @people = Person.where(flag_calcolo_produttivita: true).order( assegnazione: :desc )
	@people.each do |p|
	  p.raggiungimento_obiettivi = p.valutazione_dirigente_obiettivi_fasi_azioni
	  p.save
	end
	 respond_to do |format|
	    format.js   {render :action => "tabellone_valutazioni_obiettivi" }
     end
  
  end
  
  def importa_pagelle_obiettivi
    filename = params[:file].original_filename
	
	puts "FILENAME " + filename
     
	res = Person.importa_pagelle_obiettivi(params[:file]) # viene lanciato il metodo del model
	@Importati = res[0]
	@Errori = res[1]
	
  end
  
  def importazione_pagelle_obiettivi
  
  end
  
  def importazione_analitico
  
  end
  
  def importa_analitico
    puts params
    @modificate = []
	@scartate = []
	opzioni = {}  # un dictionary o hash
    filename = params[:file].original_filename
	opzioni["aggiungi_mancanti"] = params[:aggiungi_mancanti]
	opzioni["correeggi_matricole"] = params[:correggi_matricole]
		
	puts "FILENAME " + filename
    risultato = Person.importa_analitico(params[:file], opzioni) #pure viene lanciato il metodo del model
	@modificate = risultato[0]
	@scartate = risultato[1]
	@aggiunte = risultato[2]
  
  end
  
  def vedi_sessioni
  
     @people = Person.all.order("cognome asc")
	 
  end
  
  def vedi_sessioni_show
  
	puts params
	id = params[:person][:id]
	person = Person.find(id)
	operatore = ""
	
	if person != nil
		operatore = person.email
	end 
  
	@sessioni = []

	lista = Operation.where(operatore: operatore).order(tempo: :asc)
	@sessione = Hash.new
	ultima_operazione = nil
	lista.each do |op|
		if op.descrizione.starts_with?("LOGIN")
			if (@sessione["inizio"] != nil) && (ultima_operazione != nil)
				@sessione["fine"] = ultima_operazione.tempo
				@sessione["operatore"] = operatore
				@sessioni<< @sessione
				@sessione = Hash.new
				@sessione["inizio"] = op.tempo
			elsif @sessione["inizio"] == nil
				@sessione["inizio"] = op.tempo
			end
		else
			ultima_operazione = op
		end
	end
	if (@sessione["inizio"] != nil) && (ultima_operazione != nil)
     @sessione["fine"] = ultima_operazione.tempo
	 @sessione["operatore"] = operatore
	 @sessioni<< @sessione
	end
  
  end
  
  def riassuntivo_assegnazioni
    puts "PARMS" 
	puts params
	
    @dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra("riassuntivo_assegnazioni " + @dirigente.nominativo )
	filename = "RiassuntivoAssegnazioni_" + @dirigente.cognome + "_" + @dirigente.nome
    nomefileout = filename + ".xlsx"
    exfile = WriteXLSX.new(nomefileout)
	
	format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 9})
	format1.set_text_wrap() 
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 9})
  #format1red.set_font_color('red')
  
      format12 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 12})
	format1.set_text_wrap() 
	
    

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1center.set_text_wrap() ;
	
	format1centerGreen = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'lime',
	'font': 'Franklin Gothic Book',
	'size': 10})
    format1centerGreen.set_text_wrap() ;
	
	
	format12center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	
	'size': 12})
    format1center.set_text_wrap() ;
	
	format12centerMagenta = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'fg_color': 'magenta',
	'size': 12})
    format1center.set_text_wrap() ;
	
	format12centerCyan = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'fg_color': 'cyan',
	'size': 12})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'green',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 11})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 10})
	
	@risultati = []
    @dirigente.dirige.each do |s|
    item = Hash.new
    item[:ufficio] = s
    item[:dipendenti] = s.dipendenti_ufficio
    @risultati << item
    s.children.each do |o|
      item = Hash.new
      item[:ufficio] = o
      item[:dipendenti] = o.dipendenti_ufficio
      @risultati << item
      o.children.each do |oo|
	   item = Hash.new
       item[:ufficio] = oo
       item[:dipendenti] = oo.dipendenti_ufficio
       @risultati << item
	   oo.children.each do |ooo|
	    item = Hash.new
        item[:ufficio] = ooo
        item[:dipendenti] = ooo.dipendenti_ufficio
        @risultati << item
	   end
	  end
    end
    end
	
	
	index = 0
	@risultati.each do |r|
	   index = index + 1
       nome_ufficio = index.to_s + "-" + r[:ufficio].nome.gsub(/[^0-9A-Za-z ]/,"").strip.first(27)  #nome_ufficio 
	   worksheet_ufficio = exfile.add_worksheet(sheetname = nome_ufficio)
	   
	   worksheet_ufficio.set_landscape
	   worksheet_ufficio.fit_to_pages(1, 0)
	   
	   worksheet_ufficio.set_column('A:A', 10)
	   worksheet_ufficio.set_column('B:B', 50)
	   worksheet_ufficio.set_column('C:C', 30)
	   worksheet_ufficio.set_column('D:D', 10)
	   worksheet_ufficio.set_column('E:E', 30)
	   worksheet_ufficio.set_column('F:F', 30)
	   worksheet_ufficio.set_column('G:G', 30)
	   worksheet_ufficio.set_column('H:H', 30)
	   worksheet_ufficio.set_column('I:I', 30)
	   worksheet_ufficio.set_column('J:J', 30)
	   worksheet_ufficio.set_column('K:K', 30)
	   worksheet_ufficio.set_column('L:L', 30)
	   worksheet_ufficio.set_column('M:M', 30)
	   
	   row = 1
	   
	   worksheet_ufficio.merge_range('A1:D1', 'SCHEDA ASSEGNAZIONE OBIETTIVI ', format12center)
	   
	   worksheet_ufficio.write(row-1, 4, 'ANNO', format12)
	   worksheet_ufficio.write(row-1, 5, (Setting.where(denominazione: 'anno').length >0 ?  Setting.where(denominazione: 'anno').first.value : " - "), format12center)
	   
       row = row + 2 
	   
	   worksheet_ufficio.write(row-1, 0, " SERVIZIO ", format12center)
	   worksheet_ufficio.merge_range("B" + row.to_s + ":F" + row.to_s, r[:ufficio].ufficio_apicale.nome.to_s , format12centerMagenta)
	   
	   row = row + 1
	   worksheet_ufficio.write(row-1, 0, " Struttura (U.ORG, U.O, U.S) ", format12center)
	   worksheet_ufficio.merge_range("B" + row.to_s + ":F" + row.to_s, r[:ufficio].nome.to_s , format12centerCyan)
	   
	   row = row + 2
	   worksheet_ufficio.write(row, 0, " CODICE ", format1center)
	   worksheet_ufficio.write(row, 1, " OBIETTIVO ", format1center)
       worksheet_ufficio.write(row, 2, " DIPENDENTI ", format1center)
       worksheet_ufficio.write(row, 3, " PESO", format1center)
       worksheet_ufficio.write(row, 4, " INDICATORE", format1center)
       worksheet_ufficio.write(row, 5, " TARGET ", format1center)
	   
	   row = row + 2
	   
	   lista_dipendenti = r[:dipendenti]
	   lista_dipendenti.each do |p|
	     row = row + 1
	    
		 worksheet_ufficio.write(row, 0, p.matricola, format1)
		 worksheet_ufficio.write(row, 1, "", format1)
		 worksheet_ufficio.write(row, 2, p.nominativo, format1centerGreen)
		 worksheet_ufficio.write(row, 3, "", format1)
		 worksheet_ufficio.write(row, 4, "", format1)
		 worksheet_ufficio.write(row, 5, "", format1)
		 row = row + 1
		 
		 
		 p.obiettivi.each do |o|
		   target = ""
		   stringa_indicatore = "_"
		   denominazione = o.denominazione_completa 
	       
	       
		   o.indicatori.each do | i |
			   stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			   target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
			  end
		   o.fasi.each do |f| 
		        denominazione = denominazione + "\n" + f.denominazione_completa 
		        f.indicatori.each do |i|
                  #denominazione = denominazione +  "\n" + i.denominazione 
			      stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			      target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
	            end
				f.azioni.each do |a|
				  a.indicatori.each do |i|
				    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			        target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
				  end 
				end
	       end
		   
		   worksheet_ufficio.write(row, 0, o.codice, format1)
           worksheet_ufficio.write(row, 1, denominazione, format1)
		   worksheet_ufficio.write(row, 2, " ", format1center)
		   ga = GoalAssignment.where(person_id: p.id, operational_goal_id: o.id).first
		   peso = (ga != nil ? ga.wheight : "-")
		   worksheet_ufficio.write(row, 3, peso, format1center)
		   
		  
		   worksheet_ufficio.write(row, 4, stringa_indicatore.gsub(/[^0-9A-Za-z\/%><=., ]/,""), format1center)
		   worksheet_ufficio.write(row, 5, target, format1)
		   row = row + 1
		 end
		 p.fasi.each do |f|
		   target = ""
		   stringa_indicatore = ""
		   denominazione = ""
		   worksheet_ufficio.write(row, 0, f.codice, format1)
		   #denominazione = f.obiettivo_operativo_fase.denominazione_completa + "\n"
	       denominazione = denominazione + f.denominazione_completa 
	       # f.indicatori.each do |i|
              # #denominazione = denominazione +  "\n" + i.denominazione 
			  # target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/% ]/,"")   
			  # stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
	       # end
	       # f.azioni.each do |a| 
             # denominazione = denominazione + "\n" + a.denominazione.strip.html_safe 
			 
	       # end 
		   
		    f.indicatori.each do | i |
			   stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			   target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
			end
			  
			f.azioni.each do |a|
				  a.indicatori.each do |i|
				    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			        target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
				  end
			  end 
		   
		   
		   
		   worksheet_ufficio.write(row, 1, denominazione, format1)
		   worksheet_ufficio.write(row, 2, " ", format1center)
		   fa = PhaseAssignment.where(person_id: p.id, phase_id: f.id).first
		   peso = (fa != nil ? fa.wheight : "-")
		   worksheet_ufficio.write(row, 3, peso, format1center)
		   worksheet_ufficio.write(row, 4, stringa_indicatore.gsub(/[^0-9A-Za-z\/%><=., ]/,""), format1center)
		   worksheet_ufficio.write(row, 5, target, format1)
		   row = row + 1
		 end
		 p.azioni.each do |a|
		   target = ""
		   stringa_indicatore = "_"
		   denominazione = ""
		   #denominazione = a.obiettivo_operativo_denominazione_completa + "\n"
	       #denominazione = denominazione + a.fase_denominazione_completa + "\n"
	       denominazione = denominazione + a.denominazione_completa
	       a.indicatori.each do |i| 
              #denominazione = denominazione + "\n" + i.denominazione 
              target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
              stringa_indicatore = stringa_indicatore + " " + i.nome.to_s  			  
	       end 
		   worksheet_ufficio.write(row, 0, a.codice, format1)
		   worksheet_ufficio.write(row, 1, denominazione, format1)
		   worksheet_ufficio.write(row, 2, " ", format1center)
		   saa = SimpleActionAssignment.where(person_id: p.id, simple_action_id: a.id).first
		   peso = (saa != nil ? saa.wheight : "-")
		   worksheet_ufficio.write(row, 3, peso, format1center)
		   worksheet_ufficio.write(row, 4, stringa_indicatore.gsub(/[^0-9A-Za-z\/%><=., ]/,""), format1center)
		   worksheet_ufficio.write(row, 5, target, format1)
		   row = row + 1
		 end
		 p.opere_assegnate.each do |op|
		   target = ""
		   stringa_indicatore = "_"
		   denominazione = op.denominazione_completa + "\n"
	  
	       op.indicatori.each do |i| 
              denominazione = denominazione + "\n" + i.denominazione  
			  target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"")    
			  stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
	       end 
		   worksheet_ufficio.write(row, 0, op.codice, format1)
		   worksheet_ufficio.write(row, 1, denominazione, format1)
		   worksheet_ufficio.write(row, 2, " ", format1center)
		   opa = OperaAssignment.where(person_id: p.id, opera_id: op.id).first
		   peso = (opa != nil ? opa.wheight : "-")
		   worksheet_ufficio.write(row, 3, peso, format1center)
		   worksheet_ufficio.write(row, 4, stringa_indicatore.gsub(/[^0-9A-Za-z\/%><=., ]/,""), format1center)
		   worksheet_ufficio.write(row, 5, target, format1)
		   row = row + 1
		 end
         
		 row = row + 1
        
         
		 
	   end # fine lista dipendenti
	
	end # fine risultati : uffici
	exfile.close
    send_file nomefileout
  end 
  
  def riassuntivo_assegnazioni_raggruppate
    
	
    @dirigente = Person.find(params[:schedaxls][:dirigente_id])
	registra("riassuntivo_assegnazioni_raggruppate" + @dirigente.nominativo )
	filename = "RiassuntivoAssegnazioniRaggruppate_" + @dirigente.cognome + "_" + @dirigente.nome
    nomefileout = filename + ".xlsx"
    exfile = WriteXLSX.new(nomefileout)
	
	format1 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 8})
	format1.set_text_wrap() 
	
    format1red = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'font_color': 'red',
	'fg_color': 'red',
	'size': 8})
  #format1red.set_font_color('red')
  
      format12 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 10})
	format1.set_text_wrap() 
	
    

    format1center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'size': 8})
    format1center.set_text_wrap() ;
	
	format1centerGreen = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'lime',
	'font': 'Franklin Gothic Book',
	'size': 8})
    format1centerGreen.set_text_wrap() ;
	
	
	format12center = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	
	'size': 10})
    format1center.set_text_wrap() ;
	
	format12centerMagenta = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'fg_color': 'magenta',
	'size': 10})
    format1center.set_text_wrap() ;
	
	format12centerCyan = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Franklin Gothic Book',
	'fg_color': 'cyan',
	'size': 10})
    format1center.set_text_wrap() ;

    format_titolo = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'green',
	'font': 'Calibrì',
	'wrap_text': 'true',
	'size': 9})

    format_ufficio = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'fg_color': 'cyan',
	'font': 'Calibrì',
	'size': 9})
	
	array_uffici = []
	@dirigente.dirige.each do |s|
	  stack = []
	  max_iterazioni = 6
	  stack <<  s
	  
	  while ! stack.empty?
	    current = stack.last
		if current.children.length > 0
		  array_uffici << stack.pop
		  current.children.each do | u | stack << u end
		else
		  array_uffici << stack.pop
		end
	   
	  end
	
	end
	
	index = 0
	array_uffici.each do |ufficio|
	  index = index + 1
	  nome_ufficio = index.to_s + "-" + ufficio.nome.to_s.gsub(/[^0-9A-Za-z ]/,"").strip.first(27)  #nome_ufficio 
	  
	  worksheet_ufficio = exfile.add_worksheet(name = nome_ufficio )
	  worksheet_ufficio.set_landscape
	  worksheet_ufficio.fit_to_pages(1, 0)
	  
	  # worksheet_ufficio.set_column('A:A', 10)
	  # worksheet_ufficio.set_column('B:B', 50)
	  # worksheet_ufficio.set_column('C:C', 30)
	  # worksheet_ufficio.set_column('D:D', 10)
	  # worksheet_ufficio.set_column('E:E', 30)
	  # worksheet_ufficio.set_column('F:F', 30)
	  # worksheet_ufficio.set_column('G:G', 30)
	  # worksheet_ufficio.set_column('H:H', 30)
	  # worksheet_ufficio.set_column('I:I', 30)
	  # worksheet_ufficio.set_column('J:J', 30)
	  # worksheet_ufficio.set_column('K:K', 30)
	  # worksheet_ufficio.set_column('L:L', 30)
	  # worksheet_ufficio.set_column('M:M', 30)
	  
	  worksheet_ufficio.set_column('A:A', 10)
	  worksheet_ufficio.set_column('B:B', 30)
	  worksheet_ufficio.set_column('C:C', 25)
	  worksheet_ufficio.set_column('D:D', 10)
	  worksheet_ufficio.set_column('E:E', 30)
	  worksheet_ufficio.set_column('F:F', 25)
	  worksheet_ufficio.set_column('G:G', 20)
	  worksheet_ufficio.set_column('H:H', 20)
	  worksheet_ufficio.set_column('I:I', 20)
	  worksheet_ufficio.set_column('J:J', 20)
	  worksheet_ufficio.set_column('K:K', 20)
	  worksheet_ufficio.set_column('L:L', 20)
	  worksheet_ufficio.set_column('M:M', 20)
	  
	  row = 1
	   
	  worksheet_ufficio.merge_range('A1:D1', 'SCHEDA ASSEGNAZIONE OBIETTIVI ', format12center)
	   
	  worksheet_ufficio.write(row-1, 4, 'ANNO', format12)
	  worksheet_ufficio.write(row-1, 5, (Setting.where(denominazione: 'anno').length >0 ?  Setting.where(denominazione: 'anno').first.value : " - "), format12center)
	   
      row = row + 2 
	   
	  worksheet_ufficio.write(row-1, 0, " SERVIZIO ", format12center)
	  worksheet_ufficio.merge_range("B" + row.to_s + ":F" + row.to_s, ufficio.ufficio_apicale.nome.to_s , format12centerMagenta)
	   
	  row = row + 1
	  worksheet_ufficio.write(row-1, 0, " Struttura (U.ORG, U.O, U.S) ", format12center)
	  worksheet_ufficio.merge_range("B" + row.to_s + ":F" + row.to_s, ufficio.nome.to_s , format12centerCyan)
	   
	  row = row + 2
	  worksheet_ufficio.write(row, 0, " CODICE ", format1center)
	  worksheet_ufficio.write(row, 1, " OBIETTIVO ", format1center)
      worksheet_ufficio.write(row, 2, " DIPENDENTI ", format1center)
      worksheet_ufficio.write(row, 3, " PESO", format1center)
      worksheet_ufficio.write(row, 4, " INDICATORE", format1center)
      worksheet_ufficio.write(row, 5, " TARGET ", format1center)
	   
	  row = row + 2
	  
	  array_target = []
	  ufficio.people.each do |p|
        p.obiettivi.each do |t| array_target = array_target | [t] end 
		p.fasi.each do |t| array_target = array_target | [t] end 
		p.azioni.each do |t| array_target = array_target | [t] end 
		p.opere_assegnate.each do |t| array_target = array_target | [t] end 
		
		
      end	
      
      array_target.each do |t|
	  
	      denominazione = t.denominazione.to_s
	      
		  
		  target = ""
		  stringa_indicatore = ""
		  case t.tipo
			when "Obiettivo"
			  
			  t.indicatori.each do | i |
			   stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			   target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
			  end
			  t.fasi.each do |f| 
		        denominazione = denominazione + "\n" + f.denominazione_completa 
		        f.indicatori.each do |i|
                  #denominazione = denominazione +  "\n" + i.denominazione 
			      stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			      target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
	            end
				f.azioni.each do |a|
				  a.indicatori.each do |i|
				    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			        target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
				  end 
				end
	          end
			  
			when "Fase"
			 
			  
			  t.indicatori.each do | i |
			   stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			   target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
			  end
			  
			  t.azioni.each do |a|
				  a.indicatori.each do |i|
				    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			        target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
				  end
			  end 
		      
			  
			when "Azione"
			 
			  
			  t.indicatori.each do |i|
				    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
			        target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"") 
			  end 
			  
			when "Opera"
			 			  		      	  
	          t.indicatori.each do |i| 
                denominazione = denominazione + "\n" + i.denominazione  
			    target = target + "\n" + i.descrizione_valore_misurazione.to_s.gsub(/[^0-9A-Za-z\/%><=., ]/,"")    
			    stringa_indicatore = stringa_indicatore + " " + i.nome.to_s
	          end 
			
			end
		  
		  worksheet_ufficio.write(row, 0, t.codice, format1)
		  worksheet_ufficio.write(row, 1, denominazione, format1)
		  worksheet_ufficio.write(row, 2, " ", format1center)
		  worksheet_ufficio.write(row, 3, " ", format1center)
		  worksheet_ufficio.write(row, 4, stringa_indicatore, format1center)
		  worksheet_ufficio.write(row, 5, target, format1)
          
		  row = row + 1
		  
		  t.assegnatari.each do |p|
		    target = ""
		    stringa_indicatore = "_"
		    
		    peso = "" 
		    
			worksheet_ufficio.write(row, 0, p.matricola.to_s, format1)
		    worksheet_ufficio.write(row, 1, " ", format1)
		    worksheet_ufficio.write(row, 2, p.nominativo, format1center)
			
			peso = "" 
			case t.tipo
			when "Obiettivo"
			  ga = GoalAssignment.where(person_id: p.id, operational_goal_id: t.id).first
		      peso = (ga != nil ? ga.wheight : "-")
			  
			  
			when "Fase"
			  fa = PhaseAssignment.where(person_id: p.id, phase_id: t.id).first
		      peso = (fa != nil ? fa.wheight : "-")
			  
			 	      
			  
			when "Azione"
			  saa = SimpleActionAssignment.where(person_id: p.id, simple_action_id: t.id).first
		      peso = (saa != nil ? saa.wheight : "-")
			  
			 
			  
			when "Opera"
			  opa = OperaAssignment.where(person_id: p.id, opera_id: t.id).first
		      peso = (opa != nil ? opa.wheight : "-")
			  
			
			end
		  
		    worksheet_ufficio.write(row, 3, peso, format1center)
		    worksheet_ufficio.write(row, 4, " ", format1center)
		    worksheet_ufficio.write(row, 5, " ", format1)
			 
		    row = row + 1
		  end
		  row = row + 2
      end 	  
	
	
	end
	
	exfile.close
    send_file nomefileout
  
  end 
  
  def scheda_personale_x_dipendente
  
    if current_user_admin?
	  @people = Person.all.order("cognome asc")
	elsif current_user.dirige != nil
	  @people = current_user.dipendenti_sotto
    else
      @people = [current_user]
	end
    
  end
  
  def scheda_personale_x_dipendente_mostra
    puts params
    
	@dipendente = Person.find(params[:person][:id])
	
	@dirigente = @dipendente.dirigente
	
	puts @dipendente.nominativo
	puts @dirigente.nominativo
	
	respond_to do |format|
	   format.js   {render :action => "scheda_personale_x_dipendente_mostra" } 
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:nome, :cognome, :matricola, :ruolo, :flag_calcolo_produttivita, :tempo, :servizio_percentuale, :categoria, :email, :qualification_type_id, :password, :password_confirmation, :reset_digest, :abilitato)
    end
	
	def check_login
	 if !logged_in? then redirect_to root_url end
	end
	
	
	def scheda_excel_comportamento(persona, dirigente, exfile)
	
	 puts "SCHEDA COMPORTAMENTO"
	 
	 numero_foglio = exfile.sheets.length + 1
	 nome_foglio = (numero_foglio.to_s + "_" + persona.nominativo).gsub(/[^0-9A-Za-z_]/,"").truncate(30)
	 worksheet_comportamento = exfile.add_worksheet(sheetname = nome_foglio)
	 
	 worksheet_comportamento.set_portrait
	 worksheet_comportamento.fit_to_pages(1, 1)
	 
	 cella_risultatocomplessivo = "\'" + nome_foglio + "\'" + "!"
	 #worksheet_comportamento = exfile.add_worksheet(sheetname = (persona.nominativo).truncate(30))
	 #worksheet_obiettivi = exfile.add_worksheet(sheetname = 'Scheda obiettivi')
	
	 format1 = exfile.add_format # Add a format
	 format1.set_font('Century Gothic')
	 format1.set_size(10)
	 format1.set_align('center')
	 format1.set_valign('center')
	
	 format2 = exfile.add_format # Add a format
	 format2.set_font('Arial')
	 format2.set_size(10)
	 format2.set_align('center')
	 format3 = exfile.add_format({
     'bold': 1,
     'border': 1,
     'valign': 'vcenter',
     'fg_color': 'yellow'})

	 format3.set_font('Arial')
	 format3.set_size(8)
	 format3.set_align('right')
	 format3.set_bold
	
	 format3white = exfile.add_format({
     'bold': 1,
     'border': 1,
     'valign': 'vcenter'})

	 format3.set_font('Arial')
	 format3.set_size(8)
	 format3.set_align('right')
	 format3.set_bold
	 
	 
	 format3_wrap = exfile.add_format
	 format3_wrap.set_font('Century Gothic')
	 format3_wrap.set_size(8)
	 format3_wrap.set_align('left')
	 format3_wrap.set_valign('vcenter')
	 format3_wrap.set_text_wrap() 
	 format3_wrap.set_fg_color('yellow')
	 format3_wrap.set_border (1)
	
	
	
	 format4 = exfile.add_format # Add a format
	 format4.set_font('Century Gothic')
	 format4.set_size(10)
	 format4.set_align('left')
	 format4.set_bottom_color('cyan')
	 format4.set_bg_color('plum')
	 format4.set_top_color('black')
	 format4.set_bold
	 format4.set_text_wrap() ;
	 
	 format4_8 = exfile.add_format # Add a format
	 format4_8.set_font('Century Gothic')
	 format4_8.set_size(9)
	 format4_8.set_align('center')
	 format4_8.set_bottom_color('cyan')
	 format4_8.set_bg_color('plum')
	 format4_8.set_top_color('black')
	 format4_8.set_bold
	 format4_8.set_text_wrap() ;
	 
	 format4_right = exfile.add_format # Add a format
	format4_right.set_font('Century Gothic')
	format4_right.set_size(10)
	format4_right.set_align('right')
	format4_right.set_bottom_color('cyan')
	format4_right.set_bg_color('plum')
	format4_right.set_top_color('black')
	format4_right.set_bold
	format4_right.set_text_wrap() 
	
	 format5 = exfile.add_format # Add a format
	 format5.set_font('Century Gothic')
	 format5.set_size(8)
	 format5.set_align('left')
	 format5.set_bottom_color('gray')
	 format5.set_top_color('black')
	
	 format5right = exfile.add_format # Add a format
	 format5right.set_font('Arial')
	 format5right.set_size(8)
	 format5right.set_align('right')
	 format5right.set_bottom_color('gray')
	 format5right.set_top_color('black')
	
	 format6 = exfile.add_format
	 format6.set_font('Century Gothic')
	 format6.set_size(8)
	 format6.set_align('left')
	 format6.set_valign('vcenter')
	 format6.set_text_wrap() ;
	
	 format7firme = exfile.add_format # Add a format
	 format7firme.set_font('Century Gothic')
	 format7firme.set_size(6)
	 format7firme.set_align('left')
	 format7firme.set_bottom_color('cyan')
	 format7firme.set_bg_color('plum')
	 format7firme.set_top_color('black')
	 format7firme.set_bold
	 format7firme.set_valign('vcenter')
	 format7firme.set_text_wrap() ;
	
	
	 format7 = exfile.add_format({
     'bold': 1,
     'border': 1,
     'align': 'center',
     'valign': 'vcenter',
	 'font': 'Calibrì',
	 'size': 9})
	 format7.set_text_wrap()
	
	 worksheet_comportamento.set_column('A:A', 40)
	 worksheet_comportamento.set_column('B:B', 10)
	 worksheet_comportamento.set_column('C:C', 10)
	 worksheet_comportamento.set_column('D:D', 15)
	 worksheet_comportamento.set_column('E:E', 10)
	 worksheet_comportamento.set_column('F:F', 10)
	 worksheet_comportamento.set_column('G:G', 10)
	 worksheet_comportamento.set_column('H:H', 10)
		
	 worksheet_comportamento.merge_range('A1:D1', 'SCHEDA DI VALUTAZIONE INDIVIDUALE - AREA COMPORTAMENTALE ', format1)
	 worksheet_comportamento.set_row(0, 50)
	
	 worksheet_comportamento.write(1, 2, 'ANNO', format1)
	 worksheet_comportamento.write(1, 3, (Setting.where(denominazione: 'anno').length >0 ?  Setting.where(denominazione: 'anno').first.value : " - "), format1)
 	
	 worksheet_comportamento.merge_range('A3:B3', 'Nome Cognome', format4)
	 worksheet_comportamento.merge_range('C3:D3', persona.nome + " " + persona.cognome, format4)
	 worksheet_comportamento.merge_range('A4:B4', 'Nr Matricola', format4)
	 worksheet_comportamento.merge_range('C4:D4', persona.matricola, format4)
	 worksheet_comportamento.merge_range('A5:B5', 'Qualifica', format4)
	 worksheet_comportamento.merge_range('C5:D5', persona.qualification != nil ? persona.qualification.denominazione : '-', format4)
	 worksheet_comportamento.merge_range('A6:B6', 'Categoria', format4)
	 worksheet_comportamento.merge_range('C6:D6', persona.stringa_categoria != nil ? persona.stringa_categoria : '-', format4)
	 worksheet_comportamento.merge_range('A7:B7', 'Dirigente', format4)
	 worksheet_comportamento.merge_range('C7:D7', dirigente.nome + " " + dirigente.cognome, format4)
	
	 worksheet_comportamento.merge_range('A9:D9', 'Valutazione comportamento', format4)
	 worksheet_comportamento.merge_range('A10:B10', 'Le assenze incidono sul premio (SI/NO)', format4)
	 worksheet_comportamento.write(9, 2, 'SI/NO', format3)
	 worksheet_comportamento.write(9, 4, persona.totassenze.to_s + "gg/" + persona.totgg.to_s + "gg", format4_right)
	 worksheet_comportamento.write(9, 3, (persona.totgg.to_f != 0 ? (100*persona.totassenze.to_f/persona.totgg.to_f).round(2).to_s + "%" : "n.a."), format4_right)
	 worksheet_comportamento.write(10, 0, 'Denominazione Fattore', format4)
	 worksheet_comportamento.write(10, 1, 'Peso', format4)
	 worksheet_comportamento.write(10, 2, 'Voto', format4)
	 worksheet_comportamento.write(10, 3, 'Voto pesato', format4)
	
	 indice_riga = 11 
	 numeratore = '(0'
	 denominatore = '(0'
	 somma_pesi = '(0'
	 persona.check_valutazioni
	 persona.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc").each do |v|
	  if v != nil
	    if v.vfactor != nil 
		 denominazione = v.vfactor.denominazione
		 #denominazione = v.vfactor.descrizione
		else 
		 denominazione = "-"
		end
		#worksheet_comportamento.merge_range('A7:D7', denominazione, format3)
		#d = denominazione.gsub(/|/, "\x0A")
		d = denominazione
		# righe = denominazione.split(/|/)
		# righe.each do |r|
		 # d = d + r + "\x0A"
		# end
		worksheet_comportamento.write(indice_riga, 0, d, format6)
		if v.vfactor != nil 
		 peso = v.vfactor.peso(persona) 
		else 
		 peso =  "-"
		end
		worksheet_comportamento.write(indice_riga, 1, peso, format3white)
	    if v.value != nil 
		 valore = v.value 
		 
		else 
		 valore =  "-"
		end
		worksheet_comportamento.write(indice_riga, 2, valore, format3)
		worksheet_comportamento.write(indice_riga, 3, '=0.1*B'+(indice_riga+1).to_s+'*C'+(indice_riga+1).to_s, format3white)
		indice_riga = indice_riga + 1
		numeratore = numeratore + '+C' + indice_riga.to_s + '*B' + indice_riga.to_s
		somma_pesi = somma_pesi + '+B'+ indice_riga.to_s 
		denominatore = denominatore + '+B'+ indice_riga.to_s + '*' + (v.vfactor.max).to_s
		worksheet_comportamento.set_row(indice_riga, 40)
	 end
	 end
	 numeratore = numeratore + ')' 
	 denominatore = denominatore  + ')'
	 somma_pesi = somma_pesi  + ')'
	 # worksheet_comportamento.write(indice_riga, 0, 'Media pesata')
	 # worksheet_comportamento.write(indice_riga, 3, '=' + numeratore + '/' + somma_pesi)
	 # indice_riga = indice_riga + 1
	 
	 worksheet_comportamento.write(indice_riga, 0, 'Punteggio Finale')
	 worksheet_comportamento.write(indice_riga, 3, '=(100*' + numeratore + '/' + denominatore + ')')
	 cella_risultatocomplessivo = cella_risultatocomplessivo + "D" + (indice_riga + 1).to_s
	 indice_riga = indice_riga + 1
	
	 indice_riga = indice_riga + 2
	 worksheet_comportamento.write(indice_riga, 0, 'Data _____________________________ ', format7firme)
	 worksheet_comportamento.set_row(indice_riga, 30)
	 indice_riga = indice_riga + 1
	
	 worksheet_comportamento.write(indice_riga, 0, "Firma del dipendente per presa visione della valutazione assegnata dal dirigente \x0A  \x0A ________________________________", format7firme)
	 #worksheet_comportamento.merge_range('C'+(indice_riga+1).to_s+':D'+(indice_riga+1).to_s, "firma del dirigentee \x0A \x0A _______________________", format7firme)
	
	 worksheet_comportamento.set_row(indice_riga, 60)
	 indice_riga = indice_riga + 1
	
	
	 #indice_riga = indice_riga + 1
	 descrizione = Setting.where(denominazione: "descrizione_punteggi").first 
     testo = (descrizione != nil ? descrizione.descrizione : " - " ) 

     testo.each_line do |s| 
       stringa_colonne = 'A' + indice_riga.to_s + ':D' + indice_riga.to_s
	   worksheet_comportamento.merge_range(stringa_colonne, s, format5)
	   indice_riga = indice_riga + 1
     end
	 
	 indice_riga = indice_riga+1
	 stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	 worksheet_comportamento.write(indice_riga, 0, 'Indicazioni del dirigente:', format4)
	 worksheet_comportamento.merge_range(stringa_merge, persona.indicazioni_miglioramento_prestazione.to_s, format3_wrap)
	 indice_riga = indice_riga +1 
	 stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	 worksheet_comportamento.write(indice_riga, 0, 'Considerazioni del valutato:', format4)
	 worksheet_comportamento.merge_range(stringa_merge, persona.considerazioni_del_valutato.to_s, format3_wrap)
	 
	 indice_riga = indice_riga + 3
	 stringa = "PUNTEGGIO  TOTALE " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-")
	 worksheet_comportamento.merge_range('A'+indice_riga.to_s+':B'+ indice_riga.to_s, stringa, format4)
	 moltiplicatore_valutazione_pagella = persona.percentuale_pagella 
	 moltiplicatore_valutazione_obiettivi = persona.percentuale_obiettivi
     valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  persona.punteggiofinale  + moltiplicatore_valutazione_obiettivi * persona.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
     stringa = "" + moltiplicatore_valutazione_pagella.to_s + "*" +persona.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + persona.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s 
     worksheet_comportamento.merge_range('C'+indice_riga.to_s+':D'+ indice_riga.to_s, stringa, format4)  
	 
	 return cella_risultatocomplessivo
 end

 def scheda_excel_obiettivi(persona, dirigente, exfile) 
 
     puts "SCHEDA OBIETTIVI"
	 
	 numero_foglio = exfile.sheets.length + 1
	 nome_foglio = (numero_foglio.to_s + "_" + persona.nominativo).gsub(/[^0-9A-Za-z_]/,"").truncate(30)
	 worksheet_obiettivi = exfile.add_worksheet(sheetname = nome_foglio)
	 worksheet_obiettivi.set_portrait
	 worksheet_obiettivi.fit_to_pages(1, 0)
	 
	 cella_risultatocomplessivo = "\'" + nome_foglio + "\'" + "!"
	 
	 format1 = exfile.add_format # Add a format
	format1.set_font('Century Gothic')
	format1.set_size(10)
	format1.set_align('center')
	format1.set_valign('center')
	
	format2 = exfile.add_format # Add a format
	format2.set_font('Arial')
	format2.set_size(10)
	format2.set_align('center')
	format3 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'valign': 'vcenter',
    'fg_color': 'yellow'})

	format3.set_font('Arial')
	format3.set_size(8)
	format3.set_align('right')
	format3.set_bold
	
	format3white = exfile.add_format({
    'bold': 1,
    'border': 1,
    'valign': 'vcenter'})

	format3.set_font('Arial')
	format3.set_size(8)
	format3.set_align('right')
	format3.set_bold
	
	format3_wrap = exfile.add_format
	format3_wrap.set_font('Century Gothic')
	format3_wrap.set_size(8)
	format3_wrap.set_align('left')
	format3_wrap.set_valign('vcenter')
	format3_wrap.set_text_wrap() 
	format3_wrap.set_fg_color('yellow')
	format3_wrap.set_border (1)
	
	format4 = exfile.add_format # Add a format
	format4.set_font('Century Gothic')
	format4.set_size(10)
	format4.set_align('left')
	format4.set_bottom_color('cyan')
	format4.set_bg_color('plum')
	format4.set_top_color('black')
	format4.set_bold
	format4.set_text_wrap() 
	
	format4_right = exfile.add_format # Add a format
	format4_right.set_font('Century Gothic')
	format4_right.set_size(10)
	format4_right.set_align('right')
	format4_right.set_bottom_color('cyan')
	format4_right.set_bg_color('plum')
	format4_right.set_top_color('black')
	format4_right.set_bold
	format4_right.set_text_wrap() 
	
	format5 = exfile.add_format # Add a format
	format5.set_font('Century Gothic')
	format5.set_size(8)
	format5.set_align('left')
	format5.set_bottom_color('gray')
	format5.set_top_color('black')
	
	format5right = exfile.add_format # Add a format
	format5right.set_font('Arial')
	format5right.set_size(8)
	format5right.set_align('right')
	format5right.set_bottom_color('gray')
	format5right.set_top_color('black')
	
	format6 = exfile.add_format
	format6.set_font('Century Gothic')
	format6.set_size(8)
	format6.set_align('left')
	format6.set_valign('vcenter')
	format6.set_text_wrap() ;
	
	format7firme = exfile.add_format # Add a format
	format7firme.set_font('Century Gothic')
	format7firme.set_size(6)
	format7firme.set_align('left')
	format7firme.set_bottom_color('cyan')
	format7firme.set_bg_color('plum')
	format7firme.set_top_color('black')
	format7firme.set_bold
	format7firme.set_valign('vcenter')
	format7firme.set_text_wrap() ;
	#format6.set_bold
	
	
	
	format7 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()
	
	#####################
	#   scheda obiettivi
	#####################
	
	worksheet_obiettivi.set_column('A:A', 10)
	worksheet_obiettivi.set_column('B:B', 80)
	worksheet_obiettivi.set_column('C:C', 20)
	worksheet_obiettivi.set_column('D:D', 20)
	worksheet_obiettivi.set_column('E:E', 30)
	worksheet_obiettivi.set_column('F:F', 30)
	worksheet_obiettivi.set_column('G:G', 30)
	worksheet_obiettivi.set_column('H:H', 30)
	
	worksheet_obiettivi.merge_range('A1:E1', 'Scheda individuale obiettivi', format1)
	worksheet_obiettivi.merge_range('A2:B2', 'Nome Cognome', format4)
	worksheet_obiettivi.merge_range('C2:E2', persona.nome.to_s + " " + persona.cognome.to_s, format4)
	worksheet_obiettivi.merge_range('A3:B3', 'Nr Matricola', format4)
	worksheet_obiettivi.merge_range('C3:E3', persona.matricola.to_s, format4)
	worksheet_obiettivi.merge_range('A4:B4', 'Qualifica', format4)
	worksheet_obiettivi.merge_range('C4:E4', persona.qualifica.to_s, format4)
	worksheet_obiettivi.merge_range('A5:B5', 'Dirigente', format4)
	worksheet_obiettivi.merge_range('C5:E5', dirigente.nome.to_s + " " + dirigente.cognome.to_s, format4)
	
	worksheet_obiettivi.merge_range('A6:B6', 'Le assenze incidono sul premio (SI/NO)', format4)
	worksheet_obiettivi.write(5, 2, 'SI/NO', format3)
	worksheet_obiettivi.write(5, 4, persona.totassenze.to_s + "gg/" + persona.totgg.to_s + "gg", format4_right)
	worksheet_obiettivi.write(5, 3, (persona.totgg.to_f != 0 ? (100*persona.totassenze.to_f/persona.totgg.to_f).round(2).to_s + "%" : "n.a."), format4_right)
	
	
	worksheet_obiettivi.merge_range('A7:E7', 'Valutazione obiettivi', format4)
	worksheet_obiettivi.write(8, 0, 'ID', format1)
	worksheet_obiettivi.write(8, 1, 'Denominazione', format6)
	worksheet_obiettivi.write(8, 2, 'Tipo', format6)
	worksheet_obiettivi.write(8, 3, 'Peso', format6)
	worksheet_obiettivi.write(8, 4, 'Percentuale raggiungimento', format6)
	worksheet_obiettivi.write(8, 5, 'Valutazione dirigente', format4)
	
	indice_riga = 9
	numero_obiettivi = 0
	numeratore = '(0'
	numeratore_valutazioni = '(0'
	denominatore = '(0'
	result = 0
	
    persona.obiettivi.each do |o|
	  #stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  #worksheet_obiettivi.merge_range(stringa_colonne, o.denominazione, format4)
	  denominazione = o.denominazione_completa 
	  if !o.extrapeg
	   o.indicatori.each do |i| 
		 denominazione = denominazione + "\n" + i.denominazione 
	   end
	  end
	  o.fasi.each do |f| 
		 denominazione = denominazione + "\n" + f.denominazione_completa 
		 f.indicatori.each do |i|
           denominazione = denominazione +  "\n" + i.denominazione 
	     end
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, o.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Obiettivo', format4)
	  ga = GoalAssignment.where(persona: persona, obiettivo: o).first
	  worksheet_obiettivi.write(indice_riga, 3, (ga.wheight != nil ? ga.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (o.valutazione != nil ? (o.valutazione.valore_valutazione_oiv) : 0), format4)
	  # qua ci va la misurazione
	  worksheet_obiettivi.write(indice_riga, 4, (o.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: o).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = o
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # numeratore = numeratore + o.valore_totale * (ga.wheight != nil ? ga.wheight : 0.0)
	  # denominatore = denominatore + (ga.wheight != nil ? ga.wheight : 0.0)
	end
	
	persona.fasi.each do |f|
	  denominazione = ""
	  # stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  # worksheet_obiettivi.merge_range(stringa_colonne, f.denominazione, format4)
	  denominazione = f.obiettivo_operativo_fase.denominazione_completa + "\n"
	  denominazione = denominazione + f.denominazione_completa 
	  f.indicatori.each do |i|
        denominazione = denominazione +  "\n" + i.denominazione.to_s + " "
	  end
	  f.azioni.each do |a| 
         denominazione = denominazione + "\n" + a.denominazione_completa 
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, f.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Fase', format4)
	  fa = PhaseAssignment.where(persona: persona, fase: f).first
	  worksheet_obiettivi.write(indice_riga, 3, (fa.wheight != nil ? fa.wheight : 0.0), format4)
	  worksheet_obiettivi.write(indice_riga, 4, (f.valutazione != nil ? (f.valutazione.valore_valutazione_oiv) : 0), format4)
	  # qua ci va la misurazione
	  #worksheet_obiettivi.write(indice_riga, 4, (f.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: f).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = f
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # 
	  # numeratore = numeratore + f.valore_totale * (fa.wheight != nil ? fa.wheight : 0.0)
	  # denominatore = denominatore + (fa.wheight != nil ? fa.wheight : 0.0)
	end
	
	persona.azioni.each do |a|
	  # stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  # worksheet_obiettivi.merge_range(stringa_colonne, a.denominazione, format4)
	  denominazione = a.obiettivo_operativo_denominazione_completa + "\n"
	  denominazione = denominazione + a.fase_denominazione_completa + "\n"
	  denominazione = denominazione + a.denominazione_completa
	  a.indicatori.each do |i| 
         denominazione = denominazione + "\n" + i.denominazione.to_s + " "  
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, a.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Azione', format4)
	  saa = SimpleActionAssignment.where(persona: persona, azione: a).first
	  worksheet_obiettivi.write(indice_riga, 3, (saa.wheight != nil ? saa.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (a.valutazione != nil ? (a.valutazione.valore_valutazione_oiv) : 0), format4)
	  worksheet_obiettivi.write(indice_riga, 4, (a.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: a).first
	  
	  
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = a
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # 
	  # numeratore = numeratore + a.valore_totale * (saa.wheight != nil ? saa.wheight : 0.0)
	  # denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	end
	
	
	persona.opere_assegnate.each do |o|
	  
	  denominazione = o.denominazione_completa + "\n"
	  
	  o.indicatori.each do |i| 
         denominazione = denominazione + "\n" + i.denominazione  
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, o.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Opera', format4)
	  opa = OperaAssignment.where(persona: persona, opera: o).first
	  worksheet_obiettivi.write(indice_riga, 3, (opa.wheight != nil ? opa.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (o.valutazione != nil ? (o.valutazione.valore_valutazione_oiv) : 0), format3)
	  worksheet_obiettivi.write(indice_riga, 4, (o.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: o).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = o
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  
	  
	  # 
	  # numeratore = numeratore + a.valore_totale * (saa.wheight != nil ? saa.wheight : 0.0)
	  # denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	end
	
	numeratore = numeratore + ')'
	numeratore_valutazioni = numeratore_valutazioni + ')'
	denominatore = denominatore + ')'
	worksheet_obiettivi.write(indice_riga + 2, 1, 'Punteggio Finale')
	stringa_espressione = '=' + numeratore + '/' + denominatore
	stringa_espressione_valutazioni = '=' + numeratore_valutazioni + '/' + denominatore+''
	worksheet_obiettivi.write(indice_riga + 2, 4, stringa_espressione)
	worksheet_obiettivi.write(indice_riga + 2, 5, stringa_espressione_valutazioni)
	cella_risultatocomplessivo = cella_risultatocomplessivo + "F" + (indice_riga + 3).to_s
	
	indice_riga = indice_riga+5
	stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	worksheet_obiettivi.write(indice_riga, 0, 'Indicazioni del dirigente:', format4)
	worksheet_obiettivi.merge_range(stringa_merge, persona.indicazioni_miglioramento_prestazione.to_s, format3_wrap)
	indice_riga = indice_riga +1 
	stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	worksheet_obiettivi.write(indice_riga, 0, 'Considerazioni del valutato:', format4)
	worksheet_obiettivi.merge_range(stringa_merge, persona.considerazioni_del_valutato.to_s, format3_wrap)
	
	indice_riga = indice_riga + 3
	stringa = "PUNTEGGIO  TOTALE " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-")
	worksheet_obiettivi.merge_range('A'+indice_riga.to_s+':B'+ indice_riga.to_s, stringa, format4)
	moltiplicatore_valutazione_pagella = persona.percentuale_pagella 
	moltiplicatore_valutazione_obiettivi = persona.percentuale_obiettivi 
    valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  persona.punteggiofinale  + moltiplicatore_valutazione_obiettivi * persona.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
    stringa = "" + moltiplicatore_valutazione_pagella.to_s + "*" +persona.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + persona.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s 
    worksheet_obiettivi.merge_range('C'+indice_riga.to_s+':D'+ indice_riga.to_s, stringa, format4) 
	
	return cella_risultatocomplessivo
 
 
 end
 
 
 def scheda_excel_pagella_obiettivi(persona, dirigente, exfile)

    puts "SCHEDA COMPORTAMENTO"
	 
	 numero_foglio = exfile.sheets.length + 1
	 nome_foglio = (numero_foglio.to_s + "_" + persona.nominativo).gsub(/[^0-9A-Za-z_]/,"").truncate(30)
	 worksheet_comportamento = exfile.add_worksheet(sheetname = nome_foglio)
	 
	 worksheet_comportamento.set_portrait
	 worksheet_comportamento.fit_to_pages(1, 1)
	 
	 cella_risultatocomplessivo_pagella = "\'" + nome_foglio + "\'" + "!"
	 cella_risultatocomplessivo_obiettivi = "\'" + nome_foglio + "\'" + "!"
	 
	
	 formatTITOLO = exfile.add_format # Add a format
	 formatTITOLO.set_font('Century Gothic')
	 formatTITOLO.set_size(12)
	 formatTITOLO.set_align('center')
	 formatTITOLO.set_valign('center')
	 formatTITOLO.set_bold
	
	 format1 = exfile.add_format # Add a format
	 format1.set_font('Century Gothic')
	 format1.set_size(10)
	 format1.set_align('center')
	 format1.set_valign('center')
	
	 format2 = exfile.add_format # Add a format
	 format2.set_font('Arial')
	 format2.set_size(10)
	 format2.set_align('center')
	 format3 = exfile.add_format({
     'bold': 1,
     'border': 1,
     'valign': 'vcenter',
     'fg_color': 'yellow'})

	 format3.set_font('Arial')
	 format3.set_size(8)
	 format3.set_align('right')
	 format3.set_bold
	
	 format3white = exfile.add_format({
     'bold': 1,
     'border': 1,
     'valign': 'vcenter'})

	 format3.set_font('Arial')
	 format3.set_size(8)
	 format3.set_align('right')
	 format3.set_bold
	 
	 
	 format3_wrap = exfile.add_format
	 format3_wrap.set_font('Century Gothic')
	 format3_wrap.set_size(8)
	 format3_wrap.set_align('left')
	 format3_wrap.set_valign('vcenter')
	 format3_wrap.set_text_wrap() 
	 format3_wrap.set_fg_color('yellow')
	 format3_wrap.set_border (1)
	
	
	
	 format4 = exfile.add_format # Add a format
	 format4.set_font('Century Gothic')
	 format4.set_size(10)
	 format4.set_align('left')
	 format4.set_bottom_color('cyan')
	 format4.set_bg_color('plum')
	 format4.set_top_color('black')
	 format4.set_bold
	 format4.set_text_wrap() ;
	 
	 format4_8 = exfile.add_format # Add a format
	 format4_8.set_font('Century Gothic')
	 format4_8.set_size(9)
	 format4_8.set_align('center')
	 format4_8.set_bottom_color('cyan')
	 format4_8.set_bg_color('plum')
	 format4_8.set_top_color('black')
	 format4_8.set_bold
	 format4_8.set_text_wrap() ;
	 
	 format4_right = exfile.add_format # Add a format
	format4_right.set_font('Century Gothic')
	format4_right.set_size(10)
	format4_right.set_align('right')
	format4_right.set_bottom_color('cyan')
	format4_right.set_bg_color('plum')
	format4_right.set_top_color('black')
	format4_right.set_bold
	format4_right.set_text_wrap() 
	
	 format5 = exfile.add_format # Add a format
	 format5.set_font('Century Gothic')
	 format5.set_size(8)
	 format5.set_align('left')
	 format5.set_bottom_color('gray')
	 format5.set_top_color('black')
	
	 format5right = exfile.add_format # Add a format
	 format5right.set_font('Arial')
	 format5right.set_size(8)
	 format5right.set_align('right')
	 format5right.set_bottom_color('gray')
	 format5right.set_top_color('black')
	
	 format6 = exfile.add_format
	 format6.set_font('Century Gothic')
	 format6.set_size(8)
	 format6.set_align('left')
	 format6.set_valign('vcenter')
	 format6.set_text_wrap() ;
	
	 format7firme = exfile.add_format # Add a format
	 format7firme.set_font('Century Gothic')
	 format7firme.set_size(6)
	 format7firme.set_align('left')
	 format7firme.set_bottom_color('cyan')
	 format7firme.set_bg_color('plum')
	 format7firme.set_top_color('black')
	 format7firme.set_bold
	 format7firme.set_valign('vcenter')
	 format7firme.set_text_wrap() ;
	
	
	 format7 = exfile.add_format({
     'bold': 1,
     'border': 1,
     'align': 'center',
     'valign': 'vcenter',
	 'font': 'Calibrì',
	 'size': 9})
	 format7.set_text_wrap()
	
	 worksheet_comportamento.set_column('A:A', 20)
	 worksheet_comportamento.set_column('B:B', 40)
	 worksheet_comportamento.set_column('C:C', 10)
	 worksheet_comportamento.set_column('D:D', 10)
	 worksheet_comportamento.set_column('E:E', 10)
	 worksheet_comportamento.set_column('F:F', 10)
	 worksheet_comportamento.set_column('G:G', 10)
	 worksheet_comportamento.set_column('H:H', 10)
		
	 worksheet_comportamento.merge_range('A1:D1', 'SCHEDA DI VALUTAZIONE INDIVIDUALE - AREA COMPORTAMENTALE ', formatTITOLO)
	 worksheet_comportamento.set_row(0, 50)
	
	 worksheet_comportamento.write(1, 2, 'ANNO', format1)
	 worksheet_comportamento.write(1, 3, (Setting.where(denominazione: 'anno').length >0 ?  Setting.where(denominazione: 'anno').first.value : " - "), format1)
 	
	 worksheet_comportamento.merge_range('A3:B3', 'Nome Cognome', format4)
	 worksheet_comportamento.merge_range('C3:D3', persona.nome + " " + persona.cognome, format4)
	 worksheet_comportamento.merge_range('A4:B4', 'Nr Matricola', format4)
	 worksheet_comportamento.merge_range('C4:D4', persona.matricola, format4)
	 worksheet_comportamento.merge_range('A5:B5', 'Qualifica', format4)
	 worksheet_comportamento.merge_range('C5:D5', persona.qualification != nil ? persona.qualification.denominazione : '-', format4)
	 worksheet_comportamento.merge_range('A6:B6', 'Categoria', format4)
	 worksheet_comportamento.merge_range('C6:D6', persona.stringa_categoria != nil ? persona.stringa_categoria : '-', format4)
	 worksheet_comportamento.merge_range('A7:B7', 'Dirigente', format4)
	 worksheet_comportamento.merge_range('C7:D7', dirigente.nome + " " + dirigente.cognome, format4)
	
	 worksheet_comportamento.merge_range('A9:D9', 'Valutazione comportamento', format4)
	 worksheet_comportamento.merge_range('A10:B10', 'Le assenze incidono sul premio (SI/NO)', format4)
	 worksheet_comportamento.write(9, 2, 'SI/NO', format3)
	 worksheet_comportamento.write(9, 4, persona.totassenze.to_s + "gg/" + persona.totgg.to_s + "gg", format4_right)
	 worksheet_comportamento.write(9, 3, (persona.totgg.to_f != 0 ? (100*persona.totassenze.to_f/persona.totgg.to_f).round(2).to_s + "%" : "n.a."), format4_right)
	 worksheet_comportamento.write(10, 1, 'Denominazione Fattore', format4)
	 worksheet_comportamento.write(10, 2, 'Peso', format4)
	 worksheet_comportamento.write(10, 3, 'Voto', format4)
	 worksheet_comportamento.write(10, 4, 'Voto pesato', format4)
	
	 indice_riga = 11 
	 numeratore = '(0'
	 denominatore = '(0'
	 somma_pesi = '(0'
	 persona.check_valutazioni
	 persona.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc").each do |v|
	  if v != nil
	    if v.vfactor != nil 
		 denominazione = v.vfactor.denominazione
		 #denominazione = v.vfactor.descrizione
		else 
		 denominazione = "-"
		end
		#worksheet_comportamento.merge_range('A7:D7', denominazione, format3)
		#d = denominazione.gsub(/|/, "\x0A")
		d = denominazione
		# righe = denominazione.split(/|/)
		# righe.each do |r|
		 # d = d + r + "\x0A"
		# end
		worksheet_comportamento.write(indice_riga, 1, d, format6)
		if v.vfactor != nil 
		 peso = v.vfactor.peso(persona) 
		else 
		 peso =  "-"
		end
		worksheet_comportamento.write(indice_riga, 2, peso, format3white)
	    if v.value != nil 
		 valore = v.value 
		 
		else 
		 valore =  "-"
		end
		worksheet_comportamento.write(indice_riga, 3, valore, format3)
		worksheet_comportamento.write(indice_riga, 4, '=0.1*C'+(indice_riga+1).to_s+'*D'+(indice_riga+1).to_s, format3white)
		indice_riga = indice_riga + 1
		numeratore = numeratore + '+D' + indice_riga.to_s + '*C' + indice_riga.to_s
		somma_pesi = somma_pesi + '+C'+ indice_riga.to_s 
		denominatore = denominatore + '+C'+ indice_riga.to_s + '*' + (v.vfactor.max).to_s
		worksheet_comportamento.set_row(indice_riga, 40)
	 end
	 end
	 numeratore = numeratore + ')' 
	 denominatore = denominatore  + ')'
	 somma_pesi = somma_pesi  + ')'
	 # worksheet_comportamento.write(indice_riga, 0, 'Media pesata')
	 # worksheet_comportamento.write(indice_riga, 3, '=' + numeratore + '/' + somma_pesi)
	 # indice_riga = indice_riga + 1
	 
	 worksheet_comportamento.write(indice_riga, 1, 'Punteggio Finale')
	 worksheet_comportamento.write(indice_riga, 4, '=(100*' + numeratore + '/' + denominatore + ')')
	 cella_risultatocomplessivo_pagella = cella_risultatocomplessivo_pagella + "E" + (indice_riga + 1).to_s
	 indice_riga = indice_riga + 1
	
	 
	
	 #indice_riga = indice_riga + 1
	 descrizione = Setting.where(denominazione: "descrizione_punteggi").first 
     testo = (descrizione != nil ? descrizione.descrizione : " - " ) 

     testo.each_line do |s| 
       stringa_colonne = 'A' + indice_riga.to_s + ':D' + indice_riga.to_s
	   worksheet_comportamento.merge_range(stringa_colonne, s, format5)
	   indice_riga = indice_riga + 1
     end
	 
	 indice_riga = indice_riga+1
	 # stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	 # worksheet_comportamento.write(indice_riga, 0, 'Indicazioni del dirigente:', format4)
	 # worksheet_comportamento.merge_range(stringa_merge, '              ', format3_wrap)
	 # indice_riga = indice_riga +1 
	 # stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	 # worksheet_comportamento.write(indice_riga, 0, 'Considerazioni del valutato:', format4)
	 # worksheet_comportamento.merge_range(stringa_merge, '        ', format3_wrap)
	 
	 # indice_riga = indice_riga + 3
	 # stringa = "PUNTEGGIO  TOTALE " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-")
	 # worksheet_comportamento.merge_range('A'+indice_riga.to_s+':B'+ indice_riga.to_s, stringa, format4)
	 # moltiplicatore_valutazione_pagella = persona.percentuale_obiettivi 
	 # moltiplicatore_valutazione_obiettivi = persona.percentuale_pagella 
     # valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  persona.punteggiofinale  + moltiplicatore_valutazione_obiettivi * persona.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
     # stringa = "" + moltiplicatore_valutazione_pagella.to_s + "*" +persona.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + persona.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s 
     # worksheet_comportamento.merge_range('C'+indice_riga.to_s+':D'+ indice_riga.to_s, stringa, format4)  
	 
	# return cella_risultatocomplessivo 
	 
	 
     puts "SCHEDA OBIETTIVI"
	 
	 indice_riga = indice_riga + 5
	 
	 cella_risultatocomplessivo_obiettivi = "\'" + nome_foglio + "\'" + "!"
	 
	 format1 = exfile.add_format # Add a format
	format1.set_font('Century Gothic')
	format1.set_size(10)
	format1.set_align('center')
	format1.set_valign('center')
	
	format2 = exfile.add_format # Add a format
	format2.set_font('Arial')
	format2.set_size(10)
	format2.set_align('center')
	format3 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'valign': 'vcenter',
    'fg_color': 'yellow'})

	format3.set_font('Arial')
	format3.set_size(8)
	format3.set_align('right')
	format3.set_bold
	
	format3white = exfile.add_format({
    'bold': 1,
    'border': 1,
    'valign': 'vcenter'})

	format3.set_font('Arial')
	format3.set_size(8)
	format3.set_align('right')
	format3.set_bold
	
	format3_wrap = exfile.add_format
	format3_wrap.set_font('Century Gothic')
	format3_wrap.set_size(8)
	format3_wrap.set_align('left')
	format3_wrap.set_valign('vcenter')
	format3_wrap.set_text_wrap() 
	format3_wrap.set_fg_color('yellow')
	format3_wrap.set_border (1)
	
	format4 = exfile.add_format # Add a format
	format4.set_font('Century Gothic')
	format4.set_size(10)
	format4.set_align('left')
	format4.set_bottom_color('cyan')
	format4.set_bg_color('plum')
	format4.set_top_color('black')
	format4.set_bold
	format4.set_text_wrap() 
	
	format4_right = exfile.add_format # Add a format
	format4_right.set_font('Century Gothic')
	format4_right.set_size(10)
	format4_right.set_align('right')
	format4_right.set_bottom_color('cyan')
	format4_right.set_bg_color('plum')
	format4_right.set_top_color('black')
	format4_right.set_bold
	format4_right.set_text_wrap() 
	
	format5 = exfile.add_format # Add a format
	format5.set_font('Century Gothic')
	format5.set_size(8)
	format5.set_align('left')
	format5.set_bottom_color('gray')
	format5.set_top_color('black')
	
	format5right = exfile.add_format # Add a format
	format5right.set_font('Arial')
	format5right.set_size(8)
	format5right.set_align('right')
	format5right.set_bottom_color('gray')
	format5right.set_top_color('black')
	
	format6 = exfile.add_format
	format6.set_font('Century Gothic')
	format6.set_size(8)
	format6.set_align('left')
	format6.set_valign('vcenter')
	format6.set_text_wrap() ;
	
	format7firme = exfile.add_format # Add a format
	format7firme.set_font('Century Gothic')
	format7firme.set_size(6)
	format7firme.set_align('left')
	format7firme.set_bottom_color('cyan')
	format7firme.set_bg_color('plum')
	format7firme.set_top_color('black')
	format7firme.set_bold
	format7firme.set_valign('vcenter')
	format7firme.set_text_wrap() ;
	#format6.set_bold
	
	
	
	format7 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'font': 'Calibrì',
	'size': 9})
	format7.set_text_wrap()
	
	#####################
	#   scheda obiettivi
	#####################
	worksheet_obiettivi = worksheet_comportamento
	
	# worksheet_obiettivi.set_column('A:A', 10)
	# worksheet_obiettivi.set_column('B:B', 80)
	# worksheet_obiettivi.set_column('C:C', 20)
	# worksheet_obiettivi.set_column('D:D', 20)
	# worksheet_obiettivi.set_column('E:E', 30)
	# worksheet_obiettivi.set_column('F:F', 30)
	# worksheet_obiettivi.set_column('G:G', 30)
	# worksheet_obiettivi.set_column('H:H', 30)
	
	worksheet_comportamento.merge_range('A' + (indice_riga).to_s + ':E' + (indice_riga).to_s, 'SCHEDA DI VALUTAZIONE INDIVIDUALE - VALUTAZIONE OBIETTIVI ', formatTITOLO)
		
	indice_riga = indice_riga + 1
	worksheet_obiettivi.merge_range('A' + (indice_riga).to_s + ':B' + (indice_riga ).to_s, 'Nome Cognome', format4)
	worksheet_obiettivi.merge_range('C' + (indice_riga).to_s + ':E' + (indice_riga ).to_s, persona.nome + " " + persona.cognome, format4)
	indice_riga = indice_riga + 1
	worksheet_obiettivi.merge_range('A' + (indice_riga).to_s + ':B' + (indice_riga ).to_s, 'Nr Matricola', format4)
	worksheet_obiettivi.merge_range('C' + (indice_riga).to_s + ':E' + (indice_riga ).to_s, persona.matricola, format4)
	indice_riga = indice_riga + 1
	worksheet_obiettivi.merge_range('A' + (indice_riga).to_s + ':B' + (indice_riga ).to_s, 'Qualifica', format4)
	worksheet_obiettivi.merge_range('C' + (indice_riga).to_s + ':E' + (indice_riga ).to_s, persona.qualifica, format4)
	indice_riga = indice_riga + 1
	worksheet_obiettivi.merge_range('A' + (indice_riga).to_s + ':B' + (indice_riga ).to_s, 'Dirigente', format4)
	worksheet_obiettivi.merge_range('C' + (indice_riga).to_s + ':E' + (indice_riga ).to_s, dirigente.nome + " " + dirigente.cognome, format4)
	indice_riga = indice_riga + 1
	
	# worksheet_obiettivi.merge_range('A' + (indice_riga).to_s + ':B' + (indice_riga).to_s, 'Le assenze incidono sul premio (SI/NO)', format4)
	# worksheet_obiettivi.write(indice_riga, 3, 'SI/NO', format3)
	# worksheet_obiettivi.write(indice_riga, 5, persona.totassenze.to_s + "gg/" + persona.totgg.to_s + "gg", format4_right)
	# worksheet_obiettivi.write(indice_riga, 4, (persona.totgg.to_f != 0 ? (100*persona.totassenze.to_f/persona.totgg.to_f).round(2).to_s + "%" : "n.a."), format4_right)
	indice_riga = indice_riga + 1
	
	 	
	indice_riga = indice_riga + 1
	worksheet_obiettivi.write(indice_riga, 0, 'ID', format1)
	worksheet_obiettivi.write(indice_riga, 1, 'Denominazione', format6)
	worksheet_obiettivi.write(indice_riga, 2, 'Tipo', format6)
	worksheet_obiettivi.write(indice_riga, 3, 'Peso', format6)
	worksheet_obiettivi.write(indice_riga, 4, 'Percentuale raggiungimento', format6)
	worksheet_obiettivi.write(indice_riga, 5, 'Valutazione dirigente', format4)
	
	indice_riga = indice_riga + 1
	numero_obiettivi = 0
	numeratore = '(0'
	numeratore_valutazioni = '(0'
	denominatore = '(0'
	result = 0
	
    persona.obiettivi.each do |o|
	  #stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  #worksheet_obiettivi.merge_range(stringa_colonne, o.denominazione, format4)
	  denominazione = o.denominazione_completa 
	  if !o.extrapeg
	   o.indicatori.each do |i| 
		 denominazione = denominazione + "\n" + i.denominazione 
	   end
	  end
	  o.fasi.each do |f| 
		 denominazione = denominazione + "\n" + f.denominazione_completa 
		 f.indicatori.each do |i|
           denominazione = denominazione +  "\n" + i.denominazione 
	     end
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, o.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Obiettivo', format4)
	  ga = GoalAssignment.where(persona: persona, obiettivo: o).first
	  worksheet_obiettivi.write(indice_riga, 3, (ga.wheight != nil ? ga.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (o.valutazione != nil ? (o.valutazione.valore_valutazione_oiv) : 0), format4)
	  # qua ci va la misurazione
	  worksheet_obiettivi.write(indice_riga, 4, (o.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: o).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = o
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # numeratore = numeratore + o.valore_totale * (ga.wheight != nil ? ga.wheight : 0.0)
	  # denominatore = denominatore + (ga.wheight != nil ? ga.wheight : 0.0)
	end
	persona.fasi.each do |f|
	  # stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  # worksheet_obiettivi.merge_range(stringa_colonne, f.denominazione, format4)
	  denominazione = f.obiettivo_operativo_fase.denominazione_completa + "\n"
	  denominazione = denominazione + f.denominazione_completa 
	  f.indicatori.each do |i|
        denominazione = denominazione +  "\n" + i.denominazione.to_s + " " 
	  end
	  f.azioni.each do |a| 
         denominazione = denominazione + "\n" + a.denominazione_completa 
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, f.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Fase', format4)
	  fa = PhaseAssignment.where(persona: persona, fase: f).first
	  worksheet_obiettivi.write(indice_riga, 3, (fa.wheight != nil ? fa.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (f.valutazione != nil ? (f.valutazione.valore_valutazione_oiv) : 0), format4)
	  # qua ci va la misurazione
	  worksheet_obiettivi.write(indice_riga, 4, (f.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: f).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = f
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # 
	  # numeratore = numeratore + f.valore_totale * (fa.wheight != nil ? fa.wheight : 0.0)
	  # denominatore = denominatore + (fa.wheight != nil ? fa.wheight : 0.0)
	end
	
	persona.azioni.each do |a|
	  # stringa_colonne = 'A' + indice_riga.to_s + ':B' + indice_riga.to_s
	  # worksheet_obiettivi.merge_range(stringa_colonne, a.denominazione, format4)
	  denominazione = a.obiettivo_operativo_denominazione_completa + "\n"
	  denominazione = denominazione + a.fase_denominazione_completa + "\n"
	  denominazione = denominazione + a.denominazione_completa
	  a.indicatori.each do |i| 
         denominazione = denominazione + "\n" + i.denominazione.to_s + " "  
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, a.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Azione', format4)
	  saa = SimpleActionAssignment.where(persona: persona, azione: a).first
	  worksheet_obiettivi.write(indice_riga, 3, (saa.wheight != nil ? saa.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (a.valutazione != nil ? (a.valutazione.valore_valutazione_oiv) : 0), format4)
	  worksheet_obiettivi.write(indice_riga, 4, (a.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: a).first
	  
	  
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = a
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  # 
	  # numeratore = numeratore + a.valore_totale * (saa.wheight != nil ? saa.wheight : 0.0)
	  # denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	end
	
	
	persona.opere_assegnate.each do |o|
	  
	  denominazione = o.denominazione_completa + "\n"
	  
	  o.indicatori.each do |i| 
         denominazione = denominazione + "\n" + i.denominazione  
	  end 
	  worksheet_obiettivi.write(indice_riga, 0, o.codice, format1)
	  worksheet_obiettivi.write(indice_riga, 1, denominazione, format4)
	  worksheet_obiettivi.write(indice_riga, 2, 'Opera', format4)
	  opa = OperaAssignment.where(persona: persona, opera: o).first
	  worksheet_obiettivi.write(indice_riga, 3, (opa.wheight != nil ? opa.wheight : 0.0), format4)
	  #worksheet_obiettivi.write(indice_riga, 4, (o.valutazione != nil ? (o.valutazione.valore_valutazione_oiv) : 0), format3)
	  worksheet_obiettivi.write(indice_riga, 4, (o.valore_totale), format4)
	  
	  val = TargetDipendenteEvaluation.where(dipendente: persona, target: o).first
	  if val == nil
	    
	      puts "Creo nuova valutazione target dipendente"
	      val = TargetDipendenteEvaluation.new
	      val.dipendente = persona
	      val.target = o
		  val.dirigente = dirigente
		  val.valore = 0
	      val.save
	  end
	  worksheet_obiettivi.write(indice_riga, 5, (val.valore != nil ? val.valore : 0), format3)
	  
	  indice_riga = indice_riga + 1
	  numero_obiettivi = numero_obiettivi + 1
	  numeratore = numeratore + '+D' + indice_riga.to_s + '*' + 'E' + indice_riga.to_s
	  numeratore_valutazioni = numeratore_valutazioni + '+D' + indice_riga.to_s + '*' + 'F' + indice_riga.to_s
	  denominatore = denominatore + '+D' + indice_riga.to_s
	  
	  
	  # 
	  # numeratore = numeratore + a.valore_totale * (saa.wheight != nil ? saa.wheight : 0.0)
	  # denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	end
	
	numeratore = numeratore + ')'
	numeratore_valutazioni = numeratore_valutazioni + ')'
	denominatore = denominatore + ')'
	worksheet_obiettivi.write(indice_riga + 2, 1, 'Punteggio Finale')
	stringa_espressione = '=' + numeratore + '/' + denominatore
	stringa_espressione_valutazioni = '=' + numeratore_valutazioni + '/' + denominatore+''
	worksheet_obiettivi.write(indice_riga + 2, 4, stringa_espressione)
	worksheet_obiettivi.write(indice_riga + 2, 5, stringa_espressione_valutazioni)
	cella_risultatocomplessivo_obiettivi = cella_risultatocomplessivo_obiettivi + "F" + (indice_riga + 3).to_s
	
	indice_riga = indice_riga+5
	stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	worksheet_obiettivi.write(indice_riga, 0, 'Indicazioni del dirigente:', format4)
	worksheet_obiettivi.merge_range(stringa_merge, persona.indicazioni_miglioramento_prestazione.to_s, format3_wrap)
	indice_riga = indice_riga +1 
	stringa_merge = 'B'+ (indice_riga+1).to_s + ':D' + (indice_riga+1).to_s
	worksheet_obiettivi.write(indice_riga, 0, 'Considerazioni del valutato:', format4)
	worksheet_obiettivi.merge_range(stringa_merge, persona.considerazioni_del_valutato.to_s, format3_wrap)
	
	indice_riga = indice_riga + 3
	stringa = "PUNTEGGIO  TOTALE " + (Setting.where(denominazione: 'anno').first != nil ? Setting.where(denominazione: 'anno').first.value : "-")
	worksheet_obiettivi.merge_range('A'+indice_riga.to_s+':B'+ indice_riga.to_s, stringa, format4)
	moltiplicatore_valutazione_pagella = persona.percentuale_pagella 
	moltiplicatore_valutazione_obiettivi = persona.percentuale_obiettivi
    valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  persona.punteggiofinale  + moltiplicatore_valutazione_obiettivi * persona.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
    stringa = "=(" + moltiplicatore_valutazione_pagella.to_s + "*" + cella_risultatocomplessivo_pagella + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + cella_risultatocomplessivo_obiettivi + ")/(" + moltiplicatore_valutazione_pagella.to_s + "+" + moltiplicatore_valutazione_obiettivi.to_s + ")" 
    worksheet_obiettivi.merge_range('C'+indice_riga.to_s+':D'+ indice_riga.to_s, stringa, format4) 
	
	indice_riga = indice_riga + 2
	worksheet_obiettivi.write(indice_riga, 1, 'Data _____________________________ ', format7firme)
	worksheet_obiettivi.set_row(indice_riga, 30)
	indice_riga = indice_riga + 1
	
	worksheet_obiettivi.write(indice_riga, 1, "Firma del dipendente per presa visione della valutazione assegnata dal dirigente \x0A  \x0A ________________________________", format7firme)
	
	worksheet_obiettivi.set_row(indice_riga, 60)
	indice_riga = indice_riga + 1
	
	return [cella_risultatocomplessivo_pagella, cella_risultatocomplessivo_obiettivi]
 
 end
 
  
 def crea_pagellapdf(person)
 
    titolo = "Valutazione dipendente "
	autore = current_user.cognome + " " + current_user.nome 
	info = {
      Title: titolo,
      Author: autore,
      Subject: 'Valutazione dipendente',
      Keywords: '',
      Creator: 'automatico da Performance',
      Producer: 'Performance',
      CreationDate: Time.now
     } 
	 registra('pagellapdf ' + " " + person.nominativo)
     pdf = Prawn::Document.new(:page_size => 'A4', info: info)

	 pdf.text titolo , :align => :center, :size => 24
	 pdf.move_down 20
	 pdf.text "Dipendente: " + person.cognome + " " + person.nome, :align => :left, :size => 12
	 pdf.text "Matricola: " + person.matricola, :align => :left, :size => 10
	 if person.dirige != nil && uff = person.dirige.first != nil
	    uff = person.dirige.first != nil ? person.dirige.first.nome : " - " 
	 elsif
	    uff = person.ufficio != nil ? person.ufficio.nome : " - "
	 end
	 dirigente = person.dirigente != nil ? person.dirigente.nominativo : "-"
	 pdf.text "Ufficio: " + uff, :align => :left, :size => 10
	 pdf.text "Dirigente: " + dirigente, :align => :left, :size => 10
	 pdf.text "Qualifica: " + (person.qualification != nil ? person.qualification.denominazione :  " - "),  :align => :left, :size => 10
	 pdf.text "Categoria: " + (person.stringa_categoria.to_s),  :align => :left, :size => 10
	 pdf.text "Azienda: " + (Setting.where(denominazione: 'ente').length >0 ?  Setting.where(denominazione: 'ente').first.value : " - "), :align => :left, :size => 10
	 pdf.text (person.assenze_incidono? ? "Le assenze incidono sul premio produttività. Tasso di assenza: " + person.stringa_percentuale_assenze: "Le assenze NON incidono sul premio produttività")
	 pdf.text "Data: " + Time.now.strftime("%d/%m/%Y"), :align => :left, :size => 10
	 
	 pdf.move_down 50
	 
	 	 
	 sottotitolo = [["Fattore di valutazione", "Peso", "Votazione", "Voto pesato"]]
	 t_sottotitolo = pdf.make_table(sottotitolo,:cell_style => { :size => 10, :align => :center}, :width => 490, :column_widths => [330, 40, 60, 60])
	 
	 
	 
	 t_sottotitolo.draw
	 
	 person.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc").each do |v|
	 if v != nil
	    if v.vfactor != nil 
		 denominazione = v.vfactor.denominazione
		else 
		 denominazione = "-"
		end
		if v.vfactor != nil 
		 peso = v.vfactor.peso(person) 
		 massimo = v.vfactor.max
		else 
		 peso =  "-"
		end
	    if v.value != nil 
		 valore = v.value 
		 massimo = v.vfactor.max
		else 
		 valore =  "-"
		end
		
	    
		
	 end
	 cell_denominazione = pdf.make_cell(:content => denominazione)
     cell_peso = pdf.make_cell(:content => peso.to_s)
	 cell_valore_pesato = pdf.make_cell(:content => (valore == 0 ? "_" : (valore*peso/massimo).to_s), :font_style => :bold)
	 cell_valore = pdf.make_cell(:content => (valore == 0 ? "_" : valore.to_s))
     
	 
	 riga = [[ cell_denominazione, cell_peso, cell_valore, cell_valore_pesato ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 8, :align => :center}, :width => 490, :column_widths => [330, 40, 60, 60])

	 t_riga.draw
	 
	 end
	 if Setting.where(denominazione: 'anno').first.value == '2019'
	  cell_denominazione = pdf.make_cell(:content => "Punteggio complessivo")
      cell_peso = pdf.make_cell(:content => " " )
	  cell_valore_pesato = pdf.make_cell(:content => " " )
	  cell_valore = pdf.make_cell(:content => (person.punteggiocomplessivo == 0 ? "_" : person.punteggiocomplessivo.round(2).to_s), :font_style => :bold)
	  riga = [[ cell_denominazione, cell_peso, cell_valore, cell_valore_pesato ]]
	  t_riga = pdf.make_table(riga, :cell_style => { :size => 10, :align => :center}, :width => 490, :column_widths => [330, 40, 60,60])

	  t_riga.draw
	 end
	 
	 cell_denominazione = pdf.make_cell(:content => "Punteggio finale")
     cell_peso = pdf.make_cell(:content => " " )
	 cell_valore = pdf.make_cell(:content => " ")
	 cell_valore_pesato = pdf.make_cell(:content => (person.punteggiofinale == 0 ? "_" : person.punteggiofinale.round(2).to_s), :font_style => :bold)
	 riga = [[ cell_denominazione, cell_peso, cell_valore, cell_valore_pesato ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 10, :align => :center}, :width => 490, :column_widths => [330, 40, 60,60])

	 t_riga.draw
	 
	 
	 	
    pdf.stroke_line [100, 200], [250, 200]
	pdf.stroke_line [350, 200], [500, 200]
	
	pdf.draw_text "(Firma dipendente)", :size => 6, :at => [110, 180]
	
	pdf.draw_text "(Firma dirigente)",  :size => 6, :at => [360, 180]
	
	pdf.move_cursor_to 150
	
	pdf.move_down 20
	pdf.text (person.flag_valutazione_chiusa ? "Valutazione chiusa il " + person.data_chiusura_valutazione.to_s : "Valutazione aperta" ), :align => :left, :size => 6
	pdf.stroke_horizontal_rule
	pdf.move_down 3
	
	descrizione = Setting.where(denominazione: "descrizione_punteggi").first 
    testo = (descrizione != nil ? descrizione.descrizione : " - " )
	testo.each_line do |s| 
       
	    pdf.text s, :align => :left, :size => 6
	   
    end
	
	# pagina degli obiettivi
	pdf.start_new_page
	
	
     titolo = "Valutazione obiettivi "
	 pdf.text titolo , :align => :center, :size => 24
	 pdf.move_down 20
	 pdf.text "Dipendente: " + person.cognome + " " + person.nome, :align => :left, :size => 12
	 pdf.text "Matricola: " + person.matricola, :align => :left, :size => 10
	 if person.dirige != nil && uff = person.dirige.first != nil
	    uff = person.dirige.first != nil ? person.dirige.first.nome : " - " 
	 elsif
	    uff = person.ufficio != nil ? person.ufficio.nome : " - "
	 end
	 dirigente = person.dirigente != nil ? person.dirigente.nominativo : "-"
	 pdf.text "Ufficio: " + uff, :align => :left, :size => 10
	 pdf.text "Dirigente: " + dirigente, :align => :left, :size => 10
	 pdf.text "Qualifica: " + (person.qualification != nil ? person.qualification.denominazione :  " - "),  :align => :left, :size => 10
	 pdf.text "Azienda: " + (Setting.where(denominazione: 'ente').length >0 ?  Setting.where(denominazione: 'ente').first.value : " - "), :align => :left, :size => 10
	 pdf.text (person.flag_assenze_incidono ? "Le assenze incidono sul premio produttività" : "Le assenze NON incidono sul premio produttività")
	 pdf.text "Data: " + Time.now.strftime("%d/%m/%Y"), :align => :left, :size => 10
	 
	 pdf.move_down 50
	 
	 sottotitolo = [["Denominazione obiettivo/fase/azione", "Peso", "Valutazione", "Voto pesato"]]
	 t_sottotitolo = pdf.make_table(sottotitolo,:cell_style => { :size => 10, :align => :center}, :width => 490, :column_widths => [330, 40, 65, 55])
	 
	 peso_totale = 0
	 valore_totale = 0
	 valore_totale_pesato = 0
	 
	 t_sottotitolo.draw
	 
	 person.obiettivi_fasi_azioni_opere.each do |t|
	  denominazione = ""
	  peso = 0
	  valore = 0
	  case t.class.name
	  when "OperationalGoal"
	   ga = GoalAssignment.where(persona: person, obiettivo: t).first
	   peso = ga.wheight
	   val = TargetDipendenteEvaluation.where(dipendente: person, target: t).first
	   valore = (val != nil) ? val.valore : 0
	  when "Phase"
	   fa = PhaseAssignment.where(persona: person, fase: t).first
	   peso = fa.wheight
	   val = TargetDipendenteEvaluation.where(dipendente: person, target: t).first
	   valore = (val != nil) ? val.valore : 0
	  when "SimpleAction" 
	   aa = SimpleActionAssignment.where(persona: person, azione: t).first
	   peso = aa.wheight
	   val = TargetDipendenteEvaluation.where(dipendente: person, target: t).first
	   valore = (val != nil) ? val.valore : 0
	  when "Opera" 
	   opa = OperaAssignment.where(persona: person, opera: t).first
	   peso = opa.wheight
	   val = TargetDipendenteEvaluation.where(dipendente: person, target: t).first
	   valore = (val != nil) ? val.valore : 0
	  else
	   denominazione = ""
	   peso = 0
	   valore = 0
	  end
	  valore_totale = valore_totale + valore
	  peso_totale = peso_totale + peso
	  valore_totale_pesato = valore_totale_pesato + valore * peso
	  
	  
	  cell_denominazione = pdf.make_cell(:content => t.denominazione)
	  
      cell_peso = pdf.make_cell(:content => peso.to_s)
	  cell_valore_pesato = pdf.make_cell(:content => (valore == 0 ? "_" : (valore*peso).to_s), :font_style => :normal)
	  cell_valore = pdf.make_cell(:content => (((valore == 0)|| (peso_totale == 0)) ? "_" : (valore).to_s), :font_style => :normal)
     
	 
	  riga = [[ cell_denominazione, cell_peso, cell_valore, cell_valore_pesato ]]
	  t_riga = pdf.make_table(riga, :cell_style => { :size => 8, :align => :center}, :width => 490, :column_widths => [330, 40, 65, 55])

	  t_riga.draw
	  
	  end
	
	cell_denominazione = pdf.make_cell(:content => "Totale")
	  
    cell_peso_totale = pdf.make_cell(:content => peso_totale.to_s)
	#cell_valore_totale = pdf.make_cell(:content => (valore_totale == 0 ? "_" : (valore_totale).to_s), :font_style => :bold)
	cell_valore_totale = pdf.make_cell(:content => (" "), :font_style => :normal)
	cell_valore_totale_pesato = pdf.make_cell(:content => (peso_totale == 0 ? "_" : ((valore_totale_pesato/peso_totale)).to_s), :font_style => :bold)
     
	 
	riga = [[ cell_denominazione, cell_peso_totale, cell_valore_totale, cell_valore_totale_pesato ]]
	t_riga = pdf.make_table(riga, :cell_style => { :size => 8, :align => :center}, :width => 490, :column_widths => [330, 40, 65, 55])

	 t_riga.draw
	 
	# pagina delle indicazioni
	pdf.start_new_page
	
	
     titolo = ""
	 pdf.text titolo , :align => :center, :size => 24
	 pdf.text "Dipendente: " + person.cognome + " " + person.nome, :align => :left, :size => 12
	 pdf.text "Matricola: " + person.matricola, :align => :left, :size => 10
	 if person.dirige != nil && uff = person.dirige.first != nil
	    uff = person.dirige.first != nil ? person.dirige.first.nome : " - " 
	 elsif
	    uff = person.ufficio != nil ? person.ufficio.nome : " - "
	 end
	 dirigente = person.dirigente != nil ? person.dirigente.nominativo : "-"
	 pdf.text "Ufficio: " + uff, :align => :left, :size => 10
	 pdf.text "Dirigente: " + dirigente, :align => :left, :size => 10
	 pdf.text "Qualifica: " + (person.qualification != nil ? person.qualification.denominazione :  " - "),  :align => :left, :size => 10
	 pdf.text "Azienda: " + (Setting.where(denominazione: 'ente').length >0 ?  Setting.where(denominazione: 'ente').first.value : " - "), :align => :left, :size => 10
	 pdf.text (person.flag_assenze_incidono ? "Le assenze incidono sul premio produttività" : "Le assenze NON incidono sul premio produttività")
	 pdf.text "Data: " + Time.now.strftime("%d/%m/%Y"), :align => :left, :size => 10
	 
	 pdf.move_down 50
	 
	 # riga valutazione complessiva
	 cell_stringa_valutazione_complessiva = pdf.make_cell(:content => "VALUTAZIONE COMPLESSIVA")
	 moltiplicatore_valutazione_pagella = person.percentuale_pagella
	 moltiplicatore_valutazione_obiettivi = person.percentuale_obiettivi
	 #valutazione_complessiva = moltiplicatore_valutazione_pagella *  person.punteggiofinale  + moltiplicatore_valutazione_obiettivi * person.raggiungimento_obiettivi_discretizzato
	 valutazione_complessiva = (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) != 0 ? (moltiplicatore_valutazione_pagella *  person.punteggiofinale  + moltiplicatore_valutazione_obiettivi * person.valutazione_dirigente_obiettivi_fasi_azioni) / (moltiplicatore_valutazione_pagella + moltiplicatore_valutazione_obiettivi ) : 0.0
	 cell_valutazione_complessiva = pdf.make_cell(:content => ("" + moltiplicatore_valutazione_pagella.to_s + "*" +person.punteggiofinale.to_s + " + " + moltiplicatore_valutazione_obiettivi.to_s + "*" + person.valutazione_dirigente_obiettivi_fasi_azioni.to_s + " = " + valutazione_complessiva.round(2).to_s ))
	 riga = [[ cell_stringa_valutazione_complessiva, cell_valutazione_complessiva ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 10, :align => :left}, :width => 490, :column_widths => [200, 290])
	 t_riga.draw
	 
	 cell_stringa_indicazioni = pdf.make_cell(:content => "Indicazioni per il miglioramento della prestazione:")
	 riga = [[ cell_stringa_indicazioni ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 10, :align => :left}, :width => 490, :column_widths => [490])
	 t_riga.draw
	 
	 cell_indicazioni_miglioramento_prestazioni = pdf.make_cell(:content => "" + person.indicazioni_miglioramento_prestazione.to_s)
	 riga = [[ cell_indicazioni_miglioramento_prestazioni ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 8, :align => :left, :height => 130 }, :width => 490, :column_widths => [490])
	 t_riga.draw
	 
	 cell_stringa_considerazioni = pdf.make_cell(:content => "Considerazioni del valutato:")
	 riga = [[ cell_stringa_considerazioni ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 10, :align => :left}, :width => 490, :column_widths => [490])
	 t_riga.draw
	 
	 cell_considerazioni_del_valutato = pdf.make_cell(:content => "" + person.considerazioni_del_valutato.to_s)
	 riga = [[ cell_considerazioni_del_valutato ]]
	 t_riga = pdf.make_table(riga, :cell_style => { :size => 8, :align => :left, :height => 130 }, :width => 490, :column_widths => [490])
	 t_riga.draw
	 
	 pdf.stroke_line [10, 200], [80, 200]
	 pdf.stroke_line [120, 200], [270, 200]
	 pdf.stroke_line [370, 200], [520, 200]
	 
	 pdf.draw_text "(Luogo e Data)", :size => 6, :at => [15, 180]
	
	 pdf.draw_text "(Firma dipendente)", :size => 6, :at => [130, 180]
	
	 pdf.draw_text "(Firma dirigente)",  :size => 6, :at => [380, 180]
	 
     return pdf
 
 end
	
end
