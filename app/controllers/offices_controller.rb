class OfficesController < ApplicationController
  before_action :set_office, only: [:show, :edit, :update, :destroy]
  before_action :check_login

  # GET /offices
  # GET /offices.json
  def index
    @offices = Office.order(:nome)
  end
  
  def indexufficipersone
    @offices = Office.order(:nome)
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
  end

  # GET /offices/new
  def new
    @office = Office.new
  end

  # GET /offices/1/edit
  def edit
  end

  # POST /offices
  # POST /offices.json
  def create
    @office = Office.new(office_params)

    respond_to do |format|
      if @office.save
        format.html { redirect_to @office, notice: 'Office was successfully created.' }
        format.json { render :show, status: :created, location: @office }
      else
        format.html { render :new }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offices/1
  # PATCH/PUT /offices/1.json
  def update
    respond_to do |format|
      if @office.update(office_params)
        format.html { redirect_to @office, notice: 'Office was successfully updated.' }
        format.json { render :show, status: :ok, location: @office }
      else
        format.html { render :edit }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offices/1
  # DELETE /offices/1.json
  def destroy
    @office.destroy
    respond_to do |format|
      format.html { redirect_to offices_url, notice: 'Office was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def getoffice
    puts params
	puts Office.find(params[:office][:office_id]).nome
	@ufficio = Office.find(params[:office][:office_id])
	#@persone = Person.all
	#@uffici = Office.all
	respond_to do |format|
	   format.js   { }
	end
  end
  
  def moveoffice
    puts params
	target = params[:target]
	origin = params[:origin]
	@ufficio = Office.find(params[:office])
	if target.match(/o-\d*/) && origin.match(/o-\d*/)
	#spostamento di ufficio
	 puts "spostamento ufficio " + origin + " to " + target 
	 @ufficio_target = Office.find(target[2, target.length])
	 @ufficio_origine = Office.find(origin[2, origin.length])
	 if (@ufficio_target != nil) && (@ufficio_origine != nil) && (@ufficio_target != @ufficio_origine) && (@ufficio_origine != @ufficio)
	   @ufficio_origine.parent = @ufficio_target
	   @ufficio_origine.save
	 end
	elsif target.match(/o-\d*/) && origin.match(/d-\d*/)
	#spostamento di persona in un ufficio
	 puts "spostamento persona " + origin + " to " + target 
	 @ufficio_target = Office.find(target[2, target.length])
	 @persona = Person.find(origin[2, origin.length])
	 if (@ufficio_target != nil) && (@persona != nil)
	  @persona.ufficio = @ufficio_target
	  @persona.save
	 end
	end 
    respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
  end
  
  def setdirector
    puts "Vediamo i parametri"
	puts params
    puts "director_id           :" + params[:office][:director_id]
	puts "office_id           :" + params[:office_id]
	@ufficio = Office.find(params[:office_id])
	direttore = Person.find(params[:office][:director_id])
	@ufficio.director = direttore
	if @ufficio.office_type != nil
	 if direttore.qualification != QualificationType.where(denominazione: "Segretario").first
	  case @ufficio.office_type.denominazione 
	  when "Servizio" 
         direttore.qualification = QualificationType.where(denominazione: "Dirigente").first
      when "Dipartimento"
  	     direttore.qualification = QualificationType.where(denominazione: "Dirigente").first
	  when "UOrg"
	     direttore.qualification = QualificationType.where(denominazione: "PO").first
	  when "UO"
	     direttore.qualification = QualificationType.where(denominazione: "Preposto").first
      when "US"
	     direttore.qualification = QualificationType.where(denominazione: "Preposto").first
	  end
	 end
	end
	direttore.save
	@ufficio.save
	
	#@persone = Person.order(:cognome)
	respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
	
  end
  
  def removedirectorfromoffice
    puts "Vediamo i parametri"
	puts params
    puts "director_id           :" + params[:office][:director_id]
	puts "office_id           :" + params[:office_id]
	@ufficio = Office.find(params[:office_id])
	@ufficio.director = nil
	@ufficio.save
	
	#@persone = Person.order(:cognome)
	respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
	
  end
  
  def setperson
    # questo aggiunge una persona ad un ufficio e automaticamente lo fa diventare preposto
    puts params
	puts "params[:office][:id] " + params[:office][:id]
	puts "params[:office_id] " + params[:office_id]
    # puts "Ufficio " + Office.find(params[:office_id]).nome
	# puts "Persona " + Person.find(params[:office][:id]).cognome
	@ufficio = Office.find(params[:office_id])
	@p = Person.find(params[:office][:id])
    @p.ufficio = @ufficio
	@p.qualification = QualificationType.where(denominazione: "NonPreposto").first
    @p.save	
	#@persone = Person.order(:cognome)
	respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
    
  end
  
  def removepersonfromoffice
    puts "PARAMS removepersonfromoffice"
    puts params
	@ufficio = Office.find(params[:office_id])
	@p = Person.find(params[:office][:person_id])
	@p.ufficio = nil
	@p.save
	respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
  end
  
  def setparentoffice
    puts params
	puts "params[:office][:id] " + params[:office][:id] + " " + Office.find(params[:office][:id]).nome
	puts "params[:office_id] " + params[:office_id] + " " + Office.find(params[:office_id]).nome
	@ufficio = Office.find(params[:office_id])
	@padre = Office.find(params[:office][:id])
    @ufficio.parent = @padre
    @ufficio.save	
	
	respond_to do |format|
	   format.js    {render :action => "getoffice" }
	end
  
  end
  
  def settype
    puts params
	puts "params[:office][:id] " + params[:office][:id] + " " + OfficeType.find(params[:office][:id]).denominazione
	puts "params[:office_id] " + params[:office_id] + " " + Office.find(params[:office_id]).nome
	@ufficio = Office.find(params[:office_id])
	@tipo = OfficeType.find(params[:office][:id])
	@ufficio.office_type = @tipo
	@ufficio.save
    respond_to do |format|
	   format.js   {render :action => "getoffice" }
	end
  end
  
  def removechildrenfromoffice
    puts params
	
	@ufficio = Office.find(params[:office_id])
	ufficio_figlio = Office.find(params[:office][:office_id])
	ufficio_figlio.parent = nil
	ufficio_figlio.save
    respond_to do |format|
	   format.js   {render :action => "getoffice" }
	end
  end
  
  def stringa_filtro
    puts params
    @stringa_filtro = params[:office][:stringa_filtro]
	@ufficio = Office.find(params[:office][:office_id])
    respond_to do |format|
	   format.js   {render :action => "getoffice" }
	end
  end 
  
  def addchildrentooffice
    puts params
	@stringa_filtro = params[:stringa_filtro]
	@ufficio = Office.find(params[:office_id])
	ufficio_figlio = Office.find(params[:office][:id])
	ufficio_figlio.parent = @ufficio
	ufficio_figlio.save
    respond_to do |format|
	   format.js   {render :action => "getoffice" }
	end
  end
  
  def esporta_peg_xufficio
    @uffici = Office.servizi
  end
  
  def esportazione_peg_xufficio
    puts params
	
	id_servizio = params[:office][:id]
	servizio = Office.find(id_servizio)
	dirigente = servizio.director
	cognome_dirigente = dirigente != nil ? dirigente.cognome : "-"
	data = Time.now.strftime("%d-%m-%Y")
	ente = Setting.where(denominazione: "ente").first != nil ? Setting.where(denominazione: "ente").first.value : "_"
	anno = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : "_"
    nomefile = "Obiettivi_" + cognome_dirigente + "_" + anno + "_" + data + ".xlsx"	
	exfile = WriteXLSX.new(nomefile)
	worksheetObiettivi = exfile.add_worksheet(sheetname = 'Obiettivi')
	worksheetObiettiviIndividuali  = exfile.add_worksheet(sheetname = 'Obiettivi Individuali')
	worksheetAC = exfile.add_worksheet(sheetname = 'AC')
	worksheetACqq = exfile.add_worksheet(sheetname = 'AC quantità - AC qualità')
	
	worksheetPersonale = exfile.add_worksheet(sheetname = 'Personale')
	
	
	format1 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'size': 12,
	'font': 'Franklin Gothic Book',
    'fg_color': '#4F81BD',
	'color': 'white',})
	format1.set_text_wrap(1)
	
	format2 = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': 'white'})
	format2.set_text_wrap(1)
	
	format3 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': 'white'})
	format3.set_text_wrap(1)
	
	format4 = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'center',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': 'white'})
	
	format4.set_text_wrap(1)
	
	formatDipendenti = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': '#A5A5A5'})
	
	formatDipendentiAltro = exfile.add_format({
    'bold': 0,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': 'white'})
	
	formatUffici = exfile.add_format({
    'bold': 1,
    'border': 1,
    'align': 'left',
    'valign': 'vcenter',
	'size': 11,
	'font': 'Franklin Gothic Book',
    'fg_color': '#1F4061'})
	
	
	#
	# FOGLIO OBIETTIVI
	#
	
	worksheetObiettivi.set_column('A:A', 20)
	worksheetObiettivi.set_column('B:B', 40)
	worksheetObiettivi.set_column('C:C', 10)
	worksheetObiettivi.set_column('D:D', 10)
	worksheetObiettivi.set_column('E:E', 10)
	worksheetObiettivi.set_column('F:F', 10)
	worksheetObiettivi.set_column('G:G', 10)
	worksheetObiettivi.set_column('H:H', 10)
	worksheetObiettivi.set_column('L:L', 10)
	worksheetObiettivi.set_column('M:M', 30)
	
		
	nr_riga = 1
	
	worksheetObiettivi.write(nr_riga, 0, "Titolo", format1)
	worksheetObiettivi.write(nr_riga, 1, "Descrizione", format1)
	worksheetObiettivi.write(nr_riga, 2, "Tipo Azione", format1)
	worksheetObiettivi.write(nr_riga, 3, "Struttura Organizzativa", format1)
	worksheetObiettivi.write(nr_riga, 4, "Responsabile", format1)
	worksheetObiettivi.write(nr_riga, 5, "Strutture coinvolte", format1)
	worksheetObiettivi.write(nr_riga, 6, (anno.to_i).to_s, format1)
	worksheetObiettivi.write(nr_riga, 7, (anno.to_i + 1).to_s, format1)
	worksheetObiettivi.write(nr_riga, 8, (anno.to_i + 2).to_s, format1)
	worksheetObiettivi.write(nr_riga, 9, "Peso", format1)
	worksheetObiettivi.write(nr_riga, 10, "Missione", format1)
	worksheetObiettivi.write(nr_riga, 11, "Obiettivo Strategico", format1)
	
	worksheetObiettivi.write(nr_riga, 0, "Titolo", format1)
	worksheetObiettivi.write(nr_riga, 1, "Descrizione", format1)
	worksheetObiettivi.write(nr_riga, 2, "Tipo Azione", format1)
	worksheetObiettivi.write(nr_riga, 3, "Struttura Organizzativa", format1)
	worksheetObiettivi.write(nr_riga, 4, "Responsabile", format1)
	worksheetObiettivi.write(nr_riga, 5, "Strutture coinvolte", format1)
	worksheetObiettivi.write(nr_riga, 6, (anno.to_i).to_s, format1)
	worksheetObiettivi.write(nr_riga, 7, (anno.to_i + 1).to_s, format1)
	worksheetObiettivi.write(nr_riga, 8, (anno.to_i + 2).to_s, format1)
	worksheetObiettivi.write(nr_riga, 9, "Peso", format1)
	worksheetObiettivi.write(nr_riga, 10, "Missione", format1)
	worksheetObiettivi.write(nr_riga, 11, "Obiettivo Strategico", format1)
	
	nr_riga += 1
	
	if dirigente != nil
	
	 worksheetObiettivi.set_column('A:A', 20)
	worksheetObiettivi.set_column('B:B', 40)
	worksheetObiettivi.set_column('C:C', 10)
	worksheetObiettivi.set_column('D:D', 10)
	worksheetObiettivi.set_column('E:E', 10)
	worksheetObiettivi.set_column('F:F', 10)
	worksheetObiettivi.set_column('G:G', 10)
	worksheetObiettivi.set_column('H:H', 10)
	worksheetObiettivi.set_column('L:L', 10)
	worksheetObiettivi.set_column('M:M', 30)
	
	nr_riga = 1
	
	worksheetObiettivi.write(nr_riga, 0, "Titolo", format1)
	worksheetObiettivi.write(nr_riga, 1, "Descrizione", format1)
	worksheetObiettivi.write(nr_riga, 2, "Tipo Azione", format1)
	worksheetObiettivi.write(nr_riga, 3, "Struttura Organizzativa", format1)
	worksheetObiettivi.write(nr_riga, 4, "Responsabile", format1)
	worksheetObiettivi.write(nr_riga, 5, "Strutture coinvolte", format1)
	worksheetObiettivi.write(nr_riga, 6, (anno.to_i).to_s, format1)
	worksheetObiettivi.write(nr_riga, 7, (anno.to_i + 1).to_s, format1)
	worksheetObiettivi.write(nr_riga, 8, (anno.to_i + 2).to_s, format1)
	worksheetObiettivi.write(nr_riga, 9, "Peso", format1)
	worksheetObiettivi.write(nr_riga, 10, "Missione", format1)
	worksheetObiettivi.write(nr_riga, 11, "Obiettivo Strategico", format1)
	
	nr_riga += 1
	
	 dirigente.obiettivi_responsabile.each do |o|
	   if ! o.obiettivo_individuale
	   worksheetObiettivi.write(nr_riga, 0, o.denominazione, format2)
	   worksheetObiettivi.write(nr_riga, 1, o.descrizione, format3)
	   worksheetObiettivi.write(nr_riga, 2, o.tipo, format2)
	   worksheetObiettivi.write(nr_riga, 3, (o.struttura_organizzativa != nil ? o.struttura_organizzativa.nome : ""), format4)
	   worksheetObiettivi.write(nr_riga, 4, dirigente.nominativo2, format4)
	   worksheetObiettivi.write(nr_riga, 6, o.stringa_indicatori, format4)
	   worksheetObiettivi.write(nr_riga, 9, o.indice_strategicita, format4)
	   worksheetObiettivi.write(nr_riga, 10, o.missione.to_s, format4)
	   worksheetObiettivi.write(nr_riga, 11, o.obiettivo_riferimento.to_s, format4)
	   nr_riga += 1
	   
	     o.fasi.each do |f|
		   worksheetObiettivi.write(nr_riga, 0, f.denominazione, format3)
	       worksheetObiettivi.write(nr_riga, 1, f.descrizione, format3)
	       worksheetObiettivi.write(nr_riga, 2, f.tipo, format3)
	       worksheetObiettivi.write(nr_riga, 3, servizio.nome, format4)
	       worksheetObiettivi.write(nr_riga, 4, dirigente.nominativo2, format4)
		   worksheetObiettivi.write(nr_riga, 6, f.stringa_indicatori, format4)
		   worksheetObiettivi.write(nr_riga, 9, f.peso, format4)
		   worksheetObiettivi.write(nr_riga, 10, f.missione.to_s, format4)
	       worksheetObiettivi.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		   nr_riga += 1
		   
		   f.azioni.each do |a|
		     worksheetObiettivi.write(nr_riga, 0, a.denominazione, format3)
	         worksheetObiettivi.write(nr_riga, 1, a.descrizione, format3)
	         worksheetObiettivi.write(nr_riga, 2, a.tipo, format3)
	         worksheetObiettivi.write(nr_riga, 3, servizio.nome, format4)
	         worksheetObiettivi.write(nr_riga, 4, dirigente.nominativo2, format4)
			 worksheetObiettivi.write(nr_riga, 6, a.stringa_indicatori, format4)
			 worksheetObiettivi.write(nr_riga, 9, a.peso, format4)
			 worksheetObiettivi.write(nr_riga, 10, f.missione.to_s, format4)
	         worksheetObiettivi.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		     nr_riga += 1
		   
		   end
		   
		 end
      end
	 end
	
	 #
	 # FOGLIO OBIETTIVI INDIVIDUALI
	 #
	
	worksheetObiettiviIndividuali.set_column('A:A', 20)
	worksheetObiettiviIndividuali.set_column('B:B', 40)
	worksheetObiettiviIndividuali.set_column('C:C', 10)
	worksheetObiettiviIndividuali.set_column('D:D', 10)
	worksheetObiettiviIndividuali.set_column('E:E', 10)
	worksheetObiettiviIndividuali.set_column('F:F', 10)
	worksheetObiettiviIndividuali.set_column('G:G', 10)
	worksheetObiettiviIndividuali.set_column('H:H', 10)
	worksheetObiettiviIndividuali.set_column('L:L', 20)
	worksheetObiettiviIndividuali.set_column('M:M', 40)
	
	nr_riga = 1
	
	worksheetObiettiviIndividuali.write(nr_riga, 0, "Titolo", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 1, "Descrizione", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 2, "Tipo Azione", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 3, "Struttura Organizzativa", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 4, "Responsabile", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 5, "Strutture coinvolte", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 6, (anno.to_i).to_s, format1)
	worksheetObiettiviIndividuali.write(nr_riga, 7, (anno.to_i + 1).to_s, format1)
	worksheetObiettiviIndividuali.write(nr_riga, 8, (anno.to_i + 2).to_s, format1)
	worksheetObiettiviIndividuali.write(nr_riga, 9, "Peso", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 10, "Missione", format1)
	worksheetObiettiviIndividuali.write(nr_riga, 11, "Obiettivo Strategico", format1)
	
	nr_riga += 1
	
	 dirigente.obiettivi_responsabile.each do |o|
	   if o.obiettivo_individuale || !(o.obiettivo_di_gruppo)
	     worksheetObiettiviIndividuali.write(nr_riga, 0, o.denominazione, format2)
	     worksheetObiettiviIndividuali.write(nr_riga, 1, o.descrizione, format3)
	     worksheetObiettiviIndividuali.write(nr_riga, 2, o.tipo, format2)
	     worksheetObiettiviIndividuali.write(nr_riga, 3, (o.struttura_organizzativa != nil ? o.struttura_organizzativa.nome : ""), format4)
	     worksheetObiettiviIndividuali.write(nr_riga, 4, dirigente.nominativo2, format4)
	     worksheetObiettiviIndividuali.write(nr_riga, 6, o.stringa_indicatori, format4)
	     worksheetObiettiviIndividuali.write(nr_riga, 9, o.indice_strategicita, format4)
	     worksheetObiettiviIndividuali.write(nr_riga, 10, o.missione.to_s, format4)
	     worksheetObiettiviIndividuali.write(nr_riga, 11, o.obiettivo_riferimento.to_s, format4)
	     nr_riga += 1
	   
	       o.fasi.each do |f|
		     worksheetObiettiviIndividuali.write(nr_riga, 0, f.denominazione, format3)
	         worksheetObiettiviIndividuali.write(nr_riga, 1, f.descrizione, format3)
	         worksheetObiettiviIndividuali.write(nr_riga, 2, f.tipo, format3)
	         worksheetObiettiviIndividuali.write(nr_riga, 3, servizio.nome, format4)
	         worksheetObiettiviIndividuali.write(nr_riga, 4, dirigente.nominativo2, format4)
		     worksheetObiettiviIndividuali.write(nr_riga, 6, f.stringa_indicatori, format4)
		     worksheetObiettiviIndividuali.write(nr_riga, 9, f.peso, format4)
		     worksheetObiettiviIndividuali.write(nr_riga, 10, f.missione.to_s, format4)
	         worksheetObiettiviIndividuali.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		     nr_riga += 1
		   
		     f.azioni.each do |a|
		       worksheetObiettiviIndividuali.write(nr_riga, 0, a.denominazione, format3)
	           worksheetObiettiviIndividuali.write(nr_riga, 1, a.descrizione, format3)
	           worksheetObiettiviIndividuali.write(nr_riga, 2, a.tipo, format3)
	           worksheetObiettiviIndividuali.write(nr_riga, 3, servizio.nome, format4)
	           worksheetObiettiviIndividuali.write(nr_riga, 4, dirigente.nominativo2, format4)
			   worksheetObiettiviIndividuali.write(nr_riga, 6, a.stringa_indicatori, format4)
			   worksheetObiettiviIndividuali.write(nr_riga, 9, a.peso, format4)
			   worksheetObiettiviIndividuali.write(nr_riga, 10, f.missione.to_s, format4)
	           worksheetObiettiviIndividuali.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		       nr_riga += 1
		   
		     end  #azioni
		   
		   end # fasi
		end # if obiettivi individuali
	   end # obiettivi
	#
	 # FOGLIO OBIETTIVI ATTIVITA ORDINARIA AC (attivita consolidata)
	 #
	
	worksheetAC.set_column('A:A', 20)
	worksheetAC.set_column('B:B', 40)
	worksheetAC.set_column('C:C', 10)
	worksheetAC.set_column('D:D', 10)
	worksheetAC.set_column('E:E', 10)
	worksheetAC.set_column('F:F', 10)
	worksheetAC.set_column('G:G', 10)
	worksheetAC.set_column('H:H', 10)
	worksheetAC.set_column('L:L', 10)
	worksheetAC.set_column('M:M', 30)
	
	nr_riga = 1
	
	worksheetAC.write(nr_riga, 0, "Titolo", format1)
	worksheetAC.write(nr_riga, 1, "Descrizione", format1)
	worksheetAC.write(nr_riga, 2, "Tipo Azione", format1)
	worksheetAC.write(nr_riga, 3, "Struttura Organizzativa", format1)
	worksheetAC.write(nr_riga, 4, "Responsabile", format1)
	worksheetAC.write(nr_riga, 5, "Strutture coinvolte", format1)
	worksheetAC.write(nr_riga, 6, (anno.to_i).to_s, format1)
	worksheetAC.write(nr_riga, 7, (anno.to_i + 1).to_s, format1)
	worksheetAC.write(nr_riga, 8, (anno.to_i + 2).to_s, format1)
	worksheetAC.write(nr_riga, 9, "Peso", format1)
	worksheetAC.write(nr_riga, 10, "Missione", format1)
	worksheetAC.write(nr_riga, 11, "Obiettivo Strategico", format1)
	
	nr_riga += 1
	
	 dirigente.obiettivi_responsabile.each do |o|
	   if o.attivita_ordinaria
	     worksheetAC.write(nr_riga, 0, o.denominazione, format2)
	     worksheetAC.write(nr_riga, 1, o.descrizione, format3)
	     worksheetAC.write(nr_riga, 2, o.tipo, format2)
	     worksheetAC.write(nr_riga, 3, (o.struttura_organizzativa != nil ? o.struttura_organizzativa.nome : ""), format4)
	     worksheetAC.write(nr_riga, 4, dirigente.nominativo2, format4)
	     worksheetAC.write(nr_riga, 6, o.stringa_indicatori, format4)
	     worksheetAC.write(nr_riga, 9, o.indice_strategicita, format4)
	     worksheetAC.write(nr_riga, 10, o.missione.to_s, format4)
	     worksheetAC.write(nr_riga, 11, o.obiettivo_riferimento.to_s, format4)
	     nr_riga += 1
	   
	       o.fasi.each do |f|
		     worksheetAC.write(nr_riga, 0, f.denominazione, format3)
	         worksheetAC.write(nr_riga, 1, f.descrizione, format3)
	         worksheetAC.write(nr_riga, 2, f.tipo, format3)
	         worksheetAC.write(nr_riga, 3, servizio.nome, format4)
	         worksheetAC.write(nr_riga, 4, dirigente.nominativo2, format4)
		     worksheetAC.write(nr_riga, 6, f.stringa_indicatori, format4)
		     worksheetAC.write(nr_riga, 9, f.peso, format4)
		     worksheetAC.write(nr_riga, 10, f.missione.to_s, format4)
	         worksheetAC.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		     nr_riga += 1
		   
		     f.azioni.each do |a|
		       worksheetAC.write(nr_riga, 0, a.denominazione, format3)
	           worksheetAC.write(nr_riga, 1, a.descrizione, format3)
	           worksheetAC.write(nr_riga, 2, a.tipo, format3)
	           worksheetAC.write(nr_riga, 3, servizio.nome, format4)
	           worksheetAC.write(nr_riga, 4, dirigente.nominativo2, format4)
			   worksheetAC.write(nr_riga, 6, a.stringa_indicatori, format4)
			   worksheetAC.write(nr_riga, 9, a.peso, format4)
			   worksheetAC.write(nr_riga, 10, f.missione.to_s, format4)
	           worksheetAC.write(nr_riga, 11, f.obiettivo_riferimento.to_s, format4)
		       nr_riga += 1
		   
		     end  #azioni
		   
		   end # fasi
		end # if obiettivi individuali
	   end # obiettivi
	
	 #
	 # FOGLIO indicatori AC_quantita AC_qualita
	 #
	 worksheetACqq.set_column('A:A', 20)
	 worksheetACqq.set_column('B:B', 40)
	 worksheetACqq.set_column('C:C', 40)
	 worksheetACqq.set_column('D:D', 20)
	 worksheetACqq.set_column('E:E', 20)
	 worksheetACqq.set_column('F:F', 20)
	 worksheetACqq.set_column('G:G', 20)
	 worksheetACqq.set_column('H:H', 20)
	 worksheetACqq.set_column('I:I', 20)
	 worksheetACqq.set_column('J:J', 40)
	 worksheetACqq.set_column('K:K', 60)
	
	 nr_riga = 1
	
	 worksheetACqq.write(nr_riga, 0, "UFFICI", format1)
	 worksheetACqq.write(nr_riga, 1, "LINEA DI ATTIVITA'", format1)
	 worksheetACqq.write(nr_riga, 2, "INDICATORE DI QUALITA'", format1)
	 worksheetACqq.write(nr_riga, 3, "CONSUNTIVO N-3", format1)
	 worksheetACqq.write(nr_riga, 4, "CONSUNTIVO N-2", format1)
	 worksheetACqq.write(nr_riga, 5, "CONSUNTIVO N-1", format1)
	 worksheetACqq.write(nr_riga, 6, "VALORE PREVISIONE " + (anno.to_i).to_s, format1)
	 worksheetACqq.write(nr_riga, 7, "VALORE PREVISIONE " + (anno.to_i + 1).to_s, format1)
	 worksheetACqq.write(nr_riga, 8, "VALORE PREVISIONE " + (anno.to_i + 2).to_s, format1)
	 worksheetACqq.write(nr_riga, 9, "OBIETTIVO PERFORMANCE", format1)
	 worksheetACqq.write(nr_riga, 10, "NOTE", format1)
	 
	
	 nr_riga += 1
	 	 
	 dirigente.indicatori_attivita_consolidata.sort_by{ |iac| iac.ufficio_stringa }.each do |acg|
	  
	  worksheetACqq.write(nr_riga, 0, acg.ufficio_stringa, format3)
	  worksheetACqq.write(nr_riga, 1, acg.linea_di_attivita, format3)
	  worksheetACqq.write(nr_riga, 2, acg.indicatore_di_quantita, format3)
	  worksheetACqq.write(nr_riga, 3, acg.consuntivo_anno_n_meno_3, format3)
	  worksheetACqq.write(nr_riga, 4, acg.consuntivo_anno_n_meno_2, format3)
	  worksheetACqq.write(nr_riga, 5, acg.consuntivo_anno_n_meno_1, format3)
	  worksheetACqq.write(nr_riga, 6, acg.previsionale_anno_n, format3)
	  worksheetACqq.write(nr_riga, 7, acg.previsionale_anno_n_piu_1.to_s, format3)
	  worksheetACqq.write(nr_riga, 8, acg.previsionale_anno_n_piu_2, format3)
	  worksheetACqq.write(nr_riga, 9, (acg.obiettivo_di_performance ? "SI" : "NO"), format3)
	  worksheetACqq.write(nr_riga, 10, acg.note, format3)
	  
	  nr_riga += 1
	  
	 end
	
	 #
	 # FOGLIO PERSONALE
	 #
	 
	 worksheetPersonale.set_column('A:A', 30)
	 worksheetPersonale.set_column('B:B', 35)
	 worksheetPersonale.set_column('C:C', 45)
	 worksheetPersonale.set_column('D:D', 15)
	 worksheetPersonale.set_column('E:E', 15)
	 worksheetPersonale.set_column('F:F', 25)
	
	 nr_riga = 1
	 
	 worksheetPersonale.write(nr_riga, 0, "MATRICOLA", format1)
	 worksheetPersonale.write(nr_riga, 1, "COGNOME E NOME", format1)
	 worksheetPersonale.write(nr_riga, 2, "FIGURA", format1)
	 worksheetPersonale.write(nr_riga, 3, "QUALIFICA", format1)
	 worksheetPersonale.write(nr_riga, 4, "RAPPORTO", format1)
	 worksheetPersonale.write(nr_riga, 5, "NOTE", format1)
	 
	
	 nr_riga += 1
	 
	 worksheetPersonale.write(nr_riga, 0, servizio.nome, format1)
	 worksheetPersonale.write(nr_riga, 1, servizio.nome, format1)
	 
	 nr_riga += 1
	 
	@risultati = []
    dirigente.dirige.each do |s|
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
	
	@risultati.each do |r|
	   worksheetPersonale.merge_range("B"+(nr_riga+1).to_s+":D"+(nr_riga+1).to_s, r[:ufficio].nome, formatUffici)
	   #worksheetPersonale.write(nr_riga, 0, r[:ufficio].nome, formatUffici)
	   #worksheetPersonale.write(nr_riga, 1, r[:ufficio].nome, formatUffici)
	   
	   nr_riga += 1
	   
	   r[:ufficio].dipendenti_ufficio.each do |d|
	     worksheetPersonale.write(nr_riga, 0, d.matricola.upcase, formatDipendenti)
		 worksheetPersonale.write(nr_riga, 1, d.nominativo2.upcase, formatDipendenti)
	     worksheetPersonale.write(nr_riga, 2, d.qualifica, formatDipendentiAltro)
	     worksheetPersonale.write(nr_riga, 3, d.categoria, formatDipendentiAltro)
	     worksheetPersonale.write(nr_riga, 4, d.ruolo, formatDipendentiAltro)
	     worksheetPersonale.write(nr_riga, 5, " ", formatDipendentiAltro)
	   
	     nr_riga += 1
	   end
	
	
	end
	
	
	
	end
	
	
	exfile.close
	send_file nomefile,  :type => "application/vnd.ms-excel", :filename => nomefile, :stream => false
	
  end

  def gestione_ufficio
  
  end

  def gestione_ufficio_operazioni
    
	puts Office.find(params[:office][:office_id]).nome
	@ufficio = Office.find(params[:office][:office_id])
  

    respond_to do |format|
	   format.js    {render :action => "gestione_ufficio" }
    end  
  end
  
  def selected_office
    
	puts params[:padre]
	puts params[:nodo]
	selezionato = params[:nodo]
	@ufficio = nil
	@padre = Office.find(params[:padre])
	codice = selezionato.split("-")[0]
	id = selezionato.split("-")[1]
	case codice
	 when "d"
	  p = Person.find(id)
	  if p != nil
	    @ufficio = p.ufficio
	  end 
	 when "o"
	  @ufficio = Office.find(id)
	 
	
	end
	if @ufficio == nil
	 @ufficio = padre
	end
    puts "Trovato: " + @ufficio.nome

    respond_to do |format|
	   format.js    {render :action => "getoffice" }
    end  
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_office
      @office = Office.find(params[:id])
    end
	
	def check_login
	 if !logged_in? then redirect_to root_url end
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def office_params
      params.require(:office).permit(:nome, :office_type_id, :director_id, :parent_id)
    end
end
