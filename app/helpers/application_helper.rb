module ApplicationHelper

def target_selezionato( selezionato )

 result = nil
 if selezionato.to_s.include?("-")
    tipo = selezionato.split("-")[0] 
    id = selezionato.split("-")[1] 
	
	
    case tipo 
      when "o" 
          result = OperationalGoal.find(id) 
        
    	when "f" 
    		result = Phase.find(id) 
    		
        
    	when "a" 
    		result = SimpleAction.find(id) 
    	

    end
 end	
 return result
end

end
