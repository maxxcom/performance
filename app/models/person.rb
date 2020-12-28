class Person < ApplicationRecord
 belongs_to :ufficio, class_name: 'Office', foreign_key: 'office_id',  required: false
 belongs_to :qualification, class_name: 'QualificationType', foreign_key: 'qualification_type_id', required: false 
 has_many :dirige, class_name: 'Office', inverse_of: 'director', foreign_key: 'director_id'
 has_many :valutazioni, class_name: 'Valutation', inverse_of: 'person', foreign_key: 'person_id'
 has_many :obiettivi_responsabile, class_name: 'OperationalGoal', foreign_key: 'responsabile_principale_id', inverse_of: 'responsabile_principale'
 has_many :fasi_responsabile, class_name: 'Phase', foreign_key: 'responsabile_principale_id', inverse_of: 'responsabile_principale'
 has_many :azioni_responsabile, class_name: 'SimpleAction', foreign_key: 'responsabile_principale_id', inverse_of: 'responsabile_principale'
 has_many :other_managers, class_name: 'OtherManager', foreign_key: 'altro_responsabile_id'
 has_many :obiettivi_altro_responsabile,  -> { distinct }, :through => :other_managers, :source => :obiettivo_operativo
 has_many :indicatori_attivita_consolidata, class_name: 'AttivitaConsolidataGauge', foreign_key: 'responsabile_principale_id', inverse_of: 'responsabile_principale'
 
 has_many :goal_assignments, class_name: 'GoalAssignment', foreign_key: 'person_id'
 has_many :phase_assignments, class_name: 'PhaseAssignment', foreign_key: 'person_id'
 has_many :action_assignments, class_name: 'SimpleActionAssignment', foreign_key: 'person_id'
 has_many :obiettivi, -> { distinct }, :through => :goal_assignments, :source => :obiettivo
 has_many :fasi, -> { distinct }, :through => :phase_assignments, :source => :fase
 has_many :azioni, -> { distinct }, :through => :action_assignments, :source => :azione
 has_many :opere, class_name: 'Opera', inverse_of: 'responsabile', foreign_key: 'responsabile_id'
 
 has_many :opera_assignments, class_name: 'OperaAssignment', foreign_key: 'person_id', dependent: :destroy
 has_many :opere_assegnate, -> { distinct }, :through => :opera_assignments, :source => :opera
 
 has_many :deleghe_attive, class_name: 'Delegation', foreign_key: 'delegante_id'
 has_many :delegati, -> { distinct }, :through => :deleghe_attive, :source => :delegato
 
 has_many :deleghe_passive, class_name: 'Delegation', foreign_key: 'delegato_id'
 has_many :deleganti, -> { distinct }, :through => :deleghe_passive, :source => :delegante
 
 has_many :uffici_in_delega_relazione, class_name: 'Delegation', foreign_key: 'delegato_id'
 has_many :uffici_in_delega,  -> { distinct }, :through => :uffici_in_delega_relazione, :source => :ufficio
 
 attr_accessor :reset_token
 has_secure_password
 
 require 'csv'
 
 def password_reset_expired?
    reset_sent_at < 2.hours.ago
 end
 
 def authenticated?
 
    true
 end
 
 def new_token
  SecureRandom.urlsafe_base64
 end
 
 def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
 end
	
 def create_reset_digest
    self.reset_token = new_token
    update_attribute(:reset_digest,  digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
 end
  
 def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
 end
 
 def self.import(file)
    $aggiunte = []
    stringa_filename = file.original_filename
	csv_text = File.read(file.path, liberal_parsing: true)
	dataora = Time.current.strftime("%Y_%m_%d_%I_%M")
	filename = File.basename(stringa_filename) 
	t2 = csv_text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
	t2.gsub!('"', '\'')
	csv = CSV.parse(t2, :headers => true, :col_sep => ';')
	csv.each do |row|
	 matricola = (row[2]).rjust(7,'0')
	 nome = row[1].upcase
	 cognome = row[0].upcase
	 email = row[3]
	 doppi = Person.where(matricola: matricola)
	 if (doppi.length < 1)
	    if Person.create(matricola: matricola,
		                     nome: nome,
							 cognome: cognome,
							 email: email,
							 password: "comune",
							 password_confirmation: "comune",
							 filename_importazione: filename).valid?
		n = Hash.new
		n[:matricola] = matricola
		n[:email] = email
		$aggiunte << n
							 
	    end
	 end
	end
 end
 
 def self.import_csv(file)
    persone_aggiunte = []
	persone_doppie = []
	uffici_nuovi = []
    stringa_filename = file.original_filename
	csv_text = File.read(file.path, liberal_parsing: true)
	dataora = Time.current.strftime("%Y_%m_%d_%I_%M")
	filename = File.basename(stringa_filename) 
	t2 = csv_text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
	t2.gsub!('"', '\'')
	csv = CSV.parse(t2, :headers => true, :col_sep => ';')
	csv.each do |row|
	 matricola = row[0].rjust(7,'0')
	 nome = row[2].upcase
	 cognome = row[1].upcase
	 email = row[3]
	 cat = row[4]
	 cos = row[5]
	  
	 servizio = row[6]
	 uorg = row[7]
	 uff = row[8]
	 nome_ufficio = ''
	 nome_ufficio_padre = ''
	 nome_servizio = ''
	 u = nil
	 if (uff == nil) 
	   nome_ufficio = ''
	   if (uorg == nil)
	     nome_ufficio = ''
	   else
	     nome_ufficio = uorg.sub 'SERV ', 'SERVIZIO '
	   end   
	 elsif (uff.length < 2) 
	   if (uorg != nil)
	    temp = uorg 
	    nome_ufficio = temp.sub 'SERV ', 'SERVIZIO '
		nome_ufficio_padre = servizio.sub 'SERV ', 'SERVIZIO '
	   else 
	    nome_ufficio = ''
	   end
	 else
	   temp = uff
	   nome_ufficio = uff.sub 'SERV ', 'SERVIZIO '
	   nome_ufficio_padre = uorg.sub 'SERV ', 'SERVIZIO '
	   nome_servizio = servizio.sub 'SERV ', 'SERVIZIO '
	 end
	 puts "UFFICIO : " + nome_ufficio
	 nome_ufficio_trimmato = nome_ufficio.delete(' ').delete('.')
	 
	 
	 Office.all.each do |o|
	   temp = o.nome.delete(' ').delete('.')
	   if temp  == nome_ufficio_trimmato
	    u = o
	   end
	 end
	 puts "UFFICIO trovato: " + (u != nil ? u.nome : 'non trovato')
	 # se non l'ho trovato lo aggiungo
	 if (u == nil) && (nome_ufficio.length > 2)
	    if Office.create(nome: nome_ufficio)
		              
	      n = Hash.new
		  n[:nome] = nome_ufficio
		  n[:nome_ufficio_padre] = nome_ufficio_padre
	      uffici_nuovi<< n
		end
	 end
	 # u = Office.where(nome: nome_ufficio).first
	 
	 qualifica = nil
	 if cat.start_with?("DIR")
	    qualifica = QualificationType.where(denominazione: "Dirigente").first
	 end
	 if cat[0] == "A" || cat[0] == "B" || cat[0] == "C" || cat[0] == "D"
	    categoria = cat[0]
		livello = cat[1]
	 end
	 if cat[0] == "P"
	    categoria = cat[0..1]
		livello = cat[2]
	 end 
	
	 doppi = Person.where(matricola: matricola)
	 if (doppi.length < 1)
	     if Person.create(matricola: matricola,
		                     nome: nome,
							 cognome: cognome,
							 email: email,
							 cos: cos,
							 categoria: categoria,
							 ufficio: u,
							 password: "comune",
							 password_confirmation: "comune",
							 filename_importazione: filename).valid?
		  n = Hash.new
		  n[:matricola] = matricola
		  n[:nome] = nome
		  n[:cognome] = cognome
		  n[:email] = email
		  n[:categoria] = categoria
		  n[:cos] = cos
		  n[:ufficio] = (u != nil ? u.nome :  " - ")
		  persone_aggiunte<< n
		  end
		#puts "aggiunti " + 	cognome				 
	
	 else
	    p = doppi.first
		p.cos = cos
		p.categoria = categoria
		p.email = email
		if qualifica != nil 
		    p.qualification = qualifica
		end
		p.ufficio = u
		p.save!
	    n = Hash.new
		n[:matricola] = matricola
		n[:nome] = nome
		n[:cognome] = cognome
		n[:email] = email
		n[:categoria] = categoria
		n[:cos] = cos
		n[:ufficio] = (u != nil ? u.nome :  " - ")
		persone_doppie<< n
		#puts "doppi " + 	cognome	
	 end
	end
	return [persone_aggiunte, persone_doppie, uffici_nuovi]
 end
 
 def self.import_from_peg(file)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	xls.sheets
	
	foglio_personale = xls.sheet('Personale')
	last_row    = foglio_personale.last_row
	@persone = []
	@nontrovate = []
	ufficio = nil
	indice = 0
	condition = (indice < last_row) && (foglio_personale.cell('A',indice)  != 'COGNOME E NOME')
	while condition 
	   indice =  indice + 1
	   condition = (indice < last_row) && (foglio_personale.cell('A',indice)  != 'COGNOME E NOME')
	end
	for row in indice..last_row
	   liste = []
	   p = nil
	   cognome_nome =  foglio_personale.cell('A', row)
	   stringa = foglio_personale.cell('B', row)
	   if stringa != nil
	     stringa_ufficio = stringa.strip
		 stringa_ufficio.gsub! "à", "a'"
	   end
	   u = Office.where('lower(nome) LIKE lower(?)', stringa_ufficio).first
	   if u != nil
	    ufficio = u
		puts "UFFICIO : " + u.nome
	   end
	   
	   if cognome_nome != nil
	    array = cognome_nome.split(' ')
	   
	    if (array.length == 2)
	      lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1])
	      if lista.length == 1
		   p = lista.first
		  end
	    end
	    if (array.length == 3)
	      lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] + " " + array[1], array[2])
		  if lista.length == 1
		   p = lista.first
		  else
		    lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] , array[1] + " " + array[2])
		    if lista.length == 1
		      p = lista.first
		    end
		  end 
	    end
	    if (array.length == 4)
	      lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] + " " + array[1], array[2] + " " + array[3])
		  if lista.length == 1
		   p = lista.first
		  else
		    lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] + " " + array[1] + " " + array[2],  + array[3])
		    if lista.length == 1
		      p = lista.first
		    else 
			  lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1] + " " + array[2] + " " + array[3])
			  if lista.length == 1
		        p = lista.first
			  end
			end 
		  end
	    end
	    if p == nil
	      @nontrovate<< cognome_nome
	    else
		  p.ufficio = ufficio
		  p.save
	      @persone<< {ufficio: ufficio, persona: p}
	    end
      end
	end
	result = [@persone, @nontrovate]
	return result
	
 end
 
 def self.importapagella(file)
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	index = 0
	@Errori = []
	@Importati = []
	#if fogli.length == 2   # faccio il giro dei fogli, se è solo la pagellina va bene lo stesso
	   fogli.each do |name|
        puts name
        sheet = xls.sheet(index)
		 
		 # In A 1
		 # SCHDEA DI VALUTAZIONE
		 # Scheda individuale obiettivi
		if (sheet.cell('A',1) != nil) && (sheet.cell('A',1).strip.upcase.start_with?("SCHEDA")) 
			nominativo  = sheet.cell('C',3)
			puts nominativo 
			m  = sheet.cell('C',4)
			#mtype = sheet.excelx_type(4, 'C')
			#mvalue = sheet.excelx_value(4, 'C')
			#puts mtype 
			#puts mvalue
			#matricola = mvalue.to_s.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
			matricola = m.to_s.chomp('.0').gsub(/[^0-9A-Za-z]/,"").strip.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
			puts "MATRICOLA = " + matricola
			qualifica = sheet.cell('C',5)
			puts qualifica
			
			#controllo correttezza foglio 
			label_nomecognome_foglio_obiettivi = sheet.cell('A',2)
			label_nomecognome = sheet.cell('A',3)
			label_nrmatricola = sheet.cell('A',4)
			label_qualifica = sheet.cell('A',5)
			label_dirigente = sheet.cell('A',7)
			label_titolo = sheet.cell('A',9)
			label_denominazionefattore = sheet.cell('A',11)
			contP = 0
			contO = 0
			if (label_nomecognome != nil) && (label_nomecognome.include? "Nome Cognome")
			   contP += 1
			end
			if (label_nrmatricola != nil) && (label_nrmatricola.include? "Nr Matricola")
			   contP += 1
			end
			if (label_qualifica != nil) && (label_qualifica.include? "Qualifica")
			   contP += 1
			end
			if (label_titolo != nil) && (label_titolo.include? "Valutazione comportamento")
			   contP += 1
			end
			if (label_denominazionefattore != nil) && (label_denominazionefattore.include? "Denominazione Fattore")
			   contP += 1
			end
			
			# controllo se è foglio obiettivi
			# i campi sono spostati di uno
			if (label_nomecognome_foglio_obiettivi != nil) && (label_nomecognome_foglio_obiettivi.include? "Nome Cognome")
			   contO += 1
			end
			if (label_nomecognome != nil) && (label_nomecognome.include? "Nr Matricola")
			   contO += 1
			end
			if (label_nrmatricola != nil) && (label_nrmatricola.include? "Qualifica")
			   contO += 1
			end
			if (label_qualifica != nil) && (label_qualifica.include? "Dirigente")
			   contO += 1
			end
						
			if (contP > 3)
				@p = Person.where(matricola: matricola).first
			end
			
			if (contO > 3)
				m  = sheet.cell('C',3)
				#mtype = sheet.excelx_type(4, 'C')
				#mvalue = sheet.excelx_value(4, 'C')
				#puts mtype 
				#puts mvalue
				#matricola = mvalue.to_s.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
				matricola = m.to_s.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
				puts "MATRICOLA = " + matricola
				@p = Person.where(matricola: matricola).first
			end
			
			if (@p != nil) &&  (contP > 3)
			# pagina valutazione comportamento
			   n_errori = 0;
			   qualifica = (@p.qualification != nil ? @p.qualification.denominazione : "")
			   puts "TROVATA " + @p.nome + " " + @p.cognome + " " + qualifica
			   # se ho generato il file excel allora le valutazioni devono esserci tutte
			   
			   case qualifica # 
			   when "NonPreposto"    #
				 numero_fattori = Vfactor.where("peso_nonpreposti > 0").length
			   when "Preposto"    #
				 numero_fattori = Vfactor.where("peso_preposti > 0").length
			   when "P.O."    #
				 numero_fattori = Vfactor.where("peso_po > 0").length
			   when "Dirigente"    #
				 numero_fattori = Vfactor.where("peso_dirigenti > 0").length
			   when "Segretario"    #
				 numero_fattori = Vfactor.where("peso_sg > 0").length
			   else
				 @Errori<< "Qualifica di " + @p.nome + " " + @p.cognome + " diversa da una di quelle previste"
				 n_errori = n_errori + 1
			   end
				
			   if numero_fattori != @p.valutazioni.length
				 @Errori<< "Persona " + @p.nome + " " + @p.cognome + " con numero fattori di valutazione diversi dai previsti"
				 n_errori = n_errori + 1
			   end
			   
			   lista_valutazioni = @p.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
			   
			   # le valutazioni partono dalla riga 12
			   inizio_righe_valutazioni = 12
			   if n_errori == 0
				(inizio_righe_valutazioni..(inizio_righe_valutazioni+numero_fattori-1)).each do |riga|
				  nn_errori = 0
				  fattore_valutazione = sheet.cell('A',riga)
				  # mtype = sheet.excelx_type(riga, 'A')
				  # mvalue = sheet.excelx_value(riga, 'A')
			   
				  peso_fattore_valutazione =  sheet.cell('B',riga)
				  # mtype = sheet.excelx_type(riga, 'B')
				  # mvalue = sheet.excelx_value(riga, 'B')
			   
				  stringa_voto_fattore_valutazione =  sheet.cell('C',riga)
				  # mtype = sheet.excelx_type(riga, 'C')
				  # mvalue_voto_fattore_valutazione = sheet.excelx_value(riga, 'C').to_f
				  # puts stringa_voto_fattore_valutazione.to_s
				  # puts mtype.to_s
				  # puts mvalue_voto_fattore_valutazione.to_s
				  mvalue_voto_fattore_valutazione = stringa_voto_fattore_valutazione.to_f
							  
				  
				  votopesato_fattore_valutazione =  sheet.cell('D',riga)
				  # mtype = sheet.excelx_type(riga, 'D')
				  # mvalue = sheet.excelx_value(riga, 'D')
				 
				 
				  valutazione = lista_valutazioni[riga - inizio_righe_valutazioni]
				  # conviene confrontare solo lettere alfabetiche e numeri
				  fattore_valutazione_pulito = fattore_valutazione.gsub(/[^0-9A-Za-z]/,"").strip
				  vfactor_denominazione_pulito = valutazione.vfactor.denominazione.gsub(/[^0-9A-Za-z]/,"").strip
				  puts "RIGA " + riga.to_s + " " + (riga - inizio_righe_valutazioni).to_s + " #" + fattore_valutazione + "#  #" + valutazione.vfactor.denominazione + "#"
				  puts "#" + fattore_valutazione_pulito + "#" + vfactor_denominazione_pulito + "#"
				  if !(vfactor_denominazione_pulito.eql? fattore_valutazione_pulito)
					puts "Errore denominazione: #" + valutazione.vfactor.denominazione + "#" + fattore_valutazione + "#" 
					@Errori<< "Errore denominazione: Persona " + @p.nome + " " + @p.cognome + " valutazione non corretta " + fattore_valutazione + " != "  + valutazione.vfactor.denominazione
					nn_errori = nn_errori + 1
				  end
				  if !((mvalue_voto_fattore_valutazione >= valutazione.vfactor.min) && (mvalue_voto_fattore_valutazione <= valutazione.vfactor.max))
					puts "Errore valore: # min: " + valutazione.vfactor.min.to_s + " val: " + mvalue_voto_fattore_valutazione.to_s + " max: " +  valutazione.vfactor.max.to_s 
					@Errori<< "Errore valore:: Persona " + @p.nome + " " + @p.cognome + " # min: " + valutazione.vfactor.min.to_s + " val: " + mvalue_voto_fattore_valutazione.to_s + " max: " +  valutazione.vfactor.max.to_s + " -> fuori dai limiti " 
					nn_errori = nn_errori + 1
				  end
				  puts "nn_errori: " + nn_errori.to_s
				  if nn_errori == 0
					valutazione.value =  mvalue_voto_fattore_valutazione
					valutazione.save!
					@p.save!
					@Importati |= [@p]
					
				  end
				end	
			   end			
			
		 elsif (@p != nil) &&  (contO > 2)
		 #importazione valutazione obiettivi
		 puts "IMPORTAZIONE VALUTAZIONE OBIETTIVI"
		  n_errori = 0
		  inizio_righe_obiettivi = 10
		  n_targets = @p.obiettivi.length + @p.fasi.length + @p.azioni.length
		  (inizio_righe_obiettivi..(inizio_righe_obiettivi+n_targets-1)).each do |riga|
				  nn_errori = 0
				  tipo_da_codice = ""
				  id_da_codice = ""
				  check_tipo = false
				  check_codice = false
				  id_target = sheet.cell('A',riga)
				  mtype = sheet.excelx_type(riga, 'A')
				  id_target_mvalue = sheet.excelx_value(riga, 'A')
				  
				  # il codice è fatto così
				  # OB-00000X
				  #
				  if id_target.length == 9
					tipo_da_codice = id_target[0..1]
					id_da_codice = id_target[3..7]
					check_da_id = id_target[8]
					check_codice = false
					temp = 0
				    id_da_codice.to_s.split('').each do |c|
						temp = (temp + c.to_i)%10
					end
					check_codice = (check_da_id.to_i == temp)
					puts("chack_da_id : " + check_da_id)
					puts("temp : " + temp.to_s)
					puts("result check : " + (check_da_id.to_i == temp).to_s)
				  end
				  
				  denominazione_target = sheet.cell('B',riga)
				  mtype = sheet.excelx_type(riga, 'B')
				  denominazione_mvalue = sheet.excelx_value(riga, 'B')
			   
				  tipo_target =  sheet.cell('C',riga)
				  mtype = sheet.excelx_type(riga, 'C')
				  tipo_target_mvalue = sheet.excelx_value(riga, 'C')
				  check_tipo = false
				  case tipo_target # 
				  when "Obiettivo"    
				   if tipo_da_codice == "OB"
				     check_tipo = true
				   end
				  when "Fase" 
				   if tipo_da_codice == "FA"
				     check_tipo = true
				   end				  
				  when "Azione"
				   if tipo_da_codice == "AZ"
				     check_tipo = true
				   end
				  end
				  
				  peso_target =  sheet.cell('D',riga)
				  mtype = sheet.excelx_type(riga, 'D')
				  peso_target_mvalue = sheet.excelx_value(riga, 'D')
			   
				  valutazione_target =  sheet.cell('F',riga)
				  mtype = sheet.excelx_type(riga, 'F')
				  valutazione_mtarget_mvalue = sheet.excelx_value(riga, 'F')
				  
				  if check_tipo && check_codice
					  case tipo_target # 
					  when "Obiettivo"    #
						 #o = OperationalGoal.where(denominazione: denominazione_mvalue).first
						 o = OperationalGoal.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: o).first
						 if val == nil
						   @Errori<< "Valutazione Obiettivo " + o.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						 end 
					  when "Fase"    #
						 #f = Phase.where(denominazione: denominazione_mvalue).first
						 f = Phase.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: f).first
						 if val == nil
						   @Errori<< "Valutazione Fase " + f.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						 end 
					  when "Azione"    #
						 #a = SimpleAction.where(denominazione: denominazione_mvalue).first
						 a = SimpleAction.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: a).first
						 if val == nil
						   @Errori<< "Valutazione Azione " + a.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						 end 
					  else
						@Errori<< "Tipo target " + @p.nome + " " + @p.cognome + " non riconosciuto: " + tipo_target
						nn_errori = nn_errori + 1
					  end
				end
		  end
		 else # non trovata la persona o scheda non conforme
		   @Errori<< "Scheda non riconosciuto  Fattori conformità scheda: contP=" + contP.to_s + "; contO=" + contO.to_s + "  matricola " + matricola.to_s + " non trovata. P=" + p.to_s + "#"
		 end
			   
		
		
	end # finito foglio
	 index = index + 1
	end
   #end
   return [@Errori, @Importati]
 end
 
 def self.importa_riassuntivo_pagelle_valutazioni(file)
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 2
	result = []
	for row in indice..last_row
	    
	    nome  = sheet.cell('E',row)
		cognome  = sheet.cell('D',row)
		matricola  = sheet.cell('C',row)
		voto_totale = sheet.cell('K',row)
		puts row.to_s
		if matricola != nil
		   
		   m = matricola.to_i.to_s.rjust(7, "0")
		   puts matricola
		   p = Person.where(matricola: m).first
		   if p != nil
		     #puts p.nome + " " + p.cognome + " " + voto_totale.to_s
			 p.valutazione = voto_totale
			 p.flag_calcolo_produttivita = true
			 p.save
			 result<< p
		   end
		   
		end
	end
	return result
 end
 
 def self.setta_assegnazione_ufficio(file)
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 2
	result = []
	ufficio = ""
	for row in indice..last_row
	    
	    nome  = sheet.cell('E',row)
		cognome  = sheet.cell('D',row)
		matricola  = sheet.cell('C',row)
		voto_totale = sheet.cell('K',row)
		puts row.to_s
		if matricola != nil
		   
		   m = matricola.to_i.to_s.rjust(7, "0")
		   puts matricola
		   p = Person.where(matricola: m).first
		   if p != nil
		     # se in D ce la matricola allora non ce lufficio
		     #puts p.nome + " " + p.cognome + " " + voto_totale.to_s
			 #p.valutazione = voto_totale
			 #p.flag_calcolo_produttivita = true
			 p.assegnazione = ufficio
			 p.save
			 result<< p
		  end
		else
		  # se in C non ce la matricola allora in D ce lufficio
			ufficio = cognome
		end
	end
	return result
 end
 
 
 def self.importa_assenze(file, somma_righe)
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 15
	result = []
	for row in indice..last_row
	    
	    
		cognomenome  = sheet.cell('E',row)
		mat  = sheet.cell('D',row)
		if mat != nil
		 matricola = mat.to_s.rjust(7, '0')
		else
		 matricola = nil
		end
		totgg = sheet.cell('H',row)
		totassenze = sheet.cell('I',row)
		if matricola != nil
		   
		   p = Person.where(matricola: matricola).first
		   if p != nil
		     #puts p.nome + " " + p.cognome + " " + voto_totale.to_s
			 if somma_righe 
			   p.totgg = totgg.to_f + (p.totgg != nil ? p.totgg : 0.0)
			   p.totassenze = totassenze.to_f + ( p.totassenze != nil ? p.totassenze : 0.0)
			   p.save
			 else
			   p.totgg = totgg.to_f
			   p.totassenze = totassenze.to_f
			   p.save
			 end
			 result<< p
		   end
		   
		end
	end
	return result
 end
 
 def self.importa_categorie(file)
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 15
	result = []
	for row in indice..last_row
	    
	    
		cognomenome  = sheet.cell('B',row)
		mat  = sheet.cell('A',row)
		if mat != nil
		 matricola = mat.to_s.rjust(7, '0')
		else
		 matricola = nil
		end
		categoria  = sheet.cell('E',row)
		categoria = categoria.strip
		cat = ""
		if categoria.match(/^[A-D]\d/)
		  cat = categoria[0,1]
		elsif categoria.match(/^P[A-C]\d/)
		  cat = categoria[0,2]
		end
		# provo con un altro formato
		if cat == ""
		    c = categoria.upcase.sub("CAT","").sub(".","").sub("PROG","").sub(" ","")
			puts "c = " + c
			if c.match(/^[A-D]\d/)
				cat = c[0,1]
			elsif c.match(/^PL[A-C]\d/)
				cat = c[0,3]
			end
		end
		if matricola != nil
		   
		   p = Person.where(matricola: matricola).first
		   if p != nil
		     puts p.nome + " " + p.cognome + " " + cat
			 p.categoria = cat
			 p.save
			 result<< p
		   end
		   
		end
	end
	return result
 end
 
 def self.importa_servizio_percentuale(file)
 # importa i part time
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(1)
	last_row = sheet.last_row
	indice = 5
	result = []
	scartate = []
	for row in indice..last_row
	    
	    
		nominativo  = sheet.cell('B',row)
		servizio_percentuale  = sheet.cell('E',row)
		p = Person.cerca(nominativo)
		   if p != nil
		     puts p.nome + " " + p.cognome 
			 p.servizio_percentuale = servizio_percentuale
			 
			 p.save
			 result<< p
		   else
		     scartate<< nominativo
		   end
		   
		
	end
	return [result, scartate]
 end
 
 def self.importa_2020(file, sposta_persona, crea_ufficio, solo_prova)
 # importa i part time
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	#sheet = xls.sheet(0)
	 
	
	indice = 1
	result = []
	scartate = []
	aggiunte = []
	diverse = []
	nuovi_uffici = []
	spostati_di_ufficio = []
	fogli.each do |nome_foglio|
	  puts nome_foglio
	  sheet = xls.sheet(nome_foglio)
	  last_row = sheet.last_row
	  for row in indice..last_row
	    
	    matricola_string  = sheet.cell('A',row)
		#puts matricola_string
		matricola = matricola_string.to_i.to_s.rjust(7,"0")
		nominativo  = sheet.cell('B',row)
		ruolo  = sheet.cell('C',row)
		qualifica_desc  = sheet.cell('D',row)
		ufficio  = sheet.cell('F',row)
		ore  = sheet.cell('I',row)
		#puts matricola.to_s + nominativo.to_s
		pm = Person.where(matricola: matricola).first
		if pm != nil 
		   # in A c'è un numero e quindi recupero la persona
		   p = Person.cerca(nominativo)
		   if (p != nil ) && ( p == pm )
		     # perfetto lo trovo anche per nominativo
		     # puts p.nome + " " + p.cognome 
			 uff = Office.cerca(ufficio)
			 if crea_ufficio && (! solo_prova) && uff == nil
			   uff = Office.create(nome: ufficio)
			   nuovi_uffici<< uff
			 end
			 		 
			 if (sposta_persona) && (! solo_prova) && (p.ufficio != uff)
			   p.ufficio = uff
			 end
			 if (sposta_persona) && (p.ufficio != uff)
			  spostati_di_ufficio<< [p, uff, ufficio ]
			 end
			 
			 if ! solo_prova
			   if (ore != nil) && ( ore.to_i < 37 )
			     p.servizio_percentuale = ore.to_i/36
			   end
			   p.categoria = qualifica_desc
			   p.ruolo = ruolo
			   p.save
			 end
			 result<< [p, uff, ufficio ]
		   elsif (p != nil ) && ( p != pm )
		     
			 puts "nominativo diverso " + nominativo.to_s
			 if nominativo.to_s.length < 3 # ha trovato un numero
			   scartate<< nominativo.to_s + " | " + matricola.to_s
			 else # c'è una stringa ma non battono
			   diverse<<  nominativo.to_s + " " + matricola.to_s + " | " + pm.cognome + " " + pm.nome + " " + pm.matricola + " | " + ufficio.to_s 
			 end
		   elsif (p == nil)
            #trovato per matricola non per nominativo
            if qualifica_desc.to_s.include?("cat") ||  (ruolo.to_s.include?("di") || ruolo.to_s.include?("termine") || ruolo.to_s.include?("determinato") || ruolo.to_s.include?("comandato"))# ha la categoria
              diverse<< nominativo.to_s + " " + matricola.to_s + " | " + pm.cognome + " " + pm.nome + " " + pm.matricola
			else # ha i vari campi incoerenti
			  scartate<< nominativo.to_s + " " + matricola.to_s
			end		   
		   end
		else
		  # non la trovo per matricola
          p = Person.cerca(nominativo)
		  if p != nil
		    puts "matricola diversa " + p.matricola + " " + matricola
			diverse<<  p.matricola + " | " + matricola + " | " + ufficio.to_s 
		  else
		  #non la trovo ne per matricola ne per nominativo
		  # se è a posto inserisco la nuova persona
		    if qualifica_desc.to_s.include?("cat") || (ruolo.to_s.include?("di") || ruolo.to_s.include?("termine") || ruolo.to_s.include?("determinato") || ruolo.to_s.include?("comandato"))#ha i campi per essere aggiunto
              cognome = nominativo.split(" ")[0]
			  if (cognome.eql? "DE") || (cognome.eql? "DEL") ||(cognome.eql? "DELLA") || (cognome.eql? "DI") || (cognome.eql? "D'") || (cognome.eql? "LA")
			    cognome = nominativo.split(" ")[0] + " " + nominativo.split(" ")[1]
			  end
			  nome = nominativo.sub(cognome + " ", '')
			  
			  uff = Office.cerca(ufficio)
			  if crea_ufficio && (! solo_prova) && uff == nil
			    uff = Office.create(nome: ufficio)
				nuovi_uffici<< uff
			  end
			  if ! solo_prova 
			      if Person.create(matricola: matricola,
		                     nome: nome,
							 cognome: cognome,
							 email: "",
							 cos: "",
							 categoria: qualifica_desc,
							 ufficio: uff,
							 password: "comune",
							 password_confirmation: "comune",
							 filename_importazione: stringa_filename).valid?
					aggiunte<< nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
				  end
			   else
			   #aggiunte<< nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
				 
			     scartate<< "da aggiungere " + nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
			   end
			  
			else # la riga non sembra essere buona : non ha qualifica e ruolo
			  scartate<< nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
			end # chiusura if else del controllo se la riga è accettabile 
			
          end #chiusura else della ricerca per nominativo
        		  
        end	# chiusura if else ricerca per matricola	
		
	  end #chiusura sulle righe
	end #chiusura ciclo sui fogli
	return [result, scartate, aggiunte, diverse, nuovi_uffici, spostati_di_ufficio]
 end
 
 def self.importa_check_uffici(file, sposta_persona, crea_ufficio, solo_prova)
 # importa i part time
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	#sheet = xls.sheet(0)
	 
	
	indice = 1
	result = []
	scartate = []
	aggiunte = []
	diverse = []
	nuovi_uffici = []
	spostati_di_ufficio = []
	fogli.each do |nome_foglio|
	  puts nome_foglio
	  sheet = xls.sheet(nome_foglio)
	  last_row = sheet.last_row
	  for row in indice..last_row
	    
	    matricola_string  = sheet.cell('A',row)
		#puts matricola_string
		matricola = matricola_string.to_i.to_s.rjust(7,"0")
		cognome  = sheet.cell('B',row)
		nome  = sheet.cell('C',row)
		servizio  = sheet.cell('D',row)
		ufficio  = sheet.cell('E',row)
		nominativo = cognome + " " + nome
		#puts matricola.to_s + nominativo.to_s
		pm = Person.where(matricola: matricola).first
		if pm != nil 
		   # in A c'è un numero e quindi recupero la persona
		   p = Person.cerca(nominativo)
		   if (p != nil ) && ( p == pm )
		     # perfetto lo trovo anche per nominativo
		     # puts p.nome + " " + p.cognome 
			 uff = Office.cerca(ufficio)
			 serv = Office.cerca(servizio)
			 if crea_ufficio && (! solo_prova) && uff == nil
			   uff = Office.create(nome: ufficio)
			   nuovi_uffici<< uff
			 end
			 		 
			 if (sposta_persona) && (! solo_prova) &&  (p.ufficio != uff)
			   p.ufficio = uff
			   p.save
			 end
			 if (sposta_persona) && (p.ufficio != uff)
			  spostati_di_ufficio<< [p, uff, ufficio ]
			 end
			 # non ho trovato l'ufficio ma il servizio è buono
			 # lo sposto nel servizio
			 if (uff == nil) && (serv != nil) && (! solo_prova) && (sposta_persona)
			   p.ufficio = serv
			   p.save
			   spostati_di_ufficio<< [p, uff, ufficio ]
			 end
			 result<< [p, uff, ufficio ]
		   elsif (p != nil ) && ( p != pm )
		     
			 puts "nominativo diverso " + nominativo.to_s
			 if nominativo.to_s.length < 3 # ha trovato un numero
			   scartate<< nominativo.to_s + " | " + matricola.to_s
			 else # c'è una stringa ma non battono
			   diverse<<  nominativo.to_s + " " + matricola.to_s + " | " + pm.cognome + " " + pm.nome + " " + pm.matricola + " | " + ufficio.to_s 
			 end
		   elsif (p == nil)
            #trovato per matricola non per nominativo
            # if qualifica_desc.to_s.include?("cat") ||  (ruolo.to_s.include?("di") || ruolo.to_s.include?("termine") || ruolo.to_s.include?("determinato") || ruolo.to_s.include?("comandato"))# ha la categoria
              # diverse<< nominativo.to_s + " " + matricola.to_s + " | " + pm.cognome + " " + pm.nome + " " + pm.matricola
			# else # ha i vari campi incoerenti
			  # scartate<< nominativo.to_s + " " + matricola.to_s
			# end	
            scartate<< nominativo.to_s + " " + matricola.to_s			
		   end
		else
		  # non la trovo per matricola
          p = Person.cerca(nominativo)
		  if p != nil
		    puts "matricola diversa " + p.matricola + " " + matricola
			diverse<<  p.matricola + " | " + matricola + " | " + ufficio.to_s 
		  else
		  #non la trovo ne per matricola ne per nominativo
		  # se è a posto inserisco la nuova persona
		  
		     uff = Office.cerca(ufficio)
			 serv = Office.cerca(servizio)
		     if ! solo_prova 
			      if Person.create(matricola: matricola,
		                     nome: nome,
							 cognome: cognome,
							 email: "",
							 cos: "",
							 categoria: "",
							 ufficio: uff,
							 password: "comune",
							 password_confirmation: "comune",
							 filename_importazione: stringa_filename).valid?
					aggiunte<< nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
				  else
				  scartate<< nominativo.to_s + " " + matricola.to_s + " | " + ufficio.to_s
				  end
			  end
		    
			  
			
			
          end #chiusura else della ricerca per nominativo
        	   
		
        end	# chiusura if else ricerca per matricola	
		
	  end #chiusura sulle righe
	end #chiusura ciclo sui fogli
	return [result, scartate, aggiunte, diverse, nuovi_uffici, spostati_di_ufficio]
 end
 
 def self.importa_servizio_tempo(file, aggiungi_mancanti, correggi_matricole)
 # importa i part time
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 2
	result = []
	scartate = []
	for row in indice..last_row
	    
	    matricola  = sheet.cell('A',row).rjust(7,'0')
		cognome  = sheet.cell('B',row)
		nome  = sheet.cell('C',row)
		impegno_assoluto  = sheet.cell('E',row)
		impegno_relativo  = sheet.cell('F',row)
		
		servizio_percentuale = impegno_relativo
		if servizio_percentuale > 0
		 tempo = impegno_assoluto / servizio_percentuale
		else
		 tempo = 0.0
		end
		p = Person.cerca(cognome + " " + nome)
		if p != nil
		     puts p.nome + " " + p.cognome 
			 p.servizio_percentuale = servizio_percentuale
			 p.tempo = tempo
			 if correggi_matricole && matricola != nil
			   if p.matricola != matricola
			     lista = Person.where(matricola: matricola)
				 if lista.length == 0
			      p.matricola = matricola
				 else
				  m = lista.first
				  m.matricola = "D" + matricola.last(6)
				  m.save
				  p.matricola = matricola
				 end
			   end
			 end
			 res = p.save
			 if res 
			   result<< p
			 else 
			   scartate<< (cognome + " " + nome)
			 end
		else # non ho trovato quel nominativo
		     if aggiungi_mancanti 
			    lista = Person.where(matricola: matricola)
			    if lista.length == 0
				  puts "MATRICOLA " + matricola
			      # if p = Person.create(matricola: matricola,
		                     # nome: nome,
							 # cognome: cognome,
							 # servizio_percentuale: servizio_percentuale,
							 # tempo: tempo,
							 # password: "comune",
							 # password_confirmation: "comune",
							 # filename_importazione: stringa_filename).valid? 
	                 # result<< p
				  # end	 
				  p = Person.new
				  p.matricola = matricola
		          p.nome = nome
				  p.cognome = cognome
				  p.servizio_percentuale = servizio_percentuale
				  p.tempo = tempo
				  p.password = "comune"
				  p.password_confirmation = "comune"
				  p.filename_importazione = stringa_filename
				  p.save
				  result<< p
			    else
				  m = lista.first
				  m.matricola = "D" + matricola.last(6)
				  m.save
				  if p = Person.create(matricola: matricola,
		                     nome: nome,
							 cognome: cognome,
							 servizio_percentuale: servizio_percentuale,
							 tempo: tempo,
							 password: "comune",
							 password_confirmation: "comune",
							 filename_importazione: stringa_filename).valid? 
	               result<< p
				   end
			    end
			  		 
			  else # aggiungi_mancanti false
		        scartate<< (cognome + " " + nome)
			  end
			    
			
			
		end
		   
		
	end
	return [result, scartate]
 end
 
 def self.importa_dati_generali(file, opzioni)
 # importa i part time
    @modificate = []
	@scartate = []
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	fogli.each do |name|
		foglio = xls.sheet(name)
	    last_row = foglio.last_row
	
		for row in 1..last_row
			matricola = foglio.cell(opzioni['colonna_matricola'], row).to_i.to_s.rjust(7,'0')
			@p = Person.where(matricola: matricola).first
			if @p != nil
			  puts @p.nominativo
			  if opzioni['colonna_qualifica'] != "nessuna"
				#p.qualifica = foglio.cell(opzioni['colonna_qualifica'], row).to_s
			  end
			  if opzioni['colonna_categoria'] != "nessuna"
			  
			    categoria = foglio.cell(opzioni['colonna_categoria'], row).to_s.strip
				cat = ""
				if categoria.match(/^[A-D]\d/)
					cat = categoria[0,1]
				elsif categoria.match(/^P[A-C]\d/)
					cat = categoria[0,2]
				end
				# provo con un altro formato
				if cat == ""
					c = categoria.upcase.sub("CAT","").sub(".","").sub("PROG","").sub(" ","")
					puts "c = " + c
					if c.match(/^[A-D]\d/)
						cat = c[0,1]
					elsif c.match(/^PL[A-C]\d/)
						cat = c[0,3]
					end
				end
				@p.categoria = cat
				
			  end
			  if opzioni['colonna_ruolo'] != "nessuna"
			    @p.ruolo = foglio.cell(opzioni['colonna_ruolo'], row).to_s
			  end
			  if opzioni['colonna_servizio_percentuale'] != "nessuna"
			    puts @p.nominativo + " : " + foglio.cell(opzioni['colonna_servizio_percentuale'], row).to_f.to_s
			    @p.servizio_percentuale = foglio.cell(opzioni['colonna_servizio_percentuale'], row).to_f
			  end
			  if opzioni['note'] != "nessuna"
			    @p.note = foglio.cell(opzioni['colonna_note'], row).to_s
			  end
			  if opzioni['colonna_figura_giuridica'] != "nessuna"
			    @p.figura_giuridica = foglio.cell(opzioni['colonna_figura_giuridica'], row).to_s
			  end
			  @p.save
			  @modificate<< @p
			else
			  riga_scartata = foglio.cell("A", row).to_s + "|" + foglio.cell("B", row).to_s + "|" + foglio.cell("C", row).to_s
			  @scartate<< riga_scartata
			end
	 
		end
		
	end
	
	return [@modificate, @scartate]
 end
 
 def self.importa_raggiungimento_obiettivi(file, colonna_valore)
 # importa i part time
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	fogli = xls.sheets
	sheet = xls.sheet(0)
	last_row = sheet.last_row
	indice = 1
	result = []
	scartate = []
	for row in indice..last_row
	    
	    cognome  = sheet.cell('A',row)
		nome  = sheet.cell('B',row)
		if (cognome != nil) && (nome != nil)
		  raggiungimento_obiettivi  = sheet.cell(colonna_valore,row)
		  p = Person.cerca(cognome + " " + nome)
		    if p != nil && raggiungimento_obiettivi != nil
		      puts p.nome + " " + p.cognome 
		      p.raggiungimento_obiettivi = raggiungimento_obiettivi
			 
			  p.save
			  result<< p
		    else
		      scartate<< sheet.cell('A',row)
		    end
		else
		  scartate<< sheet.cell('A',row)
		end
		   
		
	end
	return [result, scartate]
 end

 def self.importa_analitico(file, opzioni)
 # importa i part time
    @modificate = []
	@aggiunte = []
	@scartate = []
    stringa_filename = file.original_filename
    xls = Roo::Spreadsheet.open(file.path)
	xls.info
	foglio = xls.sheet(0)
	
		
	last_row = foglio.last_row
	
	for row in 1..last_row
		    matricola = foglio.cell('A', row).to_i.to_s.rjust(7,'0')
		    cognome  = foglio.cell('B',row)
		    nome  = foglio.cell('C',row)
			categoria  = foglio.cell('D',row).to_s.strip
			ruolo  = foglio.cell('E',row).to_s
			assegnazione  = foglio.cell('F',row).to_s
			totgg = foglio.cell('G',row).to_f
			totassenze = foglio.cell('H',row).to_f
			tempo = foglio.cell('J',row).to_f
			servizio = foglio.cell('K',row).to_f
			comportamento = foglio.cell('L',row).to_f
			obiettivi = foglio.cell('M',row).to_f
			
			@p = Person.where(matricola: matricola).first
			if @p != nil
			  puts @p.nominativo
			  cat = ""
			  if categoria.match(/^[A-D]/)
					cat = categoria[0,1]			  
			  elsif categoria.match(/^[A-D]\d/)
					cat = categoria[0,1]
			  elsif categoria.match(/^P[A-C]\d/)
					cat = categoria[0,2]
			  end
			  @p.categoria = cat
			  @p.ruolo = ruolo
			  @p.assegnazione = assegnazione
			  @p.servizio_percentuale = servizio
			  @p.tempo = tempo
			  @p.totgg = totgg 
			  @p.totassenze = totassenze
			  @p.raggiungimento_obiettivi = obiettivi
			  @p.valutazione = comportamento
			  @p.flag_calcolo_produttivita = true
			  @p.flag_assenze_incidono = true
			  @p.save
			  @modificate<< @p
			else
			  @p = Person.new
			  @p.matricola = matricola
			  @p.nome = nome
			  @p.cognome = cognome
		      cat = ""
			  if categoria.match(/^[A-D]\d/)
					cat = categoria[0,1]
			  elsif categoria.match(/^P[A-C]\d/)
					cat = categoria[0,2]
			  end
			  @p.categoria = cat
			  @p.ruolo = ruolo
			  @p.assegnazione = assegnazione
			  @p.servizio_percentuale = servizio
			  @p.tempo = tempo
			  @p.totgg = totgg 
			  @p.totassenze = totassenze
			  @p.raggiungimento_obiettivi = obiettivi
			  @p.valutazione = comportamento
			  @p.flag_calcolo_produttivita = true
			  @p.flag_assenze_incidono = true
			  @p.password = "comune"
			  @p.password_confirmation = "comune"
			  @p.save
	          @aggiunte<< @p
			end
		end
		
	
	
	return [@modificate, @scartate, @aggiunte]
 end

 
 def self.dirigenti
    lista1 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Segretario"} )
	lista2 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Dirigente"} )
	lista = lista1 + lista2
	return lista
 end
 
 def dipendenti_sotto
 
  listadipendenti = []
  dirige.each do |o|
      o.dipendenti.each do |p|
	    if p != nil
          listadipendenti |= [p]
		end
      end	
    end
  return listadipendenti
  end
  
  def ricalcola_raggiungimento_obiettivi_dipendenti_sotto
  
    listadipendenti = []
    dirige.each do |o|
      o.dipendenti.each do |p|
	    if p != nil
          listadipendenti |= [p]
		end
      end	
    end
	
	listadipendenti.each do |p|
	  p.raggiungimento_obiettivi = p.valutazione_dirigente_obiettivi_fasi_azioni
	  p.save
	end
  
  end
  
  def ricalcola_valutazione_dipendenti_sotto
  
    listadipendenti = []
    dirige.each do |o|
      o.dipendenti.each do |p|
	    if p != nil
          listadipendenti<< p
		end
      end	
    end
	
	listadipendenti.each do |p|
	  p.valutazione = p.punteggiofinale
	  p.save
	end
  
  end
  
  def self.importa_pesi_target(file, opzione_crea_mancanti)
   # importa i pesi per obiettivi fasi azioni dei dipendenti
       stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	fogli = xls.sheets
	
	@pesi_assegnati = []
	@righe_tralasciate = []
	
	fogli.each do |nome_foglio|
	
	 scheda_obiettivi = xls.sheet(nome_foglio)
	 #controllo alcuni campi che mi aspetto
	 scheda_obiettivi.cell('B',6).include? 'SERVIZIO'
	 last_row    = scheda_obiettivi.last_row
	
	 for row in 9..last_row
		  titolo_obiettivo_completo = scheda_obiettivi.cell('B', row)
		  if titolo_obiettivo_completo != nil
		   #frasi = titolo_obiettivo_completo.split(".")
		   #titolo_obiettivo = frasi[0]
		   titolo_obiettivo = titolo_obiettivo_completo.strip
		  end
		  
		  peso_int = 0
		  dipendente = scheda_obiettivi.cell('C', row)
		  peso = scheda_obiettivi.cell('D', row)
		  descrizione = ""
		  descrizione = scheda_obiettivi.cell('E', row)
		  if descrizione != nil
		    if descrizione.length > 1
		     descrizione = descrizione.strip
			end
		  else
		    descrizione = ""
		  end 
		  if peso != nil 
		   puts "**********" + "peso = " + peso.to_s
		   peso_int = peso
		   if peso.is_a? String
		    if peso.include?("%")
		      peso.sub!("%","")
			  peso_int = peso.to_i
			  puts "**********" + "peso_int = " + peso_int.to_s + "   " +  peso 
		    end
		   elsif peso.respond_to?(:to_f)
		    if peso < 1
		     peso_int = peso * 100
			end
		   elsif peso.respond_to?(:to_i)
		    peso_int = peso.to_i
		   end
			 
		   p = Person.cerca(dipendente)
		   if p != nil
		    puts "Titolo: " + titolo_obiettivo
			puts "Persona: " + p.cognome
		    t = OperationalGoal.cerca(titolo_obiettivo)
		    if  t == nil
			 # non ho trovato obiettivo cerco la fase
		     t = Phase.cerca(titolo_obiettivo)
		     if t != nil
			 #@ho trovato la fase
			  fa = PhaseAssignment.where(phase_id: t.id, person_id: p.id).first
			  if fa != nil
			   fa.wheight = peso_int
			   fa.save
			   ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			   @pesi_assegnati<< ass
			  else
			   t.assegnatari<< p
			   t.save
			   fa = PhaseAssignment.where(phase_id: t.id, person_id: p.id).first
			   if fa != nil
			    fa.wheight = peso_int
			    fa.save
			    ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			    @pesi_assegnati<< ass
			   end
			  end
			 
			 else
			  # non ho trovato ne obiettivo ne fase cerco azione
			  t = SimpleAction.cerca(titolo_obiettivo)
			  if t != nil
			  # ho trovato azione
			  # ho trovato la azione cerco se ha una assegnazione
			  saa = SimpleActionAssignment.where(simple_action_id: t.id, person_id: p.id).first
			    if saa != nil
			       saa.wheight = peso_int
			       saa.save
			       ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			       @pesi_assegnati<< ass
			    else
			       # non ha una assegnazione allora la creo
			       t.assegnatari<< p
			       t.save
			       saa = SimpleActionAssignment.where(simple_action_id: t.id, person_id: p.id).first
			       if saa != nil
			        saa.wheight = peso_int
			        saa.save
				    ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			        @pesi_assegnati<< ass
			       end
			    end
			  else
			  # non ho trovato ne obiettivo ne fase ne azione
			  # cerco nelle opere
			  
			  op = Opera.cerca(titolo_obiettivo)
			  if op != nil
			    opa = OperaAssignment.where(opera_id: op.id, person_id: p.id).first
				if opa != nil
			       opa.wheight = peso_int
			       opa.save
			       ass = { "target" => op.numero, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			       @pesi_assegnati<< ass
			    else
			       # non ha una assegnazione allora la creo
			       op.assegnatari<< p
			       op.save
			       opa = OperaAssignment.where(opera_id: op.id, person_id: p.id).first
			       if opa != nil
			        opa.wheight = peso_int
			        opa.save
				    ass = { "target" => op.numero, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			        @pesi_assegnati<< ass
			       end
			    end
			   else  # anche op è nil
                 record = { "numero" => row, "stringa" => titolo_obiettivo, "causale" => "non trovato target"}
		         @righe_tralasciate<< record
				 if opzione_crea_mancanti
				   puts "CREA OBIETTIVI MANCANTI"
				   # bisogna controllare che non sia una riga farlocca
				   # che abbia un peso settato correttamente
				   # che il dipendente sia giusto
				   # che ci sia un dirigente corretto
				   resp = p.dirigente
				   if p != nil && titolo_obiettivo.length > 5 && peso_int > 0 && resp != nil
				     puts "CREO"
					 puts "Dipendente: " + p.cognome 
					 puts "Obiettivo: " + titolo_obiettivo
					 puts " peso: " + peso_int.to_s
					 @og = OperationalGoal.create(denominazione: titolo_obiettivo,
			                       descrizione: "Importato automaticamente",
								   anno: Setting.where(denominazione: 'anno').first.value,
								   #indice_strategicita: peso,
								   obiettivo_importazione_automatica: true,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   responsabile_principale: resp)
					# creo l'indicatore
					  indicatore = Gauge.new
	                  indicatore.nome = "Avanzamento " + titolo_obiettivo
	                  indicatore.descrizione = "Indicatore automatico avanzamento obiettivo. " + + descrizione
                      indicatore.descrizione_valore_misurazione = "Percentuale avanzamento"
                      indicatore.valore_misurazione = 0.0
	                  indicatore.save
	                  @og.indicatori<<  indicatore
					  @og.save
					# assegno l'obiettivo
					  @og.assegnatari<< p
					  @og.save
					# setto il peso nell'assegnazione
					  ga = GoalAssignment.where(operational_goal_id: @og.id, person_id: p.id).first
					  if ga != nil
			           ga.wheight = peso_int
			           ga.save
					  end
					  ass = { "target" => @og.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			          @pesi_assegnati<< ass
				   end
				   
				 end
               end			   
			  end
			  
			 end
			  
			 
		   else
			 # ho trovato obiettivo
			 # aggiorno il responsabile principale (il dirigente)
			 resp = p.dirigente
			 t.responsabile_principale = resp
			 t.save
		     ga = GoalAssignment.where(operational_goal_id: t.id, person_id: p.id).first
			 
			 if ga != nil
			  ga.wheight = peso_int
			  ga.save
			  ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			  @pesi_assegnati<< ass
			 else
              t.assegnatari<< p
			  t.save
			  ga = GoalAssignment.where(operational_goal_id: t.id, person_id: p.id).first
			  if ga != nil
			   ga.wheight = peso_int
			   ga.save
			   ass = { "target" => t.denominazione, "persona" => p.cognome + " " + p.nome, "peso" => peso_int }
			   @pesi_assegnati<< ass
			  end
             end			 
		end
			
			  
	   else
	     # persona non trovata
		 record = { "numero" => row, "stringa" => dipendente, "causale" => "non trovato dipendente"}
		 @righe_tralasciate<< record
	   end
	  else
	    # colonna D peso non valorizzata
	    record = { "numero" => row, "stringa" => "n.a.", "causale" => "cella D peso non valorizzato"}
	    @righe_tralasciate<< record
	  end
	 end
	end #fine ciclo sui fogli
	return [@pesi_assegnati, @righe_tralasciate]
  
  end
 
 def punteggiocomplessivo
    somma = 0.0
	sommapesi = 0.0
	valutazioni.each do |v| 
	 somma = somma + (v.value != nil ? v.value : 0.0 ) * v.vfactor.peso(self)
	 sommapesi = sommapesi + v.vfactor.peso(self)
	 #puts somma
	 #puts sommapesi
	end 
	(sommapesi != 0) ? (somma/(sommapesi* 1.0 )).round(2) : 0.0
 end
 
 def punteggiofinale
    # punteggio finale della pagella
    somma = 0
	sommapesi = 0
	valutazioni.each do |v| 
	 somma = somma + (v.value != nil ? v.value : 0 ) * 1.0 * (v.vfactor != nil ? v.vfactor.peso(self)/v.vfactor.max : 0.0)
	 sommapesi = sommapesi + (v.vfactor != nil ? v.vfactor.peso(self) : 0.0)
	 #puts somma
	end 
	(sommapesi != 0) ? (100.0*somma/(sommapesi)).round(2) : 0.0
 end
 
 def valutazione_obiettivi_fasi_azioni
    # questa è la misurazione di obiettivi fasi e azioni opere del dirigente per un dipendente
    numeratore = 0
	denominatore = 0
	result = 0
    obiettivi.each do |o|
	  ga = GoalAssignment.where(persona: self, obiettivo: o).first
	  if ga != nil
	   numeratore = numeratore + o.valore_totale * (ga.wheight != nil ? ga.wheight : 0.0)
	   denominatore = denominatore + (ga.wheight != nil ? ga.wheight : 0.0)
	  end
	end
	fasi.each do |f|
	  fa = PhaseAssignment.where(persona: self, fase: f).first
	  if fa != nil
	   numeratore = numeratore + f.valore_totale * (fa.wheight != nil ? fa.wheight : 0.0)
	   denominatore = denominatore + (fa.wheight != nil ? fa.wheight : 0.0)
	  end
	end
	azioni.each do |a|
	  saa = SimpleActionAssignment.where(persona: self, azione: a).first
	  if saa != nil
	   numeratore = numeratore + a.valore_totale * (saa.wheight != nil ? saa.wheight : 0.0)
	   denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	  end
	end
	opere_assegnate.each do |op|
	  opa = OperaAssignment.where(persona: self, opera: op).first
	  if opa != nil
	   numeratore = numeratore + op.valore_totale * (opa.wheight != nil ? opa.wheight : 0.0)
	   denominatore = denominatore + (opa.wheight != nil ? opa.wheight : 0.0)
	  end
	end
	if denominatore != 0
	 result = numeratore/denominatore
	else
	 result = 0
	end
	return result.round(2)
 end
 
 def peso_totale_obiettivi_fasi_azioni
    # questa è la misurazione di obiettivi fasi e azioni opere del dirigente per un dipendente
    
	totale = 0
	
    obiettivi.each do |o|
	  ga = GoalAssignment.where(persona: self, obiettivo: o).first
	  if ga != nil
	   totale = totale + (ga.wheight != nil ? ga.wheight : 0.0)
	   
	  end
	end
	fasi.each do |f|
	  fa = PhaseAssignment.where(persona: self, fase: f).first
	  if fa != nil
	   totale = totale + (fa.wheight != nil ? fa.wheight : 0.0)
	   
	  end
	end
	azioni.each do |a|
	  saa = SimpleActionAssignment.where(persona: self, azione: a).first
	  if saa != nil
	   totale = totale + (saa.wheight != nil ? saa.wheight : 0.0)
	   
	  end
	end
	opere_assegnate.each do |op|
	  opa = OperaAssignment.where(persona: self, opera: op).first
	  if opa != nil
	   totale = totale + (opa.wheight != nil ? opa.wheight : 0.0)
	   
	  end
	end
	
	return totale
 end
 
 def valutazione_dirigente_obiettivi_fasi_azioni
     # questa è la valutazione di obiettivi fasi e azioni oper, del dirigente
	 # per quel particolare dipendente
    numeratore = 0
	denominatore = 0
	result = 0
	# dalla assegnazione si ricava il perso del target per il dipendente
	# dalla valutazion si ricava il valore del target per il dipendente: diverso dalla misurazione
    obiettivi.each do |o|
	  ge = TargetDipendenteEvaluation.where(dipendente: self, target: o).first
	  if ge == nil 
	   valore = 0
	  else
	   valore = ge.valore
	  end
	  ga = GoalAssignment.where(persona: self, obiettivo: o).first
	  if ga != nil
	   numeratore = numeratore + valore * (ga.wheight != nil ? ga.wheight : 0.0)
	   denominatore = denominatore + (ga.wheight != nil ? ga.wheight : 0.0)
	  end
	end
	fasi.each do |f|
	  fe = TargetDipendenteEvaluation.where(dipendente: self, target: f).first
	  if fe == nil 
	   valore = 0
	  else
	   valore = fe.valore
	  end
	  fa = PhaseAssignment.where(persona: self, fase: f).first
	  if fa != nil
	   numeratore = numeratore + valore * (fa.wheight != nil ? fa.wheight : 0.0)
	   denominatore = denominatore + (fa.wheight != nil ? fa.wheight : 0.0)
	  end
	end
	azioni.each do |a|
	  saae = TargetDipendenteEvaluation.where(dipendente: self, target: a).first
	  if saae == nil 
	   valore = 0
	  else
	   valore = saae.valore
	  end
	  saa = SimpleActionAssignment.where(persona: self, azione: a).first
	  if saa != nil
	   numeratore = numeratore + valore * (saa.wheight != nil ? saa.wheight : 0.0)
	   denominatore = denominatore + (saa.wheight != nil ? saa.wheight : 0.0)
	  end
	end
	opere_assegnate.each do |op|
	  ope = TargetDipendenteEvaluation.where(dipendente: self, target: op).first
	  if ope == nil 
	   valore = 0
	  else
	   valore = ope.valore
	  end
	  opa = OperaAssignment.where(persona: self, opera: op).first
	  if opa != nil
	   numeratore = numeratore + valore * (opa.wheight != nil ? opa.wheight : 0.0)
	   denominatore = denominatore + (opa.wheight != nil ? opa.wheight : 0.0)
	  end
	end
	if denominatore != 0
	 result = 1.0*numeratore/denominatore
	else
	 result = 0
	end
	return result.round(2)
 end
 
 def obiettivi_fasi_azioni_opere
     # questa è un array di tutti gli obiettivi, fasi, azioni ed opere
	 # per quel particolare dipendente
    
	result = []
	# dalla assegnazione si ricava il perso del target per il dipendente
	# dalla valutazion si ricava il valore del target per il dipendente: diverso dalla misurazione
    obiettivi.each do |o|
	  result<< o
	end
	fasi.each do |f|
	  result<< f
	end
	azioni.each do |a|
	  result<< a
	end
	opere_assegnate.each do |op|
	  result<< op
	end
	
	return result
 end
 
 def percentuale_obiettivi
    result = 0
	result = ValuationQualificationPercentage.percentuale_obiettivi(self)
	return result
 end
 
 def percentuale_pagella
    result = 0
	result = ValuationQualificationPercentage.percentuale_pagella(self)
	return result
 
 end
 
 
 def cognomenomenospaces
    cognome.gsub(/\s/,'_') + "_" + nome.gsub(/\s/,'_')
 end
 
 def nomeUfficio
    if ufficio != nil
      ufficio.nome
    else
	 if dirige.length != 0
         dirige.first.nome
     else				
        "-" 
     end
    end 
 end
 
 def nomeDirettoreUfficio
  result = ""
  if self.ufficio != nil
    if self.ufficio.director != nil
	   result = self.ufficio.director.nominativo
	end 
  end
 
 end
 
 def qualifica
   if qualification != nil
     qualification.denominazione
   else
     "-" 
   end 
 end
 
 def nominativo
      nome + " " + cognome
 end
 
 def nominativo2
      cognome + " " + nome
 end
 
 def matricola_nominativo2
      matricola + " " + cognome + " " + nome
 end
 
 def self.cerca(stringa)
   # in inputo la stringa cognome spazio nome
   # in output un solo elemento (eventualmente nil)
   # in caso di omonimie ritorna sempre il primo
   # 
   
   p = nil
   if (stringa != nil) && (stringa.length > 2)
    nominativo = stringa.strip.upcase
    
    array = nominativo.split(' ')
	    if (array.length == 1)
		  lista = Person.where('cognome LIKE ?', array[0])
		  if (lista.length == 1)
			p = lista.first
		  end
		end
	    if (array.length == 2)
	      lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1], array[0])
	      if (lista.length == 1)
		   p = lista.first
		  else 
		   lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1])
		   if (lista.length > 0)
		    p = lista.first
		   end
		  end
		  if (p == nil)
		    lista = Person.where('cognome LIKE ? ', array[0] + " " + array[1])
			if (lista.length == 1)
		      p = lista.first
		    end 
		  end 
	    end
	    if (array.length == 3)
	      if (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1] + " " + array[2], array[0])).length > 0
		    p = lista.first
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[1] + " " + array[2], array[0])).length > 0
		    p = lista.first
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] + " " + array[1], array[2])).length > 0
		    p = lista.first
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[0] + " " + array[1], array[2])).length > 0
		    p = lista.first
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[0], array[1] + " " + array[2])).length > 0
		   p = lista.first
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1] + " " + array[2])).length > 0
		   p = lista.first 
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[2] + " " + array[1])).length > 0
		   p = lista.first
		  end 
	    end
	    if (array.length == 4)
	      
		  if (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[2] + " " + array[3], array[0] + " " + array[1])).length > 0
		   p = lista.first
		  elsif  (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1] + " " + array[2] + " " + array[3],   array[0])).length > 0
		   p = lista.first
		  elsif  (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[3], array[0] + " " + array[1] + " " + array[2])).length > 0
		   p = lista.first
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[2] + " " + array[3], array[0] + " " + array[1])).length > 0
		   p = lista.first
		  elsif  (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[1] + " " + array[2] + " " + array[3],   array[0])).length > 0
		   p = lista.first
		  elsif  (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[3], array[0] + " " + array[1] + " " + array[2])).length > 0
		   p = lista.first
		  end
			  
		
	    end
   end	
   return p	
	
 end
 
 def self.cerca_dirigente(stringa)
   # in inputo la stringa cognome spazio nome, o solo cognome
   # in output un solo elemento (eventualmente nil)
   # in caso di omonimie ritorna sempre il primo
   # cerca solo tra i dirigenti
   
   p = nil
   dipendenti = []
   if ((stringa != nil) && (stringa.length > 3))
    nominativo = stringa.strip.upcase
    array = nominativo.split(' ')
	
	Person.where('lower(cognome) = lower(?)', nominativo).each do |d|
	 dipendenti<< d
	end
	
	if (array.length == 1)
	  lista = Person.where('cognome LIKE ?', array[0])
	  lista.each do |d|
	   dipendenti<< d
	  end
	end
	
    if (array.length == 2)
	      lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1], array[0])
		  lista.each do |d|
	        dipendenti<< d
	      end
		  lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1])
		  lista.each do |d|
	        dipendenti<< d
	      end
	      		  
	end
	if (array.length == 3)
	      if (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1] + " " + array[2], array[0])).length > 0
		    lista.each do |d|
	          dipendenti<< d
	        end
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[1] + " " + array[2], array[0])).length > 0
		    lista.each do |d|
	          dipendenti<< d
	        end
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0] + " " + array[1], array[2])).length > 0
		    lista.each do |d|
	          dipendenti<< d
	        end
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[0] + " " + array[1], array[2])).length > 0
		    lista.each do |d|
	          dipendenti<< d
	        end
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[0], array[1] + " " + array[2])).length > 0
		   lista.each do |d|
	          dipendenti<< d
	       end
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[1] + " " + array[2])).length > 0
		   lista.each do |d|
	          dipendenti<< d
	       end
		  elsif (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[0], array[2] + " " + array[1])).length > 0
		   lista.each do |d|
	          dipendenti<< d
	       end
		  end 
	 end
	 if (array.length == 4)
	      
		  if (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[2] + " " + array[3], array[0] + " " + array[1])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
		  elsif  (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[1] + " " + array[2] + " " + array[3],   array[0])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
		  elsif  (lista = Person.where('cognome LIKE ? and nome LIKE ?', array[3], array[0] + " " + array[1] + " " + array[2])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
		  elsif (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[2] + " " + array[3], array[0] + " " + array[1])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
		  elsif  (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[1] + " " + array[2] + " " + array[3],   array[0])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
		  elsif  (lista = Person.where('nome LIKE ? and cognome LIKE ?', array[3], array[0] + " " + array[1] + " " + array[2])).length > 0
		   lista.each do |d|
	         dipendenti<< d
	       end
	     end
    end	
   
   qualificaDirigente = [QualificationType.where(denominazione: 'Dirigente').first , QualificationType.where(denominazione: 'Segretario').first]
   dipendenti.each do |d|
    if  qualificaDirigente.include?(d.qualification)
	 p = d 
	end
   end
   end
   return p	
	
 end
 
 def raggiungimento_obiettivi_discretizzato
    risultato = 0
    if raggiungimento_obiettivi != nil
      if raggiungimento_obiettivi < 60 && raggiungimento_obiettivi > 0
	    risultato = 40
	  elsif raggiungimento_obiettivi >= 60 && raggiungimento_obiettivi < 75
	    risultato = 60
	  elsif raggiungimento_obiettivi >= 75 && raggiungimento_obiettivi < 90
	    risultato = 80
	  elsif raggiungimento_obiettivi >= 90
	    risultato = 100
	  end
	else
	  risultato = 0
	end
    return risultato
 end
 
 def target_array
    target_array = []
	obiettivi_responsabile.sort_by{|p| p.denominazione}.each do |o|
      target_array<< o
    end
    fasi_responsabile.sort_by{|p| p.denominazione}.each do |f|
      target_array<< f
    end
	azioni_responsabile.sort_by{|p| p.denominazione}.each do |a|
      target_array<< a
    end
	
	opere.sort_by{|p| p.numero}.each do |o|
      target_array<< o
    end
	
	return target_array
 end
 
 def target_array_select(x)
  # ritorna solo obiettivi o solo fasi o azioni o opere
    target_array = []
	if x.eql? "o"
	 
	 obiettivi_responsabile.sort_by{|p| p.denominazione}.each do |o|
       target_array<< o
     end
	end
	if x.eql? "f"
	 
     fasi_responsabile.sort_by{|p| p.denominazione}.each do |f|
      target_array<< f
     end
	end
	if x.eql? "a"
	 
	 azioni_responsabile.sort_by{|p| p.denominazione}.each do |a|
       target_array<< a
     end
	end
	if x.eql? "p"
	 
	 opere.sort_by{|p| p.numero}.each do |o|
       target_array<< o
     end
	end
	
	# se sel vuoto metto tutto
	if x.eql? ""
	 obiettivi_responsabile.sort_by{|p| p.denominazione}.each do |o|
      target_array<< o
     end
     fasi_responsabile.sort_by{|p| p.denominazione}.each do |f|
      target_array<< f
     end
	 azioni_responsabile.sort_by{|p| p.denominazione}.each do |a|
      target_array<< a
     end
	
	 opere.sort_by{|p| p.numero}.each do |o|
       target_array<< o
     end
	end
	
	return target_array
 end
 
 def opere_array
    opere_array = []
		
	opere.each do |o|
      opere_array<< o
    end
	
	return opere_array
 end
 
 def numero_target_assegnati
  result = 0
  result = obiettivi.length + fasi.length + azioni.length + opere.length + opere_assegnate.length
  return result
 end
 
 def totale_pesi_target_assegnati
  result = 0
  
  obiettivi.each do |o|
   result = result + (GoalAssignment.where(persona: self, obiettivo: o).first != nil ? GoalAssignment.where(persona: self, obiettivo: o).first.wheight.to_i() : 0)
  end
  fasi.each do |f|
   result = result + (PhaseAssignment.where(persona: self, fase: f).first != nil ? PhaseAssignment.where(persona: self, fase: f).first.wheight.to_i() : 0)
  end
  azioni.each do |a|
   result = result + (SimpleActionAssignment.where(persona: self, azione: a).first != nil ? SimpleActionAssignment.where(persona: self, azione: a).first.wheight.to_i() : 0)
  end
  opere.each do |op|
   result = result + (OperaAssignment.where(persona: self, opera: op).first != nil ? OperaAssignment.where(persona: self, opera: op).first.wheight.to_i() : 0)
  end
  opere_assegnate.each do |op|
   result = result + (OperaAssignment.where(persona: self, opera: op).first != nil ? OperaAssignment.where(persona: self, opera: op).first.wheight.to_i() : 0)
  end
  
  return result
 end
 
 def dirigente
    # trova il dirigente di un dipendente
    dir = nil
	servizio = nil
	ufficio_partenza =  nil
	if ufficio != nil
	  ufficio_partenza = ufficio
	end 
	if dirige != nil && dirige.length > 0
	 ufficio_partenza = dirige.first
	end
	if ufficio_partenza != nil
	 servizio = ufficio_partenza
     padre = servizio.parent
	 while padre != nil
	   servizio = padre
	   padre = servizio.parent
	   #puts "ciclo"
	 end
	 dir = servizio.director
	end
	return dir
 end
 
 def punteggio_finale_totale
    risultato = (self.raggiungimento_obiettivi.to_f * self.percentuale_obiettivi + self.percentuale_pagella * self.valutazione.to_f)/(self.percentuale_obiettivi + self.percentuale_pagella)
 end
 
 def punteggio_finale_totale_discretizzato
    risultato = 0
    risultato = (self.raggiungimento_obiettivi.to_f * self.percentuale_obiettivi + self.percentuale_pagella * self.valutazione.to_f)/(self.percentuale_obiettivi + self.percentuale_pagella)
   
      if risultato < 50 
	    risultato = 0
	  elsif risultato >= 50 && risultato < 70
	    risultato = 60
	  elsif risultato >= 70 && risultato < 90
	    risultato = 80
	  elsif risultato >= 90
	    risultato = 100
	  end
	
    return risultato
 
 end
 
 def livello_premiale
    return self.punteggio_finale_totale_discretizzato
 end
 
 def premialita_effettiva
    result = 0.0
    premialita = self.livello_premiale
	case premialita
	when 0
	  result = 0.0
	when 60
	  result = 0.60
	when 80
	  result = 0.80
	when 100
	  result = 1.0
	else
	  result = 0
	end
    return result
 end
 
 def denominazione
      nome + " " + cognome
 end
 
 def categoria_char
   reasult = ""
   cat = categoria
   if cat != nil 
    if cat.length == 1
      result = cat
    end
    if cat.match(/[ABCD]\d/)
      result = cat.match(/[ABCD]\d/)[0][0]
    end
   end
   return  result
 end 
 
 def categoria_ABCD
   result = ""
   abc = ""
   cat = categoria
   if cat != nil 
    if cat.length == 1
      result = cat
    end
    if cat.match(/[ABCD]\d/)
      result = cat.match(/[ABCD]\d/)[0][0]
    end
	if cat.match(/PL[ABCD]/)
      abc = cat.match(/PL[ABCD]/)[0][2]
	  # PLS e PLC in Comune di Udine non esistono
	  if abc == "S"                         
	   result = "B"
	  elsif abc == "A"
	   result = "C"
	  elsif abc == "B" || abc == "C"
	   result = "D"
	  end
    end
   end
   return  result
 end 
 
 def stringa_categoria
    result = ""
    if categoria_formale != nil
       result = categoria_formale.to_s + "*"
    else
       result = categoria.to_s
    end
    return result	
 
 end
 
 def stringa_percentuale_assenze
    result = ""
	result = totassenze.to_s + "/" + totgg.to_s
	return result
 end
 
 def assenze_incidono_abilitato?
    result = true
	if ((totgg != nil) && (totassenze != nil))
		if totgg > 0
			result = ((totassenze / totgg) > 0.2) && !flag_valutazione_chiusa
		else
			result = !flag_valutazione_chiusa
		end
    end
	return result
 end
 
 def assenze_incidono?
    result = true
	if ((totgg != nil) && (totassenze != nil) && (flag_assenze_incidono != nil))
		if totgg > 0
			result = ((totassenze / totgg) > 0.2) && flag_assenze_incidono
		else
			result = false
		end
    else
	   result = false
	end
	return result
 end
 
 def char_flag_valutazione_chiusa
    result = ""
	result = flag_valutazione_chiusa ? result = "C" : results = "A"
	return result
 end
 
 def percentuale_riduzione_per_assenze
    result = 0
	if  (totgg != nil) && totassenze != nil
	 if totgg != 0
	   percentuale = totassenze/totgg
	   if percentuale > 0.20 &&  percentuale <= 0.40
	     result = 0.30
	   elsif percentuale > 0.40 &&  percentuale <= 0.75
	     result = 0.50
	   elsif percentuale > 0.75 &&  percentuale <= 1.00
	     result = 0.850
	   elsif percentuale == 1
	     result = 1.0
	   end
		
	 end
	end
	return result
 end
 
 def check_valutazioni
   if qualification != nil
    tipo = qualification.denominazione
    case tipo
    when "Dirigente"
     fattori = Vfactor.where('peso_dirigenti > 0')
	when "Segretario"
     fattori = Vfactor.where('peso_sg > 0')
    when "P.O."
     fattori = Vfactor.where('peso_po > 0')
    when "Preposto"
     fattori = Vfactor.where('peso_preposti > 0')
    when "NonPreposto"
     fattori = Vfactor.where('peso_nonpreposti > 0')
	else
	 fattori = Vfactor.where(false) # in modo da avere nulla
    end
	# check se è coerente 
	valutazioni.each do |v|
	 # cancello se ha un puntatore a nil
	 if v.vfactor == nil
	  v.destroy
	  save
	 end
	 # per ogni valutazione controllo se è coerente con la qualifica
	 # quelle che non sono coerenti le cancello (potrebbe essere cambiata la qualifica)
	 if v.vfactor != nil
	  tipo = qualification.denominazione
      case tipo
      when "Dirigente"
	   if v.vfactor.peso_dirigenti <= 0
	    v.destroy
	    save
	   end 
	  when "Segretario"
       if v.vfactor.peso_sg <= 0
	    v.destroy
	    save
	   end 
      when "P.O."
	   if v.vfactor.peso_po <= 0
	    v.destroy
	    save
	   end 
      when "Preposto"
	   if v.vfactor.peso_preposti <= 0
	    v.destroy
	    save
	   end 
      when "NonPreposto"
       if v.vfactor.peso_nonpreposti <= 0
	    v.destroy
	    save
	   end
     end
	end
	 
	end
	
	# se non esiste valutazione mette valore zero
    if (valutazioni == nil) || (valutazioni.length != fattori.length)
	  fattori.order("ordine_apparizione asc").each do |f|
	    if valutazioni.where(vfactor: f).length == 0
	      v = Valutation.new
	      
	      v.vfactor = f
		  v.state = "open"
	      v.value = 0
	      v.year = Setting.where(denominazione: "anno").first != nil ? Setting.where(denominazione: "anno").first.value : ' - '
	      v.save
		  valutazioni<< v
		  save
	    end  
	   end
	 end
	 
	 
	
   end # if della qualification != nil
  
 end
 
 def self.importa_pagelle_obiettivi(file)
  # importa il riassuntivo di pagelle + obiettivi
  risultato = []
  stringhe_errori = []
  stringa_filename = file.original_filename
  extension = 'xls'
  xls = Roo::Spreadsheet.open(file.path)
  informazioni = xls.info
  fogli = xls.sheets
  fogli.each do |name|
        puts name
        sheet = xls.sheet(name)
		row = 1
		last_row = sheet.last_row
		while row < last_row
			if (sheet.cell('A',row) != nil) && (sheet.cell('A',row).to_s.strip.upcase.start_with?("SCHEDA"))
				if sheet.cell('A',row).strip.upcase.eql?("SCHEDA DI VALUTAZIONE INDIVIDUALE - AREA COMPORTAMENTALE")
					res = leggi_scheda_valutazione_comportamento(sheet, row)
					importati = res[0]
					importati.each do |p|
					 risultato<< p
					end
					errori = res[1]
					errori.each do |p|
					 stringhe_errori<< p
					end
					
		            row = row + 30
				elsif sheet.cell('A',row).to_s.strip.upcase.eql?("SCHEDA DI VALUTAZIONE INDIVIDUALE - VALUTAZIONE OBIETTIVI")
					res = leggi_scheda_valutazione_obiettivi(sheet, row)
					importati = res[0]
					importati.each do |p|
					 risultato<< p
					end
					errori = res[1]
					errori.each do |p|
					 stringhe_errori<< p
					end
		            row = row + 10
				end
		    	
			end  # if sheet A,1 != nil
			row = row + 1
		end #whilw
 
  end
  
  return [risultato, stringhe_errori]
 
 end
 
 
 private
 def downcase_email
      self.email = email.downcase
 end
 
 def nomecognome
      nome + " " + cognome
 end
 
 def cognomenome
      cognome + " " + nome
 end
 
 def self.leggi_scheda_valutazione_comportamento(sheet, row)
    puts "leggi_scheda_valutazione_comportamento"
	risultato = []
	@Errori = []
	
	nominativo  = sheet.cell('C',row + 2)
	puts nominativo 
	m  = sheet.cell('C',row + 3)
			#mtype = sheet.excelx_type(4, 'C')
			#mvalue = sheet.excelx_value(4, 'C')
			#puts mtype 
			#puts mvalue
			#matricola = mvalue.to_s.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
	matricola = m.to_s.chomp('.0').gsub(/[^0-9A-Za-z]/,"").strip.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
	puts "MATRICOLA = " + matricola
	qualifica = sheet.cell('C',row + 4)
	puts qualifica
			
	#controllo correttezza foglio 
	
	label_nomecognome = sheet.cell('A',row + 2)
	label_nrmatricola = sheet.cell('A',row + 3)
	label_qualifica = sheet.cell('A',row + 4)
	label_dirigente = sheet.cell('A',row + 6)
	label_titolo = sheet.cell('A',row + 8)
	label_denominazionefattore = sheet.cell('A',row + 10)
	contP = 0
	if (label_nomecognome != nil) && (label_nomecognome.include? "Nome Cognome")
	   contP += 1
	end
	if (label_nrmatricola != nil) && (label_nrmatricola.include? "Nr Matricola")
	   contP += 1
	end
	if (label_qualifica != nil) && (label_qualifica.include? "Qualifica")
	   contP += 1
	end
	if (label_titolo != nil) && (label_titolo.include? "Valutazione comportamento")
	   contP += 1
	end
	if (label_denominazionefattore != nil) && (label_denominazionefattore.include? "Denominazione Fattore")
	   contP += 1
	end
			
	if (contP > 3)
		@p = Person.where(matricola: matricola).first
	end
	
	if (@p != nil) &&  (contP > 3)
		# pagina valutazione comportamento
		n_errori = 0;
		qualifica = (@p.qualification != nil ? @p.qualification.denominazione : "")
		puts "TROVATA " + @p.nome + " " + @p.cognome + " " + qualifica
		# se ho generato il file excel allora le valutazioni devono esserci tutte
			   
		case qualifica # 
		when "NonPreposto"    #
			 numero_fattori = Vfactor.where("peso_nonpreposti > 0").length
		when "Preposto"    #
			 numero_fattori = Vfactor.where("peso_preposti > 0").length
		when "P.O."    #
			 numero_fattori = Vfactor.where("peso_po > 0").length
		when "Dirigente"    #
			 numero_fattori = Vfactor.where("peso_dirigenti > 0").length
		when "Segretario"    #
			 numero_fattori = Vfactor.where("peso_sg > 0").length
		else
		 @Errori<< "Qualifica di " + @p.nome + " " + @p.cognome + " diversa da una di quelle previste"
		 puts "Qualifica di " + @p.nome + " " + @p.cognome + " diversa da una di quelle previste"
		 n_errori = n_errori + 1
		end
				
		if numero_fattori != @p.valutazioni.length
			 @Errori<< "Persona " + @p.nome + " " + @p.cognome + " con numero fattori di valutazione diversi dai previsti"
			 puts "Persona " + @p.nome + " " + @p.cognome + " con numero fattori di valutazione diversi dai previsti"
			 n_errori = n_errori + 1
		end
		   
		lista_valutazioni = @p.valutazioni.includes(:vfactor).order("vfactors.ordine_apparizione asc")
			   
		# le valutazioni partono dalla riga 12
		inizio_righe_valutazioni = row + 11
		if n_errori == 0
		  (inizio_righe_valutazioni..(inizio_righe_valutazioni+numero_fattori-1)).each do |riga|
		  nn_errori = 0
		  fattore_valutazione = sheet.cell('B',riga)
		  puts "fattore_valutazione: " + fattore_valutazione.to_s
				  # mtype = sheet.excelx_type(riga, 'A')
				  # mvalue = sheet.excelx_value(riga, 'A')
			   
		  peso_fattore_valutazione =  sheet.cell('C',riga)				  # mtype = sheet.excelx_type(riga, 'B')
				  # mvalue = sheet.excelx_value(riga, 'B')
			  
		  stringa_voto_fattore_valutazione =  sheet.cell('D',riga)
				  # mtype = sheet.excelx_type(riga, 'C')
				  # mvalue_voto_fattore_valutazione = sheet.excelx_value(riga, 'C').to_f
				  # puts stringa_voto_fattore_valutazione.to_s
				  # puts mtype.to_s
				  # puts mvalue_voto_fattore_valutazione.to_s
		  mvalue_voto_fattore_valutazione = stringa_voto_fattore_valutazione.to_f
							  
				  
		  votopesato_fattore_valutazione =  sheet.cell('E',riga)
				  # mtype = sheet.excelx_type(riga, 'D')
				  # mvalue = sheet.excelx_value(riga, 'D')
				 
				 
		  valutazione = lista_valutazioni[riga - inizio_righe_valutazioni]
				  # conviene confrontare solo lettere alfabetiche e numeri
		  fattore_valutazione_pulito = fattore_valutazione.gsub(/[^0-9A-Za-z]/,"").strip
	      vfactor_denominazione_pulito = valutazione.vfactor.denominazione.gsub(/[^0-9A-Za-z]/,"").strip
		  puts "RIGA " + riga.to_s + " " + (riga - inizio_righe_valutazioni).to_s + " #" + fattore_valutazione + "#  #" + valutazione.vfactor.denominazione + "#"
		  puts "#" + fattore_valutazione_pulito + "#" + vfactor_denominazione_pulito + "#"
		  if !(vfactor_denominazione_pulito.eql? fattore_valutazione_pulito)
					puts "Errore denominazione: #" + valutazione.vfactor.denominazione + "#" + fattore_valutazione + "#" 
					@Errori<< "Errore denominazione: Persona " + @p.nome + " " + @p.cognome + " valutazione non corretta " + fattore_valutazione + " != "  + valutazione.vfactor.denominazione
					nn_errori = nn_errori + 1
		  end
		  if !((mvalue_voto_fattore_valutazione >= valutazione.vfactor.min) && (mvalue_voto_fattore_valutazione <= valutazione.vfactor.max))
					puts "Errore valore: # min: " + valutazione.vfactor.min.to_s + " val: " + mvalue_voto_fattore_valutazione.to_s + " max: " +  valutazione.vfactor.max.to_s 
					@Errori<< "Errore valore:: Persona " + @p.nome + " " + @p.cognome + " # min: " + valutazione.vfactor.min.to_s + " val: " + mvalue_voto_fattore_valutazione.to_s + " max: " +  valutazione.vfactor.max.to_s + " -> fuori dai limiti " 
					nn_errori = nn_errori + 1
		  end
		  puts "nn_errori: " + nn_errori.to_s
		  if nn_errori == 0
					valutazione.value =  mvalue_voto_fattore_valutazione
					valutazione.save!
					@p.save!
					risultato |= [@p]
					
		  end
		end	
	  end
	end
		
	return [risultato, @Errori]
 end
 
 def self.leggi_scheda_valutazione_obiettivi(sheet, row)
	puts "leggi_scheda_valutazione_obiettivi"
	risultato = []
	@Errori = []
	
	nominativo  = sheet.cell('C',row +1)
	puts nominativo 
	m  = sheet.cell('C',row + 2)
			#mtype = sheet.excelx_type(4, 'C')
			#mvalue = sheet.excelx_value(4, 'C')
			#puts mtype 
			#puts mvalue
			#matricola = mvalue.to_s.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
	matricola = m.to_s.chomp('.0').gsub(/[^0-9A-Za-z]/,"").strip.rjust(7,'0').gsub(/[^0-9A-Za-z]/,"").strip
	puts "MATRICOLA = " + matricola
	qualifica = sheet.cell('C',row + 3)
	puts qualifica
			
	#controllo correttezza foglio 
	label_nomecognome_foglio_obiettivi = sheet.cell('A',row + 1)
	label_nrmatricola = sheet.cell('A',row + 2)
	label_qualifica = sheet.cell('A',row + 3)
	label_dirigente = sheet.cell('A',row + 4)
	
	contO = 0
	# controllo se è foglio obiettivi
	# i campi sono spostati di uno
	if (label_nomecognome_foglio_obiettivi != nil) && (label_nomecognome_foglio_obiettivi.include? "Nome Cognome")
	   contO += 1
	end
	if (label_nrmatricola != nil) && (label_nrmatricola.include? "Nr Matricola")
	   contO += 1
	end
	if (label_qualifica != nil) && (label_qualifica.include? "Qualifica")
	   contO += 1
	end
	if (label_dirigente != nil) && (label_dirigente.include? "Dirigente")
	   contO += 1
	end
						
	if (contO > 3)
				@p = Person.where(matricola: matricola).first
	end
	if (@p != nil) &&  (contO > 3)
		 #importazione valutazione obiettivi
		 puts "IMPORTAZIONE VALUTAZIONE OBIETTIVI"
		 n_errori = 0
		 inizio_righe_obiettivi = row + 9
		 n_targets = @p.obiettivi.length + @p.fasi.length + @p.azioni.length
		 (inizio_righe_obiettivi..(inizio_righe_obiettivi+n_targets-1)).each do |riga|
			nn_errori = 0
			tipo_da_codice = ""
			id_da_codice = ""
			check_tipo = false
			check_codice = false
			id_target = sheet.cell('A',riga)
			mtype = sheet.excelx_type(riga, 'A')
			id_target_mvalue = sheet.excelx_value(riga, 'A')
				  
				  # il codice è fatto così
				  # OB-00000X
				  #
			if id_target.length == 9
				tipo_da_codice = id_target[0..1]
				id_da_codice = id_target[3..7]
				check_da_id = id_target[8]
				check_codice = false
				temp = 0
				id_da_codice.to_s.split('').each do |c|
					temp = (temp + c.to_i)%10
				end
				check_codice = (check_da_id.to_i == temp)
				puts("check_da_id : " + check_da_id)
				puts("temp : " + temp.to_s)
				puts("result check : " + (check_da_id.to_i == temp).to_s)
			else 
			   puts "Errore codice lunghezza"
			end
				  
			denominazione_target = sheet.cell('B',riga)
			mtype = sheet.excelx_type(riga, 'B')
			denominazione_mvalue = sheet.excelx_value(riga, 'B')
			 
			tipo_target =  sheet.cell('C',riga)
			mtype = sheet.excelx_type(riga, 'C')
			tipo_target_mvalue = sheet.excelx_value(riga, 'C')
			check_tipo = false
			case tipo_target # 
				  when "Obiettivo"    
				   if tipo_da_codice == "OB"
				     check_tipo = true
				   end
				  when "Fase" 
				   if tipo_da_codice == "FA"
				     check_tipo = true
				   end				  
				  when "Azione"
				   if tipo_da_codice == "AZ"
				     check_tipo = true
				   end
				  when "Opera"
				   if tipo_da_codice == "OP"
				     check_tipo = true
				   end
			end
				  
			peso_target =  sheet.cell('D',riga)
			mtype = sheet.excelx_type(riga, 'D')
			peso_target_mvalue = sheet.excelx_value(riga, 'D')
			   
			valutazione_target =  sheet.cell('F',riga)
			mtype = sheet.excelx_type(riga, 'F')
			valutazione_mtarget_mvalue = sheet.excelx_value(riga, 'F')
			  
			if check_tipo && check_codice
					  case tipo_target # 
					  when "Obiettivo"    #
						 #o = OperationalGoal.where(denominazione: denominazione_mvalue).first
						 o = OperationalGoal.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: o).first
						 if val == nil
						   @Errori<< "Valutazione Obiettivo " + o.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						   puts "settato : " + o.denominazione + " val: " + val.valore.to_s
						 end 
					  when "Fase"    #
						 #f = Phase.where(denominazione: denominazione_mvalue).first
						 f = Phase.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: f).first
						 if val == nil
						   @Errori<< "Valutazione Fase " + f.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						   puts "settato : " + f.denominazione + " val: " + val.valore.to_s
						 end 
					  when "Azione"    #
						 #a = SimpleAction.where(denominazione: denominazione_mvalue).first
						 a = SimpleAction.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: a).first
						 if val == nil
						   @Errori<< "Valutazione Azione " + a.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						   puts "settato : " + a.denominazione + " val: " + val.valore.to_s
						 end 
					   when "Opera"    #
						 
						 op = Opera.find(id_da_codice.to_i)
						 val = TargetDipendenteEvaluation.where(dipendente: @p, target: op).first
						 if val == nil
						   @Errori<< "Valutazione Opera " + op.denominazione + " per dipendente " + @p.nome + " " + @p.cognome + " non esistente " 
						   nn_errori = nn_errori + 1
						 else
						   val.valore = valutazione_mtarget_mvalue
						   val.save!
						   puts "settato : " + op.denominazione + " val: " + val.valore.to_s
						 end 
					  else
						@Errori<< "Tipo target " + @p.nome + " " + @p.cognome + " non riconosciuto: " + tipo_target
						nn_errori = nn_errori + 1
					  end
				end
			end
		 else # non trovata la persona o scheda non conforme
		   @Errori<< "Scheda non riconosciuto  Fattori conformità scheda: contP=" + contP.to_s + "; contO=" + contO.to_s + "  matricola " + matricola.to_s + " non trovata. P=" + p.to_s + "#"
		 end
	
		
	return [risultato, @Errori]
 
 end
 
 def self.importa_organico(file)
	stringa_filename = file.original_filename
	extension = 'xls'
	xls = Roo::Spreadsheet.open(file.path)
	#informazioni = xls.info
	@persone_aggiunte = []
	@uffici_aggiunti = []
	@righe_scartate = []
	@persone_modificate = []
 
	fogli = xls.sheets
	fogli.each do |name|
        puts name
        sheet = xls.sheet(name)
		last_row = sheet.last_row
		case name
		when "Lista Dipendenti"
			indice = 2
			
			for row in indice..last_row
				inserita = false
				nome  = sheet.cell('B',row).to_s.strip
				cognome  = sheet.cell('C',row).to_s.strip
				matricola  = sheet.cell('D',row).to_s.rjust(7,'0').strip
				ufficio  = sheet.cell('E',row).to_s.strip
				email  = sheet.cell('F',row).to_s.strip
				qualifica  = sheet.cell('G',row).to_s.strip
				categoria  = sheet.cell('H',row).to_s.strip
				ruolo  = sheet.cell('I',row).to_s.strip
				
				q = QualificationType.where(denominazione: qualifica).first
				
				
				if Person.where(matricola: matricola).length == 0
					if Office.where(nome: ufficio).length == 1
						ufficio = Office.where(nome: ufficio).first
						if Person.create(nome: nome,
							cognome: cognome,
							matricola: matricola,
							email: email,
							ufficio: ufficio,
							qualification: q,
							categoria: categoria,
							ruolo: ruolo,
							password: "comune",
							password_confirmation: "comune",
							filename_importazione: stringa_filename).valid?
							
						    a = Person.where(matricola: matricola).first
							@persone_aggiunte<< a
						    inserita = true
							puts "ok"
						else
						    puts "PROBLEMA"
						end
					else # ufficio non trovato
						if Person.create(nome: nome,
							cognome: cognome,
							matricola: matricola,
							email: email,
							qualification: q,
							categoria: categoria,
							ruolo: ruolo,
							password: "comune",
							password_confirmation: "comune",
							filename_importazione: stringa_filename).valid?
						    
						   a = Person.where(matricola: matricola).first
						   @persone_aggiunte<< a
						   inserita = true
						end
					end
				else
				#eventualmente update
				# solo delle cose che hanno senso: ufficio, categoria, qualifica, ruolo
					if Person.where(matricola: matricola).length == 1
					  p = Person.where(matricola: matricola).first
					  inserita = true
					  if Office.where(nome: ufficio).length == 1
					    ufficio = Office.where(nome: ufficio).first
						p.ufficio = ufficio
						p.qualification = q
						p.categoria = categoria
						p.ruolo = ruolo
						p.save
						@persone_modificate<< p
					  end
					end
				end
				if !inserita
				  @righe_scartate<< row.to_s + " " + nome + " " + cognome + " " + matricola
				end
			end
		
		
		when "Lista Uffici"
			indice = 2
			for row in indice..last_row
				nome  = sheet.cell('B',row).to_s.strip
				tipo  = sheet.cell('C',row).to_s.strip
				direttore  = sheet.cell('D',row).to_s.strip
				ufficio_padre  = sheet.cell('E',row).to_s.strip
				
				d = Person.cerca(direttore)
				t = OfficeType.where(denominazione: tipo).first
				up = Office.where(nome: ufficio_padre).first
				
				if Office.where(nome: nome).length == 0
					if (d != nil) && (t != nil) && (up != nil)
						u = Office.create(nome: nome,
							director: d,
							office_type: t,
							parent: up)
						
						@uffici_aggiunti<< u
					elsif (d != nil) && (t != nil) 
						u = Office.create(nome: nome,
							director: d,
							office_type: t)
						@uffici_aggiunti<< u
					elsif (d == nil) && (t == nil) && (up != nil)
						u = Office.create(nome: nome,
							parent: up)
						@uffici_aggiunti<< u
					elsif (d == nil) && (t != nil) && (up != nil)
						u = Office.create(nome: nome,
							office_type: t,
							parent: up)
						@uffici_aggiunti<< u
					end
				else Office.where(nome: nome).length == 1
					o = Office.where(nome: nome).first
					if d != nil
						o.director = d
						o.save
					end
					if t != nil
						o.office_type = t
						o.save
					end
					if up != nil
						o.parent = up
						o.save
					end
				end
		
		
			end
		end
  end
  return [@persone_aggiunte, @uffici_aggiunti, @righe_scartate, @persone_modificate] 
 end


end
