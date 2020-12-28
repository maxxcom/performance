module SessionsHelper

# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
	#registra('LOGIN')
  end
  
  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= Person.find_by(id: session[:user_id])
  end
  
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
  
  def super_user?
    current_user.cognome.include? "CHIANDONE"
	true
  end
  
  def current_user_group
    result = "-"
    if current_user.nil?
	 result = "-"
	else
     result = current_user.office != nil ? current_user.office.nome : "-"
	 current_user.altri_uffici.each do |uff|
	   result = result + ", " uff.nome
	 end
	end
	result
  end
  
  def current_user_admin?
    result = false
	if logged_in?
     if (current_user_group.include? "SEGRETERIA GENERALE") || (current_user_group.include? "CONTROLLO DI GESTIONE")
	   result = true
	 end
	 if current_user.cognome.include? "CHIANDONE"
	    result = true
	 end
    end
	result
  end
  
  def log_out
    #registra('LOGOUT')
    session.delete(:user_id)
    @current_user = nil
  end
  
  def filtro_dirigenti
    dirigenti = []
	if logged_in?
     if (current_user_group.include? "SEGRETERIA GENERALE") || (current_user_group.include? "CONTROLLO DI GESTIONE")
	   lista1 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Segretario"} )
	   lista2 =  Person.joins(:qualification).where(qualification_types: { denominazione: "Dirigente"} )
	   dirigenti = lista1 + lista2
	 else
	   if current_user.qualification == QualificationType.where(denominazione: 'Dirigente').first
	   # se è un dirigente nella lista vede se stesso
	    dirigenti<< current_user
	   else
	    # se non e dirigente cerco l'ufficio apicale
	    lev = current_user.ufficio
		if lev != nil
	      top = lev.parent
	      while top != nil
		    lev = top
		    top = lev.parent
		  end
		  if lev != nil && lev.director != nil
		    dirigenti<< lev.director
		  end
		end
	   end
	 end
    end
	
	return dirigenti
  
  end
  
end
