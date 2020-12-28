class Opera < ApplicationRecord

belongs_to :target, polymorphic: true, required: false
belongs_to :responsabile, class_name: 'Person', foreign_key: 'responsabile_id'
has_many :indicatori, class_name: 'Gauge', as: :target

has_many :opera_assignments, class_name: 'OperaAssignment', foreign_key: 'opera_id', dependent: :destroy
has_many :assegnatari, :through => :opera_assignments, :source => :persona


def self.importa(file, responsabile)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	@opere = []
	@opere_modificate = []
	resp = responsabile
	informazioni = xls.info
	lista_fogli = xls.sheets
	
	lista_fogli.each do |sheetname|
	  
	  foglio_opere = xls.sheet(sheetname)
	  cella_sub = foglio_opere.cell('B',1)
	  it_is_foglio_opere = false
	  if (foglio_opere.cell('B',1) != nil)
	    it_is_foglio_opere = foglio_opere.cell('B',1).strip.downcase == "sub"
	  end
	  puts sheetname
	  puts foglio_opere.cell('B',1)
	  puts it_is_foglio_opere
	  if (it_is_foglio_opere)
	  
	    # E UN FOGLIO OPERE
	    last_row    = foglio_opere.last_row
	
	    
	    index_p = 1
	    for row in 3..last_row
		  numero = ""
		  sub = ""
		  numero = foglio_opere.cell('A', row)
		  sub = foglio_opere.cell('B', row)
		  if sub == nil
		     sub = "000"
		  end
		  if sub == 0
		     sub = "000"
		  end
		  if numero == nil
		     numero = "7840"
             sub = "P" + index_p.to_s	
             index_p = index_p + 1			 
		  end
		  if numero != nil
		    numero = numero.to_s.remove(".0")
		  end
		  if sub != nil
		    sub = sub.to_s.remove(".0")
		  end
		  descrizione = foglio_opere.cell('C', row)
		  stringa_target = foglio_opere.cell('D', row)
		  target = nil
		  lista_target = stringa_target.to_s.split("|")
		  if lista_target.length == 3
		    target = SimpleAction.where(denominazione: lista_target[2].to_s.strip, responsabile_principale_id: resp.id).first
		  elsif lista_target.length == 2
		    target = Phase.where(denominazione: lista_target[1].to_s.strip, responsabile_principale_id: resp.id).first
		  elsif lista_target.length == 1
		    target = OperationalGoal.where(denominazione: lista_target[0].to_s.strip, responsabile_principale_id: resp.id).first
		  else
		    target = nil
		  end
		  
		  puts resp.nominativo
		  
		  if (descrizione != nil) && (descrizione.length > 1) 
		   if (Opera.where('numero = ? and sub = ?', numero.to_s.to_s.remove(".0"), sub.to_s.to_s.remove(".0")).length == 0)
		     @op = Opera.create(   numero: numero.to_s.remove(".0"),
			                       sub: sub.to_s.remove(".0"),
								   descrizione: descrizione,
								   anno: Setting.where(denominazione: 'anno').first.value,
								   ente: Setting.where(denominazione: 'ente').first.value,
								   responsabile: resp)
			 # qua bisogna creare lo indicatore se la create ha funzionato
			 if @op.valid?
			  g = Gauge.new
		      g.nome = "Stato di avanzamento"
		      g.save
			  @op.indicatori<< g
			  @op.save
			 
			  # if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # @obiettivo = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # @obiettivo.opere<< @op
			  # end
			  # if (Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # @fase = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # @fase.opere<< @op
			  # end
			  # if (SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # @azione = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # @azione.opere<< @op
			  # end
			  if target != nil
			    
			       target.opere<< @op
				
			  end
			  @opere<< @op 
			 end
		   else 
			 # se esiste già lo metto in op 
			 
             @op = Opera.where('numero = ? and sub = ?', numero.to_s.to_s.remove(".0"), sub.to_s.to_s.remove(".0")).first
             if resp != nil			 
			   @op.descrizione =  descrizione
			   @op.save
			 end
			 if target != nil
			    # evito doppioni
			    if target.opere.include?(@op)
			       target.opere<< @op
				end
			 end
			 # if (OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # obiettivo = OperationalGoal.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # obiettivo.opere<< @op
			 # end
			 # if (Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # @fase = Phase.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # @fase.opere<< @op
			 # end
			 # if (SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).length > 0)
			    # @azione = SimpleAction.where('lower(denominazione) = lower(?) and responsabile_principale_id = ?', target, resp.id).first
			    # @azione.opere<< @op
			 # end
			 @opere_modificate<< @op
           end	
	      end
	      end
	   end # non è un foglio opere
	
	end
	return [@opere, @opere_modificate]
end

