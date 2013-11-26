class UserMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def can_create_albums_now(user)
    @user = user

    mail({
      to: user.email,
      subject: "You can now create albums on teller!"
    })    
  end
end