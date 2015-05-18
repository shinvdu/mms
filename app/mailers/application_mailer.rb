class ApplicationMailer < ActionMailer::Base
  default from: Settings.email.user
  layout 'mailer'
end
