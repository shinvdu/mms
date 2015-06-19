class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.confirm.subject
  #
    def confirm(email)
        @message = "Thank you for confirmation!"
        mail(:to => email, :subject => "Registered")
    end
end
