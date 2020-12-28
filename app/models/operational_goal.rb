class OperationalGoal < ApplicationRecord

belongs_to :obiettivo_strategico_padre, class_name: 'StrategicGoal', foreign_key: 'obiettivo_strategico_id', required: false

belongs_to :responsabile_principale, class_name: 'Person', foreign_key: 'responsabile_principale_id'
has_many :other_managers, class_name: 'OtherManager', foreign_key: 'obiettivo_operativo_id'
has_many :altri_responsabili, -> { distinct }, :through => :other_managers, :source => :altro_responsabile

has_many :goal_assignments, class_name: 'GoalAssignment', foreign_key: 'operational_goal_id', dependent: :destroy
has_many :assegnatari, :through => :goal_assignments, :source => :persona

has_many :fasi, class_name: 'Phase', foreign_key: 'operational_goal_id', dependent: :destroy
has_many :opere, class_name: 'Opera', as: :target

has_many :indicatori, class_name: 'Gauge', as: :target, dependent: :destroy
has_one :valutazione, class_name: 'ItemEvaluation', as: :target, dependent: :destroy

has_many :valutazioni_x_dipendenti, class_name: 'TargetDipendenteEvaluation', as: :target, dependent: :destroy

has_many :office_target_collaborations, -> { distinct }, as: :target, dependent: :destroy
has_many :offices, -> { distinct }, class_name: 'Office', through: :office_target_collaborations

belongs_to :struttura_organizzativa, class_name: 'Office', foreign_key: 'struttura_organizzativa_id', required: false


