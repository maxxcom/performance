class Office < ApplicationRecord

 has_many :people,  inverse_of: 'ufficio'
 belongs_to :director, class_name: 'Person', foreign_key: 'director_id', required: false 
 belongs_to :office_type, class_name: 'OfficeType', foreign_key: 'office_type_id', required: false
 belongs_to :parent, class_name: 'Office', foreign_key: 'parent_id', required: false
 has_many :children, class_name: 'Office', foreign_key: 'parent_id', inverse_of: 'parent'
 
 has_many :office_target_collaborations, dependent: :destroy
 has_many :operational_goals, -> { distinct }, :through => :office_target_collaborations, :source => :target, source_type: 'OperationalGoal'
 has_many :phases, -> { distinct }, :through => :office_target_collaborations, :source => :target, source_type: 'Phase'
 has_many :simple_actions, :through => :office_target_collaborations, :source => :target, source_type: 'SimpleAction'
 
 has_many :obiettivi_operativi, class_name: 'OperationalGoal', inverse_of: 'struttura_organizzativa', foreign_key: 'struttura_organizzativa_id'
 
 def dipendenti
    @dips = []
    people.each do |d|
	  @dips<< d
	end
	
	# questo è un punto discutibile
	# forse meglio mettere un dipendente all'interno dell'ufficio che dirige
	#if self.director != nil
	# @dips<< self.director
	#end
	# oppure aggiungere senza duplicazione
	if director != nil
	 @dips = @dips | [director]
	end
	children.each do |o|
	 o.dipendenti.each do |p|
	  @dips<< p
	 end
	end
	return @dips
 end
 
 def dipendenti_ufficio
    @dips = []
    people.each do |d|
	  @dips<< d
	end
	# questo è un punto discutibile
	# forse meglio mettere un dipendente all'interno dell'ufficio che dirige
	#if self.director != nil
	# @dips<< self.director
	#end
	# oppure aggiungere senza duplicazione
	if director != nil
	 @dips = @dips | [director]
	end
	
	return @dips
 end

 def dirigente
    
	sopra = self
	while sopra != nil
	 top = sopra
     sopra = sopra.parent
	 
    end
    if top != nil
      direttore = top.director
    end
    return direttore	
 end 
 
 def ufficio_apicale
    sopra = self
	max = 5
	index = 0
	while (sopra.parent != nil) && (index < max)
      sopra = sopra.parent
	  index = index + 1
	end
	puts "ufficio_apicale : " + index.to_s + " " + nome
	return sopra
 end
 
 def self.ufficio_simile(nome)
    max = 0
	o_max = nil
    Office.all.each do |o|
	 res = Office.compara_stringhe(nome, o.nome)
	 if res > max
	  max = res
	  o_max = o
	 end
	end
    return o_max
 end
 
 def self.cerca(nome_grezzo)
  result = nil
  nome = nome_grezzo.to_s
  # lista = Office.where('lower(nome) = lower(?)', nome)
  # nome_accenti = nome.tr("è", "E'")
  # nome_accenti = nome_accenti.sub("é", "E'")
  # nome_accenti = nome_accenti.sub("à", "A'")
  # lista2 = Office.where('lower(nome) = lower(?)', nome_accenti)
  # lista = lista + lista2
  # if lista.length > 0
    # result = lista.first
  # else
    # result = nil
  # end
  valore = 0
  soglia = (Setting.where(denominazione: 'soglia_comparazione_stringhe').first != nil ? Setting.where(denominazione: 'soglia_comparazione_stringhe').first.value.to_f : 0.2 )
  ufficio =  nil
  # prima cerchiamo una corrispondenza precisa
  ufficio = Office.where(nome: nome.upcase).first
  
  # l'approssimazione crea più problemi che vantaggi
  #
  if ufficio == nil
    uffici = Office.all
    uffici.each do |u|
     val = String::Similarity.levenshtein(u.nome.to_s.upcase, nome.upcase)
     if (val > valore) && (val > soglia)
       valore = val
	   ufficio = u
     end
    end
  end
  result = ufficio
  return result
 end
 
 def self.compara_stringhe(a, b)
	 indice = 0
	 # a_temp = a.delete(' ').delete('.').upcase
	 # b_temp = b.delete(' ').delete('.').upcase
	 a_temp = a.upcase
	 b_temp = b.upcase
	 a_temp.each_char do |ch|
	  if b_temp.include? ch
	   b_temp = b_temp.delete(ch)
	   indice = indice + (a.length - ( (a_temp.index(ch) != nil ? a_temp.index(ch) : 0)  - (b.index(ch) != nil ? b.index(ch) : 0)).abs)
	   indice = indice + 1
	   
	  end
	end
	risultato = indice - 10*(a.length - b.length).abs
	return risultato
  end
  


def self.servizi

 result = []
 servizio = OfficeType.where(denominazione: "Servizio").first
 dipartimento = OfficeType.where(denominazione: "Dipartimento").first
 Office.all.each do |o|
  if o.office_type == servizio || o.office_type == dipartimento
   result<< o
  end
 end

 return result
end



end
