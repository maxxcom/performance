class Gauge < ApplicationRecord
 belongs_to :target, polymorphic: true, required: false
 
def tipo
   return "Indicatore" 
 end
 
def self.importa(file)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	informazioni = xls.info
	xls.sheets
	@fasi = []
    @azioni = []
	@indicatori_obiettivi = []
	@indicatori_fasi = []
	@indicatori_azioni = []
	
	elabora = false
	xls.each_with_pagename do |name, sheet|
	  case name 
	  when "Obiettivi" 
	     foglio_obiettivi = xls.sheet('Obiettivi')
		 flag_di_gruppo = true
		 elabora = true
	  when "Obiettivi di struttura"
	     foglio_obiettivi = xls.sheet('Obiettivi di struttura')
		 flag_di_gruppo = true
		 elabora = true
	  when "Obiettivi Individuali"
	     foglio_obiettivi = xls.sheet('Obiettivi Individuali')
		 flag_di_gruppo = false
		 elabora = true
	  else 
	     elabora = false
	  end
	  
	  if elabora
	
	    foglio_obiettivi.cell('A',2) == 'Titolo'
	    last_row    = foglio_obiettivi.last_row
	    @target_non_trovati = []
	    
	    for row in 3..last_row
		  titolo_grezzo = foglio_obiettivi.cell('A', row)
		  if titolo_grezzo != nil
		   titolo = titolo_grezzo.strip
		  else
		   titolo = nil
		  end
		  descrizione = foglio_obiettivi.cell('B', row)
		  tipo_grezzo = foglio_obiettivi.cell('C', row)
		  if tipo_grezzo != nil
		   #tipo = tipo_grezzo.strip.strip
		   tipo = tipo_grezzo.gsub(/[^0-9A-Za-z]/, '')
		  else
		   tipo = nil
		  end
		  servizio = foglio_obiettivi.cell('D', row)
		  indicatori_stringa = foglio_obiettivi.cell('G', row).to_s
		  puts "INDICATORI: " + indicatori_stringa
		  indicatori = indicatori_stringa.split("\n")
		  indicatori.delete_if {|x| x.length <1  } 
		  if foglio_obiettivi.cell('E', row) != nil
		   responsabile = foglio_obiettivi.cell('E', row).gsub(/[^0-9 A-Za-z]/, '')
		  else
		   responsabile = " "
		  end
		  peso = foglio_obiettivi.cell('K', row)
		  
		  if (tipo == 'Obiettivo') || (tipo.downcase == 'Obiettivoindividuale'.downcase)
		    # resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			resp = Person.cerca_dirigente(responsabile)
			puts "responsabile"
			puts responsabile
			if resp != nil
			 # Operational_goals.joins(:responsabile_principale).where('operational_goals.denominazione = ? AND people.cognome = ?', denominazione, resp.cognome)
			 if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 1)
		      og = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			  if indicatori != nil
			   
			     io = Hash.new
			     io[:obiettivo] = og
			     io[:indicatori] = indicatori
				 # due casi
				 # un indicatore solo viene messo come indicatore
				 # piu indicatori vengono trasformati in altrettante fasi con un indicatore ciascuna
				 
			     @indicatori_obiettivi<< io
				 if indicatori.length > 1
				   indicatori.each do |i|
				   esiste_gia = false
				   l = og.fasi
				   # cerco nelle fasi
				   l.each do |fase|
				    esiste_gia = esiste_gia || (fase.denominazione.eql? i)
				    
				   end
				   if !esiste_gia 
				     g = Gauge.new
				     g.nome = i
				     g.save
				     f = Phase.create(denominazione: i,
			                       descrizione: ("Fase_indicatore - " + i),
								   anno: Setting.where(denominazione: "anno").first.value,
								   peso: 1.0,
								   ente: Setting.where(denominazione: "ente").first.value,
								   obiettivo_operativo_fase: og,
								   generato_da_indicatore: true,
								   responsabile_principale: resp)
					 
					 f.indicatori<< g
					 f.save
					 og.fasi<< f
				     og.save
				   else
				     puts "ESISTE GIA indicatore di obiettivo"
					 puts i
					 puts "--"
				   end
				 end
				end
				if indicatori.length == 1
				  esiste_gia = false
				  l = og.indicatori
				  l.each do |ind|
				    esiste_gia = esiste_gia || (ind.nome.eql? indicatori[0])
		     	  end
				  if !esiste_gia 
				     g = Gauge.new
				     g.nome = indicatori[0]
				     g.save
					 og.indicatori<< g
					 og.save
				  end
				end
			 end
			else 
			 # se non esiste lo obiettivo
             @target_non_trovati<< titolo	
            end	
           end # if di resp != nil se non ho responsabile non faccio niente			
		  end
		  # mi baso sul fatto che nel foglio Excel ci sia sempre prima l'obiettivo e poi le sue fasi ed azioni
		  if tipo == 'Fase'
		    #resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			resp = Person.cerca_dirigente(responsabile)
			f = Phase.cerca2(titolo.strip, resp)
		    
			if f != nil
			  if indicatori != nil
			   
			     io = Hash.new
			     io[:fase] = f
			     io[:indicatori] = indicatori
			     @indicatori_fasi<< io
				 
				 # si decide che per ogni indicatore sotto una fase si crea una azione omonima
				 # in modo da avere un indicatore per ogni target
				 # indicatori.each do |i|
				  # esiste_gia = false
				  # l = f.indicatori
				  # l.each do |ind|
				   # esiste_gia = esiste_gia || (ind.nome.eql? i)
				  # end
				  # if !esiste_gia 
				    # g = Gauge.new
				    # g.nome = i
				    # g.save
				    # f.indicatori<< g
					# f.save
				  # else
				    # puts "ESISTE GIA indicatore di fase"
					# puts i
					# puts "--"
				  # end
			     # end
				 if indicatori.length > 1
				  indicatori.each do |i|
				    esiste_gia = false
				    l = f.azioni
				    # cerco nelle azioni della fase
				    l.each do |azione|
				     esiste_gia = esiste_gia || (azione.denominazione.eql? i)
				    
				    end
				    if !esiste_gia 
				      g = Gauge.new
				      g.nome = i
				      g.save
				      a = SimpleAction.create(denominazione: i,
			                       descrizione: ("Azione_indicatore - " + i),
								   anno: Setting.where(denominazione: "anno").first.value,
								   peso: 1.0,
								   ente: Setting.where(denominazione: "ente").first.value,
								   fase: f,
								   generato_da_indicatore: true,
								   responsabile_principale: resp)
					 
					  a.indicatori<< g
					  a.save
					  f.azioni<< a
				      f.save
					else
				    puts "ESISTE GIA indicatore di obiettivo"
					puts i
					puts "--"
				   end
				  end
				end  # fine di if indicatori.length > 1
				if indicatori.length == 1
				  ind = indicatori.first
				  esiste_gia = false
				  f.indicatori.each do | i |
			        esiste_gia = esiste_gia || (i.nome.eql? ind)
				  end
				  if !esiste_gia 
				     g = Gauge.new
				     g.nome = ind
				     g.save
				     f.indicatori<< g
					 f.save
				  else
				     puts "ESISTE GIA indicatore di fase"
					 puts ind
					 puts "--"
				   end
			    
				end
			 end
			else
			  # se non esiste 
			  @target_non_trovati<< titolo
			end
		  end
		  if tipo == 'Azione'
		    # resp = Person.where('lower(cognome) = lower(?)', responsabile).first
			resp = Person.cerca_dirigente(responsabile)
		    if (SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).length == 1)
		      a = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', titolo, resp.id).first
			  if indicatori != nil
			   
			     io = Hash.new
			     io[:azione] = a
			     io[:indicatori] = indicatori
			     @indicatori_azioni<< io
				 # indicatori.each do |i|
				  # esiste_gia = false
				  # l = a.indicatori
				  # l.each do |ind|
				   # esiste_gia = ind.nome.eql? i
				  # end
				  # if !esiste_gia 
				    # g = Gauge.new
				    # g.nome = i
				    # g.save
				    # a.indicatori<< g
					# a.save
				  # end
			     # end
				 
				 indicatori.each do |i|
				   esiste_gia = false
				   
				   # controllo di non aver già creato azioni fittizie
				   azioni = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', "Azione_indicatore - " + i, resp.id)
				   if azioni.length > 0
				     esiste_gia = true
				   end
				   a.indicatori.each do | ind |
				    esiste_gia = esiste_gia || (ind.nome.eql? "Azione_indicatore - " + i) || (ind.nome.eql? i)
				   end
				   if !esiste_gia 
				     g = Gauge.new
				     g.nome = i
				     g.save
				     a = SimpleAction.create(denominazione: i,
			                       descrizione: ("Azione_indicatore - " + i),
								   anno: Setting.where(denominazione: "anno").first.value,
								   peso: 1.0,
								   ente: Setting.where(denominazione: "ente").first.value,
								   fase: f,
								   generato_da_indicatore: true,
								   responsabile_principale: resp)
					 
					 a.indicatori<< g
					 a.save
					 f.azioni<< a
				     f.save
					 else
				     puts "ESISTE GIA indicatore di obiettivo"
					 puts i
					 puts "--"
				   end
				 end
			   
			 end
			else
			 @target_non_trovati<< titolo
			end
		  end
	  end
	end # if elabora
	
	end # each_with_pagename , ciclo sui fogli di calcolo
	return [@indicatori_obiettivi, @indicatori_fasi, @indicatori_azioni, @target_non_trovati]
end

def nome80
    return nome.to_s.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80).html_safe
end

def nome_completo
    return nome.to_s.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe
end

def denominazione
	return nome.to_s.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe
end

def descrizione80
    return descrizione.to_s.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80).html_safe
end

def descrizione_completa
    return descrizione.to_s.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe
end

end
