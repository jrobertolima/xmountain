require 'net/http'
require 'sqlite3'
require 'roo'

def sendSms(atleta, categoria, tempo, fone, pos)
  username = 'jbetol'
  password = 'Petom@123'
  msisdn = fone
  msg = "XMountain Informa: 
  #{atleta} 
  Categoria #{categoria} 
  Tempo de prova: #{tempo}
  Classificação: /#{pos}"
  puts msg

  uri = URI('https://sms4geeks.appspot.com/smsgateway')#ction=out&username=YourUserName&password=YourPassword&msisdn=555123456&msg=hello')

  request = Net::HTTP::Post.new(uri)
	request.set_form_data('action' => 'out', 'username' => username, 'password' => password,
		     		'msisdn' => msisdn, 'msg' => msg)

	res = Net::HTTP.start(uri.hostname,  uri.port, :use_ssl => uri.scheme == 'http') do |http|
		
#		http.request(request)
	#	puts "Res " + res.body
	end	
end

def classifica(lista)
  lista.size.to_s   
end
  
#Consulta atleta dada a matrícula e retorna seus dados
	def consulta_mat(matricula)
		db = SQLite3::Database.open('xmountain.db')
    db.results_as_hash = true
    result = db.execute("select * from atletas where matricula = #{matricula}") 
 #   return result
	end
  
  def consulta_cat(categoria)
    puts categoria
		db = SQLite3::Database.open('xmountain.db')
    result = db.execute("select matricula from atletas where categoria = '#{categoria}'") 
  end

  def importa(source)
    workbook = Roo::Spreadsheet.open(source)

#    puts workbook.info
    #Select the workshhet to work. The first one, in that case.
    workbook.default_sheet = workbook.sheets[0]

# Create a hash of the headers so we can access columns by name (assuming row
# 1 contains the column headings).  This will also grab any data in hidden
# columns.
		headers = Hash.new
		workbook.row(1).each_with_index {|header,i|
  		headers[header] = i
		}

# Iterate over the rows using the `first_row` and `last_row` methods.  Skip
# the header row in the range.
		((workbook.first_row + 1)..workbook.last_row).each do |row|

		  # Get the column data using the column heading.
		  matricula = workbook.row(row)[headers['Matrícula']]
		  tempo = (workbook.row(row)[headers['Tempo']])
      # Fetch athlete data (name and phone) from DB
      res  = consulta_mat(matricula)
      pos = classifica(consulta_cat(res[0]['categoria']))  
      sendSms(res[0]['nome'], res[0]['categoria'], tempo,res[0]['fone'], pos)
		end  
	end
  
=begin    worksheets.each do |worksheet|
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
=end

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
				puts values
		end
	end
 
#  res = criadb
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
  ],
 [
    "1710",
    "Jose Silva",
    "master c",
    "31992320098"
  ],
  [
    "1716",
    "Fred Antonio Salgado",
    "cadete",
    "31996950250"
  ],
  [
    "1715",
    "Raphael Severo Souza",
    "master b",
    "31998854354"
  ],
  [
    '1714',
    "Henrik Jailton Souza",
    "Expert",
    "31984954144"
  ] 
  ]
  values.each {|item| insere(item)}
	puts "Importando"
  importa('./results.xlsx')

#end

		#URI.parse('https://sms4geeks.appspot.com/smsgateway'),
	  #   {'action' => 'out', 'username' => username, 'password' => password,
	  #   		'msisdn' => msisdn, 'msg' => msg})

#p http.status
=begin
MASTER CM
MASTER CF
30 km MASTER DM
30 km MASTER DF
30 km PNE M
      PNE F  
30 km SPORT F
30 km SPORT MA
30 km SPORT MB
30 km T-REX
48 km CADETE
48 km ELITE M
48 km MASTER 30F
48 km MASTER A1
48 km MASTER A2
48 km MASTER B1
48 km MASTER B2
48 km SUB 30F
48 km SUB 30M
DUPLA MISTA 
=end