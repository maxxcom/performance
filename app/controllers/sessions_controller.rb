class SessionsController < ApplicationController
  def new
  end
  
  def create
   ip = request.remote_ip
   browser = request.env['HTTP_USER_AGENT'] 
   username = params[:session][:email].downcase
   passw = params[:session][:password]
   puts username + "/" + passw +" ip:" + ip + " - " + browser
   @user = Person.find_by(email: username)
   if !@user.nil?
    puts @user.cognome
	puts "passwd " + params[:session][:password]
   else
   # provo a cercarlo come matricola
     @user = Person.find_by(matricola: username)
     if !@user.nil?
       puts @user.cognome
	   puts "passwd " + params[:session][:password]
     end
   end
   # if user && user.authenticate(params[:session][:password])
   if !@user.nil? && @user.abilitato > 0 && @user.authenticate(params[:session][:password])
     log_in @user
	 registra('Login ' + @user.nominativo)
     redirect_to '/pages/show'
   else
     flash.now[:danger] = 'user o password invalide'
     render 'new_errore'
   end
  end 
  
  def destroy
    log_out
    redirect_to '/login/'
  end
  
end
