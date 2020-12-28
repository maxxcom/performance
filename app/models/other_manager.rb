class OtherManager < ApplicationRecord

belongs_to :altro_responsabile, class_name: 'Person', foreign_key: 'altro_responsabile_id'
belongs_to :obiettivo_operativo, class_name: 'OperationalGoal', foreign_key: 'obiettivo_operativo_id'


end
