class SimpleAction < ApplicationRecord

 has_many :simple_action_assignments, class_name: 'SimpleActionAssignment', foreign_key: 'simple_action_id', dependent: :destroy
 has_many :assegnatari, :through => :simple_action_assignments, :source => :persona
 belongs_to :fase, class_name: 'Phase', foreign_key: 'fase_id', required: false
 
 belongs_to :responsabile_principale, class_name: 'Person', foreign_key: 'responsabile_principale_id'
 
 has_many :indicatori, class_name: 'Gauge', as: :target, dependent: :destroy
 has_one :valutazione, class_name: 'ItemEvaluation', as: :target, dependent: :destroy
 
 has_many :opere, class_name: 'Opera', as: :target
 has_many :valutazioni_x_dipendenti, class_name: 'TargetDipendenteEvaluation', as: :target
 
 has_many :office_target_collaborations, as: :target, dependent: :destroy
 has_many :offices,  -> { distinct }, class_name: 'Office', through: :office_target_collaborations
 
 def tipo
   return "Azione" 
 end
 
 def valore_totale
    valore = 0
	numeratore = 0
	denominatore = 0
    
	indicatori.each do |ind|
	 numeratore = numeratore + (ind.valore_misurazione != nil ? ind.valore_misurazione.to_f : 0 )
	 denominatore = denominatore + 1
	end
	
	if denominatore > 0
	 valore = numeratore/denominatore
	end
	return valore
	
 end
 
 def self.cerca(stringa)
    sa = nil
	if stringa != nil
     sa = SimpleAction.where("denominazione LIKE ?", stringa+"%").first
	end
	return sa
 end
 
 def attivita_ordinaria
    result = false
    if fase != nil
	  result = fase.attivita_ordinaria
	else
	  result = false
	end
    return result
    
 end
 
 def peso_assegnazione(persona)
    result = 0
	saa = SimpleActionAssignment.where(person_id: persona.id, simple_action_id: id).first
    if saa != nil
	 result = saa.wheight
	end
	return result
 end
 
 def stringa_indicatori
    stringa = ""
    indicatori.each do |g|
	 stringa += "\n" + g.nome 
	
	end
	return stringa
 end
 
 def stringa_extrapeg
    result = ""
	if fase != nil
	  result = fase.stringa_extrapeg
	end
	
	return result
 
 end
 
 def denominazione80
    result = denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
    if generato_da_indicatore
	 result = "*" + result
	end
    return result
end

 def descrizione80
    result = descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
    
    return result
end

 def descrizione_completa
    result = descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe + stringa_extrapeg
    
    return result
end
 
def id_denominazione80
    return id.to_s + "-" + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
end

 def id_class
 
    return id.to_s + "-" + "SimpleAction"
 end

def tipo_dirigente_denominazione80
    stringa_dirigente = (responsabile_principale != nil) ? (" " + responsabile_principale.cognome + " ") : (" - ") 
    return "A" + " - " + stringa_dirigente + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end

def denominazione_completa
	result = ""
    result = result + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù\/\']/,"").strip.html_safe
	if self.fase  != nil
		if self.fase.flag_variazione_peg
			result = result + "(*) "
		end
	end
	if generato_da_indicatore
	 result = "*" + result
	end
	return result
end

def flag_variazione_peg 
    result = false
 
    if  self.fase != nil
	  if self.fase.flag_variazione_peg
	    result = true
	  end
	end
    return result

end 
 
def obiettivo_operativo_denominazione_completa
	result = ""
	if self.fase != nil
		fase = self.fase
		if fase.obiettivo_operativo_fase != nil
				result = fase.obiettivo_operativo_fase.denominazione_completa
		end
	end
	return result
end
		
def fase_denominazione_completa
	result = ""
	if self.fase != nil
		resul = self.fase.denominazione_completa
	end
	return result
end

 
 def sotto_target
  result = []
    
  opere.each do |o|
    result<< o
  end
  
  return result
 end
 
 def codice
	
	check_sum = 0
	
	self.id.to_s.split('').each do |c|
	  check_sum = (check_sum + c.to_i)%10
	end
    return "AZ-" + self.id.to_s.rjust(5, '0') + check_sum.to_s
 end
 
 def ha_vincoli
    result = false
	
	if assegnatari.length > 0
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