def self.importa_valori(file, responsabile)
    stringa_filename = file.original_filename
	extension = 'xls'
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls, :extension => extension")
	#xls = Roo::Spreadsheet.open("D:\\DATI\\Segreteria\\ControlloGestione\\Performance\\PEGImportazione\\Asquini2018.xls", :extension => extension)
	xls = Roo::Spreadsheet.open(file.path)
	@opere = []
	@opere_modificate = []
	resp = responsabile
	informazioni = xls.info
	lista_fogli = xls.sheets
	
	lista_fogli.each do |sheetname|
	  
	  foglio_opere = xls.sheet(sheetname)
	  cella_sub = foglio_opere.cell('B',2)
	  it_is_foglio_opere = false
	  if (foglio_opere.cell('B',2) != nil)
	    it_is_foglio_opere = foglio_opere.cell('B',2).strip.downcase == "sub"
	  end
	  puts sheetname
	  puts foglio_opere.cell('B',2)
	  puts it_is_foglio_opere
	  if (it_is_foglio_opere)
	  
	    # E UN FOGLIO OPERE
	    last_row    = foglio_opere.last_row
	
	    
	    index_p = 1
	    for row in 4..last_row
		  numero = ""
		  sub = ""
		  numero = foglio_opere.cell('A', row)
		  sub = foglio_opere.cell('B', row)
		  if sub == nil
		     sub = "000"
		  end
		  if sub == 0
		     sub = "000"
		  end
		  if numero == nil
		     numero = "7840"
             sub = "P" + index_p.to_s	
             index_p = index_p + 1			 
		  end
		  if numero != nil
		    numero = numero.to_s.remove(".0")
		  end
		  if sub != nil
		    sub = sub.to_s.remove(".0")
		  end
		  descrizione = foglio_opere.cell('C', row)
		  target = foglio_opere.cell('D', row)
		  
		  valore = foglio_opere.cell('AA', row)
		  if valore == nil
		    valore = 0
		  end
		  puts resp.nominativo
		  
		  if (descrizione != nil) && (descrizione.length > 1) 
		   if (Opera.where('numero = ? and sub = ?', numero.to_s.to_s.remove(".0"), sub.to_s.to_s.remove(".0")).length == 0)
		     puts "nothing to do"
		   else 
			 # se esiste già lo metto in op 
			 
             @op = Opera.where('numero = ? and sub = ?', numero.to_s.to_s.remove(".0"), sub.to_s.to_s.remove(".0")).first
			 
             if resp != nil			 
			  selezione = @op.indicatori.select {|a| a.nome.match(/^Stato di avanzamento/)}
			  if selezione.length > 0
			   indicatore = selezione[0]
			   if indicatore != nil
			     indicatore.valore_misurazione = valore * 100
				 indicatore.save
			   end
			  
			   @opere_modificate<< @op
			  end
             end	
	      end
	      end
	   end # non è un foglio opere
	 end
	end
	return [@opere, @opere_modificate]
end


def valore_totale
   valore = 0
   indicatori.each do |i|
    valore = valore + (i.valore_misurazione != nil ? i.valore_misurazione.to_f : 0 )
   end
   if indicatori.length > 0
    valore = valore / indicatori.length
   else
    valore = 0
   end
   return valore.round(2)
end

def denominazione
   stringa = ""
   stringa = stringa + numero + " "
   stringa = stringa + sub + " "
   stringa = stringa + descrizione[0..30]
   return stringa
end 

def denominazione80
    return denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80).html_safe
end

def denominazione_completa
    return denominazione.gsub(/[^0-9A-Za-z .,;:-_àèéìòù]/,"").strip.html_safe + " " + descrizione.gsub(/[^0-9A-Za-z .,;:-_àèéìòù]/,"").strip.html_safe
end

def stringa_extrapeg
    return ""
end

def descrizione80
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80).html_safe
end

def descrizione_completa
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe
end
 
def id_denominazione80
    return id.to_s + "-" + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80).html_safe
end
 

def tipo
   stringa = "Opera"
   
   return stringa
end 

def responsabile_principale
   r = responsabile  
   return r
end 

def self.cerca(stringa)
  
   # due casi : o con sub o senza sub
   op = nil
   numero = ""
   sub = "0"
   titolo_opera = ""
   m1 = /(Opera)(\s*)(\d*)(\/)(.*)(\:)(.*)/.match(stringa)
   m2 = /(Opera)(\s*)(\d*)(\:)(.*)/.match(stringa)
   if m1 != nil
    if (m1[1] == "Opera")
     numero = m1[3].strip
	 sub = m1[5].strip
	 titolo_opera = m1[7].strip
	 op = Opera.where(numero: numero, sub: sub).first
	end
   elsif m2 != nil
    if (m2[1] == "Opera")
     numero = m2[3].strip
	 titolo_opera = m2[5].strip
	 op = Opera.where(numero: numero).first
	end
   end
   
   return op
 
end

def assegnata_a (dipendente)
   result = false
   if dipendente != nil
     assegnatari.each do |a|
       if a == dipendente
	     result = true
	   end
     end
   end
   return result
end

 def peso_assegnazione(persona)
    result = 0
	oa = OperaAssignment.where(person_id: persona.id, opera_id: id).first
    if oa != nil
	 result = oa.wheight
	end
	return result
 end

def attivita_ordinaria
  return false
end

def stringa_indicatori
    stringa = ""
    indicatori.each do |g|
	 stringa += "\n" + g.nome 
	
	end
	return stringa
 end
 
 def sotto_target
  result = []
  
  
  return result
 end
 
 def codice
    check_sum = 0
	
	self.id.to_s.split('').each do |c|
	  check_sum = (check_sum + c.to_i)%10
	end
    return "OP-" + self.id.to_s.rjust(5, '0') + check_sum.to_s
 end
 
 def ha_vincoli
    result = false
	
	if assegnatari.length > 0
		result = true
	end
	
	
	if indicatori.length > 0
		result = true
	end
	
	# if !result
	  # # se ci sono valutazioni credo convenga cancellarle
	  # v = valutazione
	  # if v != nil
	    # v.destroy
	  # end
	  # # se non ha assegnatari allora non dovrebbe avere neanche valutazioni_x_dipendenti
	  # valutazioni_x_dipendenti.each do |v|
	   # v.destroy
	  # end
	
	# end
	
	return result
 end
 
end
