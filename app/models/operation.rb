class Operation < ApplicationRecord
  include SessionsHelper
  
  def self.registra4(desc, operatore, addr1, addr2)
   o = Operation.new
   o.operatore = operatore
   o.descrizione = desc
   o.tempo = Time.zone.now
   o.remote_address = addr1
   o.forwardedfor_address = addr2
   o.save
   
  end

end
