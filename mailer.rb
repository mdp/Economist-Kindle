require 'yaml'
require 'rubygems'
require 'actionmailer'

credentials = YAML.load_file("credentials.yml")['email']
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => credentials['domain'],
  :authentication => :plain,
  :user_name => "#{credentials['user']}@#{credentials['domain']}",
  :password => credentials['password']
}

class EconomistMailer < ActionMailer::Base

  def issue(email, title, html)
    puts "Delivering to #{email} - #{title}"
    recipients      email
    subject         title
    from            "#{ActionMailer::Base.smtp_settings[:user_name]}@#{ActionMailer::Base.smtp_settings[:domain]}"
    body            "Economist latest issue"
    attachment "text/html" do |a|
      a.body = html
      a.filename = title
    end
  end
end
