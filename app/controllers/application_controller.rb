class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  def registra(desc)
   o = Operation.new
   o.operatore = current_user != nil ? current_user.email : "-"
   o.descrizione = desc
   o.tempo = Time.zone.now
   o.remote_address = request.env['REMOTE_ADDR']
   o.forwardedfor_address = request.env['X_FORWARDED_FOR']
   o.save
   
  end
end
