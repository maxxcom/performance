class Valutation < ApplicationRecord
 belongs_to :person, foreign_key: 'person_id', required: true
 belongs_to :vfactor, foreign_key: 'vfactor_id', required: true

end
