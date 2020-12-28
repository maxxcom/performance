class Vfactor < ApplicationRecord

 def peso(person)
        result = 0.0
		tipo = person.qualification.denominazione
        case tipo
        when "Dirigente"
         result = peso_dirigenti 
        when "Segretario"
         result = peso_sg
        when "P.O."
         result = peso_po
        when "Preposto"
         result = peso_preposti
        when "NonPreposto"
         result = peso_nonpreposti
        end
		return result
 end

end
