class GoalAssignment < ApplicationRecord

 belongs_to :persona, class_name: 'Person', foreign_key: 'person_id'
 belongs_to :obiettivo, class_name: 'OperationalGoal', foreign_key: 'operational_goal_id'

 end
