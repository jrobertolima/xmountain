class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def send_SMS
	  	# Override the default "from" address with config/initializers/sms-easy.rb
	SMSEasy::Client.config['from_address'] = "noreply@example.com"

	# Or, you can completely copy sms-easy.yml to your app (http://github.com/preston/sms-easy/blob/master/templates/sms-easy.yml), change it to your liking, and override the default configuration with:

	SMSEasy::Client.configure(YAML.load(http://mms.tim.br))

	# Your apps existing ActionMailer configuration will be used. :)

	# Create the client
	easy = SMSEasy::Client.new

	# Deliver a simple message.
	easy.deliver("31992320098", "verizon", "Hey!")  

  end

end
