require 'net/http'
#require 'uri'

username = 'jbetol'
password = 'Petom@123'
msisdn = ['31992320098','31992320104','31993500083']
msg = 'XMountain Informa'

uri = URI('https://sms4geeks.appspot.com/smsgateway')#ction=out&username=YourUserName&password=YourPassword&msisdn=555123456&msg=hello')

msisdn.each do |cel|
  request = Net::HTTP::Post.new(uri)
	request.set_form_data('action' => 'out', 'username' => username, 'password' => password,
		     		'msisdn' => cel, 'msg' => msg)

	res = Net::HTTP.start(uri.hostname,  uri.port, :use_ssl => uri.scheme == 'https') do |http|
		
		http.request(request)
	#	puts "Res " + res.body
	end	
end
		#URI.parse('https://sms4geeks.appspot.com/smsgateway'),
	  #   {'action' => 'out', 'username' => username, 'password' => password,
	  #   		'msisdn' => msisdn, 'msg' => msg})

#p http.status

