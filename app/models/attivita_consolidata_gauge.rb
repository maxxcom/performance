class AttivitaConsolidataGauge < ApplicationRecord

 belongs_to :responsabile_principale, class_name: 'Person', foreign_key: 'responsabile_principale_id'
 
 
end
