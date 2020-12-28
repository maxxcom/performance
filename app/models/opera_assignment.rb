class OperaAssignment < ApplicationRecord

 belongs_to :persona, class_name: 'Person', foreign_key: 'person_id' 
 belongs_to :opera, class_name: 'Opera', foreign_key: 'opera_id' 
 
end
