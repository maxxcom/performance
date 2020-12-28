class ValuationQualificationPercentage < ApplicationRecord
 belongs_to :valuation_area
 belongs_to :qualification_type
 belongs_to :category
 
 def self.percentuale_obiettivi(person)
    result = 1
	categoria = Category.where(denominazione: person.categoria_ABCD).first
	area_valutazione = ValuationArea.where(denominazione: "Raggiungimento obiettivi individuali/di gruppo").first
    vqp = ValuationQualificationPercentage.where(qualification_type: person.qualification, category: categoria, valuation_area: area_valutazione).first
	if vqp != nil
	 result = vqp.percentuale
	end
	return result
 end
 
 def self.percentuale_pagella(person)
    result = 1
	categoria = Category.where(denominazione: person.categoria_ABCD).first
	area_valutazione = ValuationArea.where(denominazione: "Competenze dimostrate e comportamenti organizzativi").first
    vqp = ValuationQualificationPercentage.where(qualification_type: person.qualification, category: categoria, valuation_area: area_valutazione).first
	if vqp != nil
	 result = vqp.percentuale
	end
	return result
 end
 
 def self.percentuale_obiettivi_categoria(categoria)
    result = 1
	categoria = Category.where(denominazione: categoria).first
	area_valutazione = ValuationArea.where(denominazione: "Raggiungimento obiettivi individuali/di gruppo").first
    vqp = ValuationQualificationPercentage.where(category: categoria, valuation_area: area_valutazione).first
	if vqp != nil
	 result = vqp.percentuale
	else  #male che vada divide al 50 per cento
	 result = 1
	end
	return result
 end
 
 def self.percentuale_pagella_categoria(categoria)
    result = 1
	categoria = Category.where(denominazione: categoria).first
	area_valutazione = ValuationArea.where(denominazione: "Competenze dimostrate e comportamenti organizzativi").first
    vqp = ValuationQualificationPercentage.where(category: categoria, valuation_area: area_valutazione).first
	if vqp != nil
	 result = vqp.percentuale
	else  #male che vada divide al 50 per cento
	 result = 1
	end
	return result
 end
 
 
 
end
