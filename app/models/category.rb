class Category < ApplicationRecord
 has_many :valuation_qualification_percentages, class_name: 'ValuationQualificationPercentage', inverse_of: 'category', foreign_key: 'category_id'
 
 
 def self.categoria_pulita(stringa)
    result = stringa
	if stringa != nil 
      if stringa.start_with?('cat ')
        result =  stringa[4]
      end
	  if stringa.length == 2 && (stringa[1].match(/[0-9]/) != nil) 
        result = 	stringa[0]
	  
	  end
	  if stringa.start_with?("PL") && stringa.length > 2 
	     result = stringa[0..2]
	  end
	  if stringa.match(/[A-Z][0-9][A-Z][0-9]*/)
	     result = stringa[0]
	  end
	end
	return result
 end
 
end
