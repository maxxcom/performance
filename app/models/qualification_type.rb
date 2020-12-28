class QualificationType < ApplicationRecord
 has_many :people, class_name: 'Person', inverse_of: 'qualification', foreign_key: 'qualification_type_id'
 has_many :valuation_qualification_percentages, class_name: 'ValuationQualificationPercentage', inverse_of: 'qualification_type', foreign_key: 'qualification_type_id'
 
end
