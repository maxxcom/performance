class TargetDipendenteEvaluation < ApplicationRecord

  belongs_to :target, polymorphic: true
  belongs_to :dipendente, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :dirigente, class_name: 'Person', foreign_key: 'dirigente_id'
 
end
