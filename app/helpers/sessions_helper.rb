module SessionsHelper

# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
	registra('LOGIN')
  end
  
  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= Person.find_by(id: session[:user_id])
  end
  
  def change_user(person)
    registra('CHANGE USER FROM ' + current_user.id.to_s + "-" + current_user.nominativo + " TO " + person.nominativo)
    session.delete(:user_id)
    @current_user = nil
    @current_user = person
	session[:user_id] = person.id
  end
  
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
  
  def super_user?
    result = false
    result = (current_user.abilitato == 3)
	return result
  end
  
  def current_user_group
    result = "-"
    if current_user.nil?
	 result = "-"
	else
     result = current_user.ufficio != nil ? current_user.ufficio.nome : "-"
	 result = result + (current_user.dirige.first != nil ? current_user.dirige.first.nome : "-")
	end
	result
  end
  
  def current_user_admin?
    result = false
	if logged_in?
     # if (current_user_group.include? "SEGRETERIA GENERALE") || (current_user_group.include? "CONTROLLO DI GESTIONE")
	   # result = true
	 # end
	 if current_user.cognome.include? "CHIANDONE"
	    result = true
	 end
	 if current_user.abilitato == 3
	    result = true
	 end
    end
	result
  end
  
  def log_out
    registra('LOGOUT')
    session.delete(:user_id)
    @current_user = nil
  end
  
  def filtro_dirigenti
    dirigenti = []
	if logged_in?
     if (super_user?)
	   lista1 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Segretario"} )
	   lista2 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Dirigente"} )
	   dirigenti = lista1 + lista2
	 else
	   if ((current_user.qualification == QualificationType.where(denominazione: 'Dirigente').first) || (current_user.qualification == QualificationType.where(denominazione: 'Segretario').first ))
	   # se è un dirigente nella lista vede se stesso più i deleganti
	    current_user.deleganti.each do | p |
		  dirigenti |=  [p]
		end
	    dirigenti |= [current_user]
	   else
	    # se non e dirigente cerco l'ufficio apicale
		current_user.deleganti.each do | p |
		  dirigenti |= [p]
		end
	    lev = current_user.ufficio
		
		# questo non ha senso, devo prendere solo quelli della delega
		# if lev != nil
	      # top = lev.parent
	      # while top != nil
		    # lev = top
		    # top = lev.parent
		  # end
		  # if lev != nil && lev.director != nil
		    # dirigenti |= [lev.director]
		  # end
		# end
	   end
	 end
    end
	
	return dirigenti
  
  end
  
  def mostra_tutto_in_aggiungi_target?
    result = true
    settaggio = Setting.where(denominazione: "mostra_tutto_in_aggiungi_target").first
	if settaggio != nil 
	  result = settaggio.value.to_s.eql? "1"
	end
	return result
  
  end
  
  def mostra_opere_in_aggiungi_target?
    result = true
    settaggio = Setting.where(denominazione: "mostra_opere_in_aggiungi_target").first
	if settaggio != nil 
	  result = settaggio.value.to_s.eql? "1"
	end
	return result
  
  end
  
  def spezza_stringa(stringa, n)
  
   # spezza la stringa con dei \n in tratti non più lunghi di n caratteri
   # senza spezzare le singole parole
     
	 stringa_spezzata =  ""
     parole = stringa.split(" ")
	 line = ""
	 parole.each do | p |
	    if line.length + p.length + 1 < n
		  line = line + " " + p
		else
		  stringa_spezzata = stringa_spezzata + line + "\n"
		  line = "" + p
		end
	 end
	 stringa_spezzata = stringa_spezzata + line
	 
	 return stringa_spezzata
  end
  
  def periodo_assegnazione_aperto
    return Period.periodo_aperto("ASSEGNAZIONE")
  end
  
  def periodo_inserimento_aperto
    return Period.periodo_aperto("INSERIMENTO")
  end
  
  def periodo_misurazione_aperto
    return Period.periodo_aperto("MISURAZIONE")
  end
  
  def periodo_valutazione_aperto
    return Period.periodo_aperto("VALUTAZIONE")
  end
end
