require 'watir'

    browser = Watir::Browser.new(:chrome)

browser = Watir::Browser.new
browser.goto 'google.com.br'
browser.text_field(title: 'Search').set 'Hello World!'
browser.button(type: 'submit').click

#puts browser.title=> 'Hello World! - Google Search'
browser.close


=begin
	
rescue Exception => e
	
end    browser.goto("https://web.whatsapp.com/") #scan the QR code

  #  browser.text_field(title: 'Procurar ou começar uma nova conversa').set 'Talibã Racing Team'

    browser.send_keys :enter

    element=browser.div(:class => "input")

    script = "return arguments[0].innerHTML = 'Testando Xmountain'"

    #3.times do #// Number of times you want to send message.Don't do it for a large number as WhatsApp may block you.

    browser.execute_script(script, element)

    browser.send_keys :space
    browser.send_keys :enter

    browser.button(:class => "compose-btn-send" ).click # :enter

   # end
    browser.close
=end