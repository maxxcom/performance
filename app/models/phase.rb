class Phase < ApplicationRecord

 has_many :phase_assignments, class_name: 'PhaseAssignment', foreign_key: 'phase_id', dependent: :destroy
 has_many :assegnatari, :through => :phase_assignments, :source => :persona
 belongs_to :obiettivo_operativo_fase, class_name: 'OperationalGoal', foreign_key: 'operational_goal_id', required: false
 has_many :azioni, class_name: 'SimpleAction', foreign_key: 'fase_id', dependent: :destroy
 has_many :opere, class_name: 'Opera', as: :target
 
 belongs_to :responsabile_principale, class_name: 'Person', foreign_key: 'responsabile_principale_id'
 
 has_many :indicatori, class_name: 'Gauge', as: :target, dependent: :destroy
 has_one :valutazione, class_name: 'ItemEvaluation', as: :target, dependent: :destroy
 
 has_many :valutazioni_x_dipendenti, class_name: 'TargetDipendenteEvaluation', as: :target
 
 has_many :office_target_collaborations, as: :target, dependent: :destroy
 has_many :offices, -> { distinct }, class_name: 'Office', through: :office_target_collaborations

 def tipo
   return "Fase" 
 end
 
 def valore_totale
    valore = 0
	numeratore = 0
	denominatore = 0
	
	if azioni.length > 0
      azioni.each do |azione|
	     numeratore = numeratore + azione.valore_totale * (azione.peso != nil ? azione.peso : 1.0/azioni.length)
	  end
	  azioni.each do |azione|
	     denominatore = denominatore + (azione.peso != nil ? azione.peso : 1.0/azioni.length)
	  end
	  if denominatore > 0
	   valore = numeratore/denominatore
	  end
	elsif
	  indicatori.each do |ind|
	    numeratore = numeratore + (ind.valore_misurazione != nil ? ind.valore_misurazione.to_f : 0.0 )
	    denominatore = denominatore + 1
	  end
	
	  if denominatore > 0
	    valore = numeratore/denominatore
	  end
	end
	
	return valore
 end
 
 def self.cerca(stringa)
    f = nil
	if stringa != nil
     f = Phase.where("lower(denominazione) LIKE ?", stringa.strip.downcase + "%").first
	 if f == nil
	   f = Phase.where("lower(denominazione) LIKE ?", ("Fase AC - " + stringa.strip).downcase + "%").first
	 end
	end
	return f
 end
 
  def self.cerca2(stringa, responsabile)
    f = nil
	if ((stringa != nil) && (responsabile != nil))
	 
     f = Phase.where("lower(denominazione) LIKE ? AND responsabile_principale_id = ?", stringa.strip.downcase+"%", responsabile.id).first
	 if f == nil
	   f = Phase.where("lower(denominazione) LIKE ? AND responsabile_principale_id = ?", ("Fase AC - " +stringa.strip).downcase+"%", responsabile.id).first
	 end
	end
	return f
 end
 
 def attivita_ordinaria
    result = false
    if obiettivo_operativo_fase != nil
	  result = obiettivo_operativo_fase.attivita_ordinaria
	else
	  result = false
	end
    return result
 end
 
 def stringa_extrapeg
    result = ""
	
	if (obiettivo_operativo_fase != nil)
	 result = obiettivo_operativo_fase.stringa_extrapeg
	end
	return result
 
 end
 
 def denominazione80
    risultato = ""
    if denominazione != nil
	  risultato = denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
	end
	if generato_da_indicatore
	 risultato = "*" + risultato
	end
    return risultato
 end
 
 def descrizione80
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 def descrizione_completa
    return descrizione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.html_safe + stringa_extrapeg
 end
 
 def id_denominazione80
    risultato = ""
    if denominazione != nil
	  risultato = id.to_s + "-" + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
	end
	if generato_da_indicatore
	 risultato = "*" + risultato
	end
    return risultato
 end
 
  def id_class
 
    return id.to_s + "-" + "Phase"
 end
 
 def tipo_dirigente_denominazione80
    stringa_dirigente = (responsabile_principale != nil) ? (" " + responsabile_principale.cognome + " ") : (" - ") 
    return "F" + " - " + stringa_dirigente + denominazione.gsub(/[^0-9A-Za-z .,;-_àèéìòù]/,"").strip.first(80)
 end
 
 def denominazione_completa
	result = ""
    result = result + self.denominazione.gsub(/[^0-9A-Za-z .,;:-_àèéìòù\/\']/,"").strip.html_safe
	if  obiettivo_operativo_fase != nil
	  if obiettivo_operativo_fase.flag_variazione_peg
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
 
    if  self.obiettivo_operativo_fase != nil
	  if self.obiettivo_operativo_fase.flag_variazione_peg
	    result = true
	  end
	end
    return result
 end 
 
 def peso_assegnazione(persona)
    result = 0
	fa = PhaseAssignment.where(person_id: persona.id, phase_id: id).first
    if fa != nil
	 result = fa.wheight
	end
	return result
 end
 
 def codice
    check_sum = 0
	
	self.id.to_s.split('').each do |c|
	  check_sum = (check_sum + c.to_i)%10
	end
    return "FA-" + self.id.to_s.rjust(5, '0') + check_sum.to_s
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
  azioni.each do |a|
    result<< a
  end
  
  opere.each do |o|
    result<< o
  end
  
  return result
 end
 
 def ha_vincoli
    result = false
	
	if assegnatari.length > 0
		result = true
	end
	
	if azioni.length > 0
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
