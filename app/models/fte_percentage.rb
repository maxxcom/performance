class FtePercentage < ApplicationRecord

belongs_to :category, class_name: 'Category', foreign_key: 'category_id', required: false 

def self.peso_categorie

  result = {}
  FtePercentage.all.each do | f |
    
	if f.category != nil
	  result[ f.category.denominazione.to_s ] = f.percentuale
    end
  end
  
  return result

end

end
