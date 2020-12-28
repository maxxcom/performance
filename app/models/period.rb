class Period < ApplicationRecord

def self.periodo_aperto( nome_periodo )
	result = true
	now = DateTime.current.to_date
    p = Period.where(denominazione: nome_periodo).first
	if p != nil
      if p.stato_aperto || (now > p.data_inizio && now < p.data_fine)
	     result = true
	  else
	     result = false
	  end
	end  
	return result
end 



end
