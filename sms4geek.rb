require 'net/http'
require 'sqlite3'
require 'roo'

  def importa(source)
    workbook = Roo::Spreadsheet.open(source)
    worksheets = workbook.sheets
    puts "Found #{worksheets.count} worksheets"

    worksheets.each do |worksheet|
      puts "Reading: #{worksheet}"
      num_rows = 0

      workbook.sheet(worksheet).each_row_streaming do |row|
        row_cells = row.map { |cell| cell.value }
        num_rows += 1

        # uncomment to print out row values
        puts row_cells.join ' '
      end
      puts "Read #{num_rows} rows"
    end

    puts 'Done'  
  end

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

		if db.execute("select * from atletas where matricula==#{values[0]}").empty?
				db.execute("INSERT INTO atletas(matricula, nome, categoria, fone) VALUES(?,?,?,?)", values)
		else
				puts "Atleta já existe"
				puts values
				puts " "
		end
	end

	def consulta
		db = SQLite3::Database.open('xmountain.db')
    db.execute("select * from atletas") do |result|
    	puts 'Atleta '
    	puts result
    	puts " "
    end
	end
  
 # res = criadb
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
    "1705",
    "Rayla Lima",
    "master b",
    "31993500114"
  ],
  [
    '1703',
    "Tomaz Correa",
    "Expert",
    "3199500083"
  ]
  ]
#  values.each {|item| insere(item)}
#	consulta	
  importa('./results.xlsx')


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