def self.importa(file)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	xls.sheets
	elabora = false
	@obiettivi = []
	@obiettivi_modificati = []
	@fasi = []
	@azioni = []
	xls.each_with_pagename do |name, sheet|
	  case name 
	  when "Obiettivi" 
	     foglio_obiettivi = xls.sheet('Obiettivi')
		 flag_di_gruppo = false
		 flag_di_struttura = true
		 elabora = true
	  when "Obiettivi di struttura"
	     foglio_obiettivi = xls.sheet('Obiettivi di struttura')
		 flag_di_gruppo = false
		 flag_di_struttura = true
		 elabora = true
	  when "Obiettivi Individuali"
	     foglio_obiettivi = xls.sheet('Obiettivi Individuali')
		 flag_di_gruppo = false
		 flag_di_struttura = false
		 flag_individuale = true
		 elabora = true
	  else 
	     elabora = false
	  end
	  if elabora
	    foglio_obiettivi.cell('A',2) == 'Titolo'
	    last_row    = foglio_obiettivi.last_row
	    
		struttura_organizzativa = nil
	    indice_riga = 3
	    for row in 3..last_row
	       puts "RIGA: " + indice_riga.to_s
		   indice_riga = indice_riga + 1
		   titolo = foglio_obiettivi.cell('A', row)
		   if titolo != nil 
		     titolo = titolo.strip
		   end
		   descrizione = foglio_obiettivi.cell('B', row)
		   tipo_grezzo = foglio_obiettivi.cell('C', row)
		   puts "titolo " + titolo.to_s 
		   if tipo_grezzo != nil && tipo_grezzo.length >1 
		     tipo = tipo_grezzo.gsub(/[^0-9A-Za-z]/, '')
		   end
		   servizio_grezzo = foglio_obiettivi.cell('D', row)
		   if servizio_grezzo != nil && servizio_grezzo.length >1 
		     servizio_grezzo = servizio_grezzo.strip
		     servizio = servizio_grezzo.gsub(/[^0-9 A-Za-zòàùèé,-]/, '')
			 struttura_organizzativa = Office.cerca(servizio)
		   end
		   avanzamento = foglio_obiettivi.cell('O', row)
		   valore_avanzamento = 0.0
		   if avanzamento.is_a?(Numeric)
		    valore_avanzamento = 1.0 * avanzamento
		   else
		    if (avanzamento != nil) && (avanzamento.strip.first != "=") && (avanzamento.last == "%")
              valore_avanzamento = avanzamento.strip.chomp('%').to_f
            else
              valore_avanzamento = 0.0		  
		    end
           end	
		   missione = foglio_obiettivi.cell('L', row)
		   obiettivo_riferimento = foglio_obiettivi.cell('M', row)
		   puts foglio_obiettivi.cell('E', row)
		   if foglio_obiettivi.cell('E', row) != nil
		    responsabile = foglio_obiettivi.cell('E', row).gsub(/[^0-9 A-Za-z]/, '')
		   else
		    responsabile = " "
		   end
		   peso = foglio_obiettivi.cell('J', row)
		   
		   if (tipo == 'Obiettivo') || (tipo == 'Obiettivoindividuale')
		    puts "tipo" + tipo
			resp = Person.cerca_dirigente(responsabile)
	 		puts "responsabile " + responsabile.to_s
 			puts (resp != nil ? resp.cognome : "non trovato")
			if (tipo == 'Obiettivo individuale')
			 flag_individuale = true
			end 
  		  	if resp != nil
			 if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
		      @og = OperationalGoal.create(denominazione: titolo,
			                       descrizione: descrizione,
								   obiettivo_di_gruppo: flag_di_gruppo,
								   obiettivo_individuale: flag_individuale,
								   obiettivo_di_struttura: flag_di_struttura,
								   obiettivo_riferimento: obiettivo_riferimento,
								   obiettivo_extrapeg: false,
								   missione: missione,
								   struttura_organizzativa: struttura_organizzativa,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   indice_strategicita: peso,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   responsabile_principale: resp)
			  v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			  @og.valutazione = v
			  @obiettivi<< @og 
			 else 
			 # se esiste già lo metto in og in modo da poter settare le fasi eventualmente aggiunte
			 
              @og = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			  # eventualmente lo modifico
			  @og.struttura_organizzativa = struttura_organizzativa
			  @og.save
			  
              if resp != nil		
               if @og.valutazione == nil
			 	v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			    @og.valutazione = v
			   else
			    if valore_avanzamento > 0
			      @og.valutazione.valore_valutazione_dirigente = valore_avanzamento
				end
			   end
			   @og.descrizione =  descrizione
		       # il peso negli obiettivi è indice di strategicità
			   @og.descrizione =  descrizione
			   @og.obiettivo_di_gruppo = flag_di_gruppo
			   @og.obiettivo_individuale = flag_individuale
			   @og.obiettivo_di_struttura = flag_di_struttura
			   @og.indice_strategicita =  peso
			   @og.obiettivo_riferimento = obiettivo_riferimento
			   @og.missione = missione
			   @og.struttura_organizzativa = struttura_organizzativa
			   @og.save
			  end
			  @obiettivi_modificati<< @og
             end			 
		    end
           end		  
		   # mi baso sul fatto che nel foglio Excel ci sia sempre prima l'obiettivo e poi le sue fasi ed azioni
		   if tipo == 'Fase'
		     resp = Person.cerca_dirigente(responsabile)
	 		 puts responsabile
 			 if resp != nil
 		      if (Phase.where('lower(denominazione) = lower(?)and responsabile_principale_id = ?', titolo, resp.id).length == 0) 
		       @f = Phase.create(denominazione: titolo,
			                       descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   peso: peso,
								   
								   obiettivo_riferimento: obiettivo_riferimento,
								   missione: missione,
								   
								   ente: Setting.where(denominazione: 'ente').first.value,
								   obiettivo_operativo_fase: @og,
								   responsabile_principale: resp)
			   v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			   @f.valutazione = v
			   @fasi<< @f
			  else
			   # se esiste già lo metto in f in modo da poter settare le azioni eventualmente aggiunte
			   @f = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			   if @f.valutazione == nil
			  	 v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			     @f.valutazione = v
			   else
			     if valore_avanzamento > 0
			       @f.valutazione.valore_valutazione_dirigente = valore_avanzamento
			 	 end
			   end
			   @f.responsabile_principale = resp
			   @f.obiettivo_operativo_fase = @og
			   @f.peso = peso
			   @f.obiettivo_riferimento = obiettivo_riferimento
			   @f.missione = missione
			   @f.ente = Setting.where(denominazione: 'ente').first.value
			   @f.anno = Setting.where(denominazione: 'anno').first.value
			   @f.descrizione = descrizione
			   @f.save
			   @fasi<< @f
			  end
			end
		   end
		   if tipo == 'Azione'
		     resp = Person.cerca_dirigente(responsabile)
			 puts responsabile
			 if resp != nil
		      if (SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
		       @a = SimpleAction.create(denominazione: titolo,
			                       descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   peso: peso,
								   								   
								   obiettivo_riferimento: obiettivo_riferimento,
								   missione: missione,
								   
								   ente: Setting.where(denominazione: 'ente').first.value,
								   fase: @f,
								   responsabile_principale: resp)
			   v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			   @a.valutazione = v
			   @azioni<< @a
			  else
			   # se esiste già la vado a modificare
			   @a = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			   if @a.valutazione == nil
				 v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento)
			     @a.valutazione = v
			    else
			     if valore_avanzamento > 0
			       @a.valutazione.valore_valutazione_dirigente = valore_avanzamento
				 end
			    end
			   @a.descrizione = descrizione
			   @a.anno = Setting.where(denominazione: 'anno').first.value
			   @a.peso = peso
			   @a.obiettivo_riferimento = obiettivo_riferimento
			   @a.missione = missione								   
			   @a.ente = Setting.where(denominazione: 'ente').first.value
			   @a.fase = @f
			   @a.responsabile_principale = resp
			   @a.save
			   @azioni<< @a
			  end 
		    end
		   end
	   end
	  end # ciclo elabora
	end # ciclo su titti i fogli di lavoro
	return [@obiettivi, @fasi, @azioni, @obiettivi_modificati]
