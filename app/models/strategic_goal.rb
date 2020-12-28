class StrategicGoal < ApplicationRecord

has_many :obiettivi_operativi, class_name: 'OperationalGoal', foreign_key: 'obiettivo_strategico_id', inverse_of: 'obiettivo_strategico_padre'
end
