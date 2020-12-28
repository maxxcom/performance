class SimpleActionAssignment < ApplicationRecord

 belongs_to :persona, class_name: 'Person', foreign_key: 'person_id'
 belongs_to :azione, class_name: 'SimpleAction', foreign_key: 'simple_action_id'
 
end