end

def self.importa_attivita_ordinaria(file, responsabile, colonna_nome_ufficio, colonna_obiettivo, colonna_indicatore, colonna_valore, colonna_obiettivo_performance, nome_foglio)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Cipriano2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Cipriano2018.xls")
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	fogli = xls.sheets
	#foglio_obiettivi = xls.sheet('AC_quantità')
	foglio_obiettivi = nil
	esiste_attivita_ordinaria = false
	
	indice_foglio_attivita_ordinaria = 0
	@obiettivi = []
	@obiettivi_modificati = []
	@righe_non_determinate = []
	i = 0
	# ciclo per tutti i fogli di lavoro
	fogli.each do |nome_foglio|
	   if nome_foglio.start_with?(nome_foglio)
	    # siamo in un foglio di attività ardinaria
	    puts "FOGLIO ATTIVITA ORDINARIA: " + nome_foglio
	    esiste_attivita_ordinaria = true
	    foglio_obiettivi = xls.sheet(nome_foglio)
	    	
	    if esiste_attivita_ordinaria
	  	    
	     #foglio_obiettivi.cell('A',1) == 'UFFICI'
	     last_row = foglio_obiettivi.last_row
	
	     for row in 2..last_row
		  stringa = foglio_obiettivi.cell('B', row)
		  if stringa != nil # se nil lascio quello che avevo
		    titolo = stringa.strip()
		  end
		  descrizione = " n.a. "
		  tipo = "Obiettivo"  # sono tutti obiettivi
		  
		  nome_ufficio = foglio_obiettivi.cell(colonna_nome_ufficio, row).to_s.strip
		  
		  #puts foglio_obiettivi.cell('A', row)
		  #
		  ########################################################
		  # il responsabile lo ricevo dalla form
		  # # if foglio_obiettivi.cell('A', row) != nil
		   # # nome_ufficio = foglio_obiettivi.cell('A', row).strip
		   # # nome_ufficio.gsub!(/Unità Operativa/, "U.O.") 
		   # # nome_ufficio.gsub!(/Unità Semplice/, "U.S.") 
		   
		  # # end
		  # # # se la cella non è valorizzata rimane l'ultimo trovato
		  
		  # # ufficio = Office.where("nome LIKE ?", nome_ufficio.upcase ).first
		  # # if ufficio != nil
		   # # resp = ufficio.dirigente
		  # # else
		   # # resp = nil
		  # # end
		  #########################################################
		  resp = responsabile
		  nome_obiettivo = foglio_obiettivi.cell(colonna_obiettivo, row).to_s.strip()
		  
		  indicatore = foglio_obiettivi.cell(colonna_indicatore, row)
		  if indicatore != nil
		    indicatore = indicatore.strip()
		  end
		  
		  obiettivo_performance = foglio_obiettivi.cell(row, colonna_obiettivo_performance).to_s.strip
		  puts "obiettivo_performance :" + obiettivo_performance.to_s
		  op = false
		  if obiettivo_performance != nil
		    if obiettivo_performance.include? "SI"
			 op = true
			end
		  end
		  
		  	  
		  consuntivo1 = foglio_obiettivi.cell('D', row) != nil ? foglio_obiettivi.cell('D', row) : ""
		  consuntivo2 = foglio_obiettivi.cell('E', row) != nil ? foglio_obiettivi.cell('E', row) : ""
		  consuntivo3 = foglio_obiettivi.cell('F', row) != nil ? foglio_obiettivi.cell('F', row) : ""
		  previsionale1 = foglio_obiettivi.cell('G', row) != nil ? foglio_obiettivi.cell('G', row) : ""
		  previsionale2 = foglio_obiettivi.cell('H', row) != nil ? foglio_obiettivi.cell('H', row) : ""
		  previsionale3 = foglio_obiettivi.cell('I', row) != nil ? foglio_obiettivi.cell('I', row) : ""
		  
		  note = foglio_obiettivi.cell('K', row) != nil ? foglio_obiettivi.cell('K', row) : ""
		  
		  if tipo == 'Obiettivo' && resp != nil && titolo != nil && titolo.length > 1  && indicatore != nil
		    #resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			puts resp.nominativo
			puts titolo
			# popolo la tabella AttivitaConsolidataGauge
			if (AttivitaConsolidataGauge.where(responsabile_principale: resp, linea_di_attivita: titolo, indicatore_di_quantita: indicatore).length == 0)
			 @ac = AttivitaConsolidataGauge.create(ufficio_stringa: nome_ufficio,
			                       linea_di_attivita: titolo,
								   indicatore_di_quantita: indicatore,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   consuntivo_anno_n_meno_3: consuntivo1,
                                   consuntivo_anno_n_meno_2: consuntivo2,
                                   consuntivo_anno_n_meno_1: consuntivo3,
                                   previsionale_anno_n: previsionale1,
                                   previsionale_anno_n_piu_1: previsionale2,
                                   previsionale_anno_n_piu_2: previsionale3,
                                   obiettivo_di_performance: (obiettivo_performance.to_s.downcase.strip.eql? "si"), 
                                   note: note.to_s.strip,
			                       foglio_di_lavoro: nome_foglio,
								   responsabile_principale: resp)
			else 
			  acg = AttivitaConsolidataGauge.where(responsabile_principale: resp, linea_di_attivita: titolo, indicatore_di_quantita: indicatore).first
			  acg.linea_di_attivita = titolo.strip
			  acg.ufficio_stringa = nome_ufficio.strip
			  acg.indicatore_di_quantita = indicatore.strip
			  acg.anno = Setting.where(denominazione: 'anno').first.value
			  acg.ente = Setting.where(denominazione: 'ente').first.value,
			  acg.responsabile_principale = resp
			  acg.consuntivo_anno_n_meno_3 = consuntivo1
              acg.consuntivo_anno_n_meno_2 = consuntivo2
              acg.consuntivo_anno_n_meno_1 = consuntivo3
              acg.previsionale_anno_n = previsionale1
              acg.previsionale_anno_n_piu_1 = previsionale2
              acg.previsionale_anno_n_piu_2 = previsionale3
              
              acg.obiettivo_di_performance = (obiettivo_performance.to_s.downcase.strip.eql? "si") 
              acg.note = note.to_s.strip
			  acg.foglio_di_lavoro = nome_foglio
			  acg.save
			end
			#########
			# se op == true creo l'obiettivo
			if op   
			  if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
			 
		       @og = OperationalGoal.create(denominazione: titolo,
			                       descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   #indice_strategicita: peso,
								   attivita_ordinaria: true,
								   obiettivo_di_struttura: false,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   responsabile_principale: resp)
			   @obiettivi<< @og 
			   # qua se ha creato lo obiettivo bisogna vedere del indicatore
			   # oppure si importa due volte
			  else 
			   # se esiste già lo metto in og in modo da poter settare le fasi/indicatore eventualmente aggiunte
			 
               @og = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			   @og.attivita_ordinaria = true
			   @og.obiettivo_di_struttura = false
			   @og.save
			 
			   if (Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', "Fase AC - " + indicatore, resp.id).length == 0)
			    @fa = Phase.create(denominazione: "Fase AC - " + indicatore,
			                       descrizione: indicatore,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   #indice_strategicita: peso,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   obiettivo_operativo_fase: @og,
								   responsabile_principale: resp)
			    # creo l'indicatore che si chiama come la fase
				
				g = Gauge.new
				g.nome = indicatore
				g.descrizione =  @fa.denominazione
				g.save
				@fa.indicatori<< g
				@fa.save
			 else
			   @fa = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', "Fase AC - " + indicatore, resp.id).first
			   if @fa.obiettivo_operativo_fase != @og
			      @righe_non_determinate<< "PROBLEMA 1 FASE INDICATORE: " + indicatore
			   end 
			   if @fa.indicatori.length != 1 || @fa.indicatori.first.nome != indicatore
			      @righe_non_determinate<< "PROBLEMA 2 FASE INDICATORE: " + indicatore
			   end 
			 end
			 
             if resp != nil			 
			   @og.descrizione =  descrizione
			   @og.save
			 end
			 @obiettivi_modificati<< @og
            end	
          end #fine di op == true 0> ho creato l'obiettivo 			
		 else
		    # responsabile non determinato
			@righe_non_determinate<< (row.to_s + " " + titolo)
		 end
	    end
	  end
	 end
	 i = i + 1 # itero sui fogli di lavoro
	end
	xls.close
	return [@obiettivi, @obiettivi_modificati, @righe_non_determinate]
end

def self.importavalori(file)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	xls.sheets
	
	foglio_obiettivi = xls.sheet('Obiettivi')
	foglio_obiettivi.cell('A',2) == 'Titolo'
	last_row    = foglio_obiettivi.last_row
	@obiettivi = []
	@obiettivi_modificati = []
	@target_non_trovati = []
	@fasi_modificate = []
	@azioni_modificate = []
	@indicatori_valorizzati = []
	@valutazioni_importate = []
	for row in 3..last_row
		  titolo = foglio_obiettivi.cell('A', row)
		  descrizione = foglio_obiettivi.cell('B', row)
		  tipo = foglio_obiettivi.cell('C', row)
		  servizio = foglio_obiettivi.cell('D', row)
		  
		  indicatori_stringa = foglio_obiettivi.cell('H', row).to_s
		  indicatori = indicatori_stringa.split("\n")
		  indicatori.delete_if {|x| x.length <1  } 
		  
		  avanzamento_dichiarato = foglio_obiettivi.cell('O', row)
		  avanzamento_misurato = foglio_obiettivi.cell('T', row)
		  quantificatore_indicatore_stringa = foglio_obiettivi.cell('N', row)
		  valore_avanzamento_dichiarato = 0.0
		  valore_avanzamento_misurato = 0.0
		  if avanzamento_dichiarato.is_a?(Numeric)
		   valore_avanzamento_dichiarato = 1.0 * avanzamento_dichiarato * 100
		  else
		   if (avanzamento_dichiarato != nil) && (avanzamento_dichiarato.strip.first != "=") && (avanzamento_dichiarato.last == "%")
             valore_avanzamento_dichiarato = avanzamento_dichiarato.strip.chomp('%').to_f * 100
           else
		     puts "VALORE BOH " + avanzamento_dichiarato.to_s
			 puts avanzamento_dichiarato
             valore_avanzamento_dichiarato = 0.0	  
		   end
          end	
          if avanzamento_misurato.is_a?(Numeric)
		   valore_avanzamento_misurato = 1.0 * avanzamento_misurato * 100 
		   puts "valore_avanzamento_misurato NUMERIC"
		  else
		   puts "valore_avanzamento_misurato NON NUMERIC"
		   if (avanzamento_misurato != nil) && (avanzamento_misurato.strip.first != "=") && (avanzamento_misurato.strip.last == "%")
             valore_avanzamento_misurato = avanzamento_misurato.strip.chomp('%').to_f * 100
			 
           else
		     
             valore_avanzamento_misurato = 0.0		  
		   end
          end			  
		  if foglio_obiettivi.cell('E', row) != nil
		   responsabile = foglio_obiettivi.cell('E', row).strip
		  else
		   responsabile = " "
		  end
		  peso = foglio_obiettivi.cell('K', row)
		  
		  if tipo == 'Obiettivo'
		    resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			puts resp.nominativo
			if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
		     
			 @target_non_trovati<< titolo 
			else 
			 # se esiste già lo metto in og in modo da poter settare le fasi eventualmente aggiunte
			 # nell'importazione dei valori in realtà non modifico la struttura
			 
             @og = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
             if resp != nil		
               if @og.valutazione == nil
				v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento_dichiarato)
			    @og.valutazione = v
				@valutazioni_importate<< v
			   else
			    if valore_avanzamento_dichiarato > 0
			      @og.valutazione.valore_valutazione_dirigente = valore_avanzamento_dichiarato
				  @valutazioni_importate<< @og.valutazione
				end
			   end
			   @og.descrizione =  descrizione
			   @og.save
			 end
			 # modifica indicatori
			 @og.indicatori.each do |ind|
			    #nella variabile indicatori cè la lista degli indicatori trovati
			    indicatori.each do |indicatore|
				  if ind.nome.downcase.strip.eql? indicatore.downcase.strip
				    ind.descrizione_valore_misurazione = quantificatore_indicatore_stringa
					ind.valore_misurazione = valore_avanzamento_misurato
					ind.save
					@indicatori_valorizzati<< ind
				  end
				end
			 end
			 @obiettivi_modificati<< @og
            end			 
		  end
		  # mi baso sul fatto che nel foglio Excel ci sia sempre prima l'obiettivo e poi le sue fasi ed azioni
		  if tipo == 'Fase'
		    resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			puts resp.nominativo
		    if (Phase.where('lower(denominazione) = lower(?)and responsabile_principale_id = ?', titolo, resp.id).length == 0)
		      
			  @target_non_trovati<< titolo
			else
			  # se esiste già lo metto in f in modo da poter settare le azioni eventualmente aggiunte
			  @f = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			  if @f.valutazione == nil
				v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento_dichiarato)
			    @f.valutazione = v
				@f.save
				@valutazioni_importate<< v
			  else
			    if valore_avanzamento_dichiarato > 0
			      @f.valutazione.valore_valutazione_dirigente = valore_avanzamento_dichiarato
				  @valutazioni_importate<< @f.valutazione
				end
			  end
			  # modifica indicatori
			  @f.indicatori.each do |ind|
			    #nella variabile indicatori cè la lista degli indicatori trovati
			    indicatori.each do |indicatore|
				  if ind.nome.downcase.strip.eql? indicatore.downcase.strip
				    ind.descrizione_valore_misurazione = quantificatore_indicatore_stringa
					ind.valore_misurazione = valore_avanzamento_misurato
					ind.save
					@indicatori_valorizzati<< ind
				  end
				end
			 end
			  @f.responsabile_principale = resp
			  # non modifico la struttura di obiettivi / fasi / azioni
			  #@f.obiettivo_operativo_fase = @og
			  @f.peso = peso
			  @f.ente = Setting.where(denominazione: 'ente').first.value
			  @f.anno = Setting.where(denominazione: 'anno').first.value
			  @f.descrizione = descrizione
			  @f.save
			  @fasi_modificate<< @f
			end
		  end
		  if tipo == 'Azione'
		    if (SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
		      
			  @target_non_trovati<< titolo
			else
			  # se esiste già la vado a modificare
			  @a = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			  if @a.valutazione == nil
				v = ItemEvaluation.create(valore_valutazione_dirigente: valore_avanzamento_dichiarato)
			    @a.valutazione = v
				@valutazioni_importate<< v
			   else
			    if valore_avanzamento_dichiarato > 0
			      @a.valutazione.valore_valutazione_dirigente = valore_avanzamento_dichiarato
				  @valutazioni_importate<< @a.valutazione
				end
			   end
			   # modifica indicatori
			   @a.indicatori.each do |ind|
			    #nella variabile indicatori cè la lista degli indicatori trovati
			    indicatori.each do |indicatore|
				  if ind.nome.downcase.strip.eql? indicatore.downcase.strip
				    ind.descrizione_valore_misurazione = quantificatore_indicatore_stringa
					ind.valore_misurazione = valore_avanzamento_misurato
					ind.save
					@indicatori_valorizzati<< ind
				  end
				end
			 end
			  @a.descrizione = descrizione
			  @a.anno = Setting.where(denominazione: 'anno').first.value
			  @a.peso = peso
			  @a.ente = Setting.where(denominazione: 'ente').first.value
			  @a.fase = @f
			  @a.responsabile_principale = resp
			  @a.save
			  @azioni_modificate<< @a
			end 
		  end
	end
	return [@obiettivi, @fasi_modificate, @azioni_modificate, @obiettivi_modificati, @indicatori_valorizzati, @valutazioni_importate, @target_non_trovati]
end

def self.importa_misurazioni_attivita_ordinaria(file, responsabile)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Cipriano2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Cipriano2018.xls")
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	fogli = xls.sheets
	#foglio_obiettivi = xls.sheet('AC_quantità')
	foglio_obiettivi = nil
	esiste_attivita_ordinaria = false
	
	indice_foglio_attivita_ordinaria = 0
	@obiettivi = []
	@obiettivi_modificati = []
	@valori_assegnati = []
	@righe_non_determinate = []
	i = 0
	# ciclo per tutti i fogli di lavoro
	fogli.each do |f|
	   colonna_obiettivo_performance = 0
	   if f.start_with?('AC')
	    # siamo in un foglio di attività ardinaria
	    puts "FOGLIO ATTIVITA ORDINARIA: " + f
	    esiste_attivita_ordinaria = true
	    indice_foglio_attivita_ordinaria = i
		puts "indice_foglio_attivita_ordinaria :" + indice_foglio_attivita_ordinaria.to_s
	    foglio_obiettivi = xls.sheet(indice_foglio_attivita_ordinaria)
	    indice_flag_performance = 1
	    foglio_obiettivi.row(1).each do |c|
		  if c != nil 
	       if c.include? "OBIETTIVO PERFORMANCE"
		    colonna_obiettivo_performance = indice_flag_performance
		   end
		  end
		  indice_flag_performance = indice_flag_performance + 1
	    end
	   

	    puts "colonna_obiettivo_performance :" + colonna_obiettivo_performance.to_s
	   
	
	    if esiste_attivita_ordinaria
	  	    
	     foglio_obiettivi.cell('A',1) == 'UFFICI'
	     last_row    = foglio_obiettivi.last_row
	
	     for row in 2..last_row
		  stringa = foglio_obiettivi.cell('B', row)
		  if stringa != nil # se nil lascio quello che avevo
		    titolo = stringa.strip()
		  end
		  descrizione = " n.a. "
		  tipo = "Obiettivo"  # sono tutti obiettivi
		  #puts foglio_obiettivi.cell('A', row)
		  #
		  ########################################################
		  # il responsabile lo ricevo dalla form
		  # # if foglio_obiettivi.cell('A', row) != nil
		   # # nome_ufficio = foglio_obiettivi.cell('A', row).strip
		   # # nome_ufficio.gsub!(/Unità Operativa/, "U.O.") 
		   # # nome_ufficio.gsub!(/Unità Semplice/, "U.S.") 
		   
		  # # end
		  # # # se la cella non è valorizzata rimane l'ultimo trovato
		  
		  # # ufficio = Office.where("nome LIKE ?", nome_ufficio.upcase ).first
		  # # if ufficio != nil
		   # # resp = ufficio.dirigente
		  # # else
		   # # resp = nil
		  # # end
		  #########################################################
		  resp = responsabile
		  indicatore = foglio_obiettivi.cell('C', row)
		  if indicatore != nil
		    indicatore = indicatore.strip()
		  end
		  # attenzione qua inverto gli indici perche se si mettono 'A' allora il 
		  obiettivo_performance = foglio_obiettivi.cell(row, colonna_obiettivo_performance)
		  #puts "obiettivo_performance :" + obiettivo_performance.to_s
		  op = false
		  if obiettivo_performance != nil
		    if obiettivo_performance.include? "SI"
			 op = true
			 valore = foglio_obiettivi.cell('I', row)
			 if valore == nil
			   valore = 0.0
			 end
			end
		  end
		  
		  if tipo == 'Obiettivo' && resp != nil && titolo != nil && titolo.length > 1 && op 
		    #resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			puts resp.nominativo
			puts titolo
			if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 0)
			 # non faccio niente
		     
			else 
			 # se esiste già lo metto in og in modo da poter settare le fasi/indicatore eventualmente aggiunte
			 
             @og = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			 
			 
			 if (Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', "Fase AC - " + indicatore, resp.id).length == 0)
			   # non faccio niente
			 else
			   @fa = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', "Fase AC - " + indicatore, resp.id).first
			   if @fa.obiettivo_operativo_fase != @og
			      @righe_non_determinate<< "PROBLEMA 1 FASE INDICATORE: " + indicatore
			   end 
			   if @fa.indicatori.length != 1 || @fa.indicatori.first.nome != indicatore
			      @righe_non_determinate<< "PROBLEMA 2 FASE INDICATORE: " + indicatore
			   else
			      # indicatore esiste e ha quel nome
				  # metto il valore
				  indicatore  = @fa.indicatori.first
			      indicatore.valore_misurazione = valore * 100
				  indicatore.save
                  @obiettivi_modificati<< @og
				  @valori_assegnati<< indicatore
               end			   
			 end
			 
             if resp != nil			 
			   @og.descrizione =  descrizione
			   @og.save
			 end
			 
            end	
          			
		 else
		    # responsabile non determinato
			@righe_non_determinate<< (row.to_s + " " + titolo)
		  end
	    end
	  end
	 end
	 i = i + 1 # itero sui fogli di lavoro
	end
	xls.close
	return [@obiettivi, @obiettivi_modificati, @righe_non_determinate, @valori_assegnati,]
end


 def tipo
   return "Obiettivo" 
 end
 
 def valore_totale
    valore = 0
	numeratore = 0
	denominatore = 0
	
	if fasi.length > 0
      fasi.each do |f|
	      numeratore = numeratore + f.valore_totale * (f.peso != nil ? f.peso : 1.0/fasi.length)
	  end
	  fasi.each do |f|
	     denominatore = denominatore + (f.peso != nil ? f.peso : 1.0/fasi.length)
	  end
	  if denominatore > 0
	   valore = numeratore/denominatore
	  end
	elsif
	  indicatori.each do |ind|
	    numeratore = numeratore + (ind.valore_misurazione != nil ? ind.valore_misurazione.to_f : 0 )
	    denominatore = denominatore + 1
	  end
	
	  if denominatore > 0
	    valore = numeratore/denominatore
	  end
	end
	
	return valore.round(2)
 end
 
 def punteggio_0_3
 
    val = valore_totale
	result = 0
	if val < 50
		result = 0.0
	elsif val < 60 && val >= 50
		result = 1.0
	elsif val < 70 && val >= 60
		result = 1.5
	elsif val < 80 && val >= 70
		result = 2.0
	elsif val < 90 && val >= 80
		result = 2.5
	elsif val >= 90
		result = 3.0
	end
	return result

	end
 
 def self.cerca(stringa)
    o = nil
	if stringa != nil
	 stringa = stringa.strip
	 puts "#" + stringa + "#"
     o = OperationalGoal.where("denominazione LIKE ?", stringa+"%").first
	 	
	end
	return o
 end
 
 def denominazione80
    return denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 def denominazione_completa
	result = ""
    result = result + denominazione.gsub(/[^0-9A-Za-z .,;:-_àèéìòù\/\']/,"").strip.html_safe + stringa_extrapeg
	if flag_variazione_peg
		result = result + "(*) "
	end 
	# fasi.each do |f|
		# result = result + "<p>" + f.denominazione.strip.html_safe + "<p>"
	# end
	# indicatori.each do |i|
		# result = result + "<p>" + i.denominazione.strip.html_safe + "<p>"
	# end
	return result
 end
 
 
 
 def codice
	check_sum = 0
	
	self.id.to_s.split('').each do |c|
	  check_sum = (check_sum + c.to_i)%10
	end
    return "OB-" + self.id.to_s.rjust(5, '0') + check_sum.to_s
 end
 
 def id_class
 
    return id.to_s + "-" + "OperationalGoal"
 end
 
 def id_denominazione80
    return id.to_s + "-" + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 
 
 def tipo_dirigente_denominazione80
    stringa_dirigente = (responsabile_principale != nil) ? (" " + responsabile_principale.cognome + " ") : (" - ") 
    return "O" + " - " + stringa_dirigente + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 def peso_assegnazione(persona)
    result = 0
	ga = GoalAssignment.where(person_id: persona.id, operational_goal_id: id).first
    if ga != nil
	 result = ga.wheight
	end
	return result
 end
 
 def descrizione80
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 def descrizione_completa
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe 
 end
 
 def stringa_indicatori
    stringa = ""
    indicatori.each do |g|
	 stringa += "\n" + g.nome 
	
	end
	return stringa
 end
 
 def struttura_organizzativa_id_integer
  result = 0
  if struttura_organizzativa_id != nil
   resulta = struttura_organizzativa_id
  end
 
 end
 
 def sotto_target
  result = []
  fasi.each do |f|
    result<< f
  end
  
  opere.each do |o|
    result<< o
  end
  
  return result
 end
 
 def extrapeg
	result = false
	stringa_extrapeg = "extrapeg"
	stringa = self.denominazione.gsub(/[^A-Za-z]/,"").strip.downcase
	if stringa.include? stringa_extrapeg
		result = true
	end
	return result
 end
 
 def stringa_extrapeg
    result = ""
	
	if (obiettivo_extrapeg != nil) && ( obiettivo_extrapeg )
	 result = " (extrapeg )"
	end
	return result
 
 end
 
 def ha_vincoli
    result = false
	
	if altri_responsabili.length > 0
		result = true
	end
	
	if assegnatari.length > 0
		result = true
	end
	
	if fasi.length > 0
		result = true
	end
	
	if opere.length > 0
		result = true
	end
	
	if indicatori.length > 0
		result = true
	end
	
	if !result
	  # se ci sono valutazioni credo convenga cancellarle
	  v = valutazione
	  if v != nil
	    v.destroy
	  end
	  # se non ha assegnatari allora non dovrebbe avere neanche valutazioni_x_dipendenti
	  valutazioni_x_dipendenti.each do |v|
	   v.destroy
	  end
	
	end
	
	return result
 end
 
end
