class PasswordResetsController < ApplicationController

  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = Person.find_by(email: params[:password_reset][:email].downcase)
    if @user && @user.abilitato
      @user.create_reset_digest
      @user.send_password_reset_email
      @messaggio = "E' stata inoltrata una email a " + params[:password_reset][:email].downcase + " con le istruzioni per modificare la password."
    else
      
      @messaggio = "L'indirizzo di email fornito " + + params[:password_reset][:email].downcase + " non esiste nella nostra base dati. Contatta l'amministratore" 
    end
  end

  def edit
    puts "EDIT"
	puts "Nome: " + @user.cognome
	
  end
  
  def update
    puts "UPDATE PasswordResetsController"
    puts params
    if params[:person][:password].empty?                  # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif  @user.update(password: params[:person][:password], password_confirmation: params[:person][:password_confirmation])          # Case (4)
      #log_in @user
      #flash[:success] = "Password has been reset."
	  @messaggio = "E' stata modificata la password per " + @user.nome + " " + @user.cognome + "."
      render 'password_reset_ok'
    else
      render 'edit'                                     # Case (2)
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = Person.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user)
        redirect_to root_url
      end
    end
	
	def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
	
end
