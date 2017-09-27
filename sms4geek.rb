require 'net/http'
require 'sqlite3'

	def criadb
		db = SQLite3::Database.new('xmountain.db')

		rows = db.execute <<-SQL
							create table IF NOT EXISTS atletas(
							 	matricula INTEGER PRIMARY KEY,
							 	nome varchar(50),
							 	categoria varchar(10),
							 	fone varchar(14)
							 	);
							 	SQL
		return rows					 	
	end

	def insere(values)
		db = SQLite3::Database.open('xmountain.db')

		db.execute("INSERT INTO atletas(matricula, nome, categoria, fone) VALUES(?,?,?,?)", values)
	end

	def consulta
		db = SQLite3::Database.open('xmountain')

	end
  res  = criadb
  values = [[
    "1702",
		"Marya Lima",
    "master a",
    "31992320104"
  ],
  [
    "1701",
    "João Lima",
    "master c",
    "31992320098"
  ],
  [
    "1704",
    "Pedro Lima",
    "cadete",
    "31992320162"
  ],
  [
    '1703',
    "Tomaz Correa",
    "Expert",
    "3199500083"
  ]
  ]
  values.each {|item| insere(item)}
  #puts res
	#puts res.inspect
	



=begin
	
rescue Exception => e
	
end
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
=end
