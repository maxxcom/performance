class ValuationArea < ApplicationRecord
 has_many :valuation_qualification_percentages, class_name: 'ValuationQualificationPercentage', inverse_of: 'valuation_area', foreign_key: 'valuation_area_id'
 
end
