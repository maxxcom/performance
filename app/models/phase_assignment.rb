class PhaseAssignment < ApplicationRecord

 belongs_to :persona, class_name: 'Person', foreign_key: 'person_id'
 belongs_to :fase, class_name: 'Phase', foreign_key: 'phase_id'

end
