class Delegation < ApplicationRecord

belongs_to :delegante, class_name: 'Person', foreign_key: 'delegante_id'
belongs_to :delegato, class_name: 'Person', foreign_key: 'delegato_id'
belongs_to :ufficio, class_name: 'Office', foreign_key: 'office_id'

end
