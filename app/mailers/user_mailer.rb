class UserMailer < ApplicationMailer


def password_reset(user)
 @destinatario = user
 puts "QUA SI MANDA LA EMAIL"
 mail(to: @destinatario.email, subject: "Reset password Performance")
 #mail(to: "massimiliano.chiandone@comune.udine.it", subject: Communication.find_by(nome: "password_reset" ).oggetto)
 
end

end
