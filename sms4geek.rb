require 'net/http'
require 'sqlite3'
require 'roo'

@xmountain_DB = './db/xmountain.db'
@planilha_resultados = './db/Listagem.xlsx'
@qnt_atletas_categoria = Hash.new(0)
@clas_atual_categoria = Hash.new(0)
@db = nil 

def inicializaAmbiente
  inicializaDB
  inicializaCategorias
end  

#Inicializa hash de categorias e de classificação
def inicializaCategorias
    puts "Inicializando categorias..."
    result = @db.execute("select categoria from atletas") 

    result.each do |cat|
      @qnt_atletas_categoria[cat[0]] += 1
      @clas_atual_categoria[cat[0]] = 0
    end
    puts "Categorias done!"
end

def sendSms(atleta, categoria, tempo, fone, poscat, posgeral)

  username = 'jbetol'
  password = 'Petom@123'
  msisdn = fone.gsub!(/\D/,"")
  msg = "#{atleta}, XMountain informa seu resultado:
  Categoria => #{categoria}
  Tempo de prova => #{tempo}
  Classificacao categoria parcial => #{poscat}/#{@qnt_atletas_categoria[categoria]}
  Classificacao geral parcial => #{posgeral}/#{@qnt_atletas_categoria[categoria]}"

    puts msg 
    uri = URI('https://sms4geeks.appspot.com/smsgateway')#ction=out&username=YourUserName&password=YourPassword&msisdn=555123456&msg=hello')

    request = Net::HTTP::Post.new(uri)
  	request.set_form_data('action' => 'out', 'username' => username, 'password' => password,
  		     		'msisdn' => msisdn, 'msg' => msg)

  	res = Net::HTTP.start(uri.hostname,  uri.port, :use_ssl => uri.scheme == 'https') do |http|
  		
    #	http.request(request)
  	end	
end

def classifica(categoria,tempo)
  @clas_atual_categoria[categoria]+=1
end
  
#Consulta atleta dada a matrícula e retorna seus dados
	def consulta_mat(matricula)
    result = @db.execute("select * from atletas where matricula = #{matricula}") 
    return result
	end

  def importa#(source)
    workbook = Roo::Spreadsheet.open(@planilha_resultados)

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
		  matricula = workbook.row(row)[headers['PLAQUETA']]
#		  tempo = (workbook.row(row)[headers['Tempo']])

    # Fetch athlete data (name and phone) from DB, if do not use the Results_real spreadsheet
      #  res  = consulta_mat(matricula)
      #  pos = classifica(res[0]['categoria'], tempo)   
      #  sendSms(res[0]['nome'], res[0]['categoria'], tempo,res[0]['fone'],pos)

     #Fetch all data directly from spreadsheet Results_real
      sendSms(workbook.row(row)[headers['NOME']], 
              workbook.row(row)[headers['COD CAT']],
              workbook.row(row)[headers['TEMPO PROVA']].strftime("%HH:%MM:%SS"),
              workbook.row(row)[headers['Celular']].to_s,
              workbook.row(row)[headers['POSIÇAO CAT']],
              workbook.row(row)[headers['POSIÇAO GERAL']])

		end  
	end
  
#	Criando e configurando BD
  def inicializaDB
    puts "Inicializando DB..."
		if @db.nil?
      puts "Criado DB..."
      @db = SQLite3::Database.new(@xmountain_DB) 
      @db.execute <<-SQL
							create table IF NOT EXISTS atletas(
							 	matricula INTEGER PRIMARY KEY,
							 	nome varchar(50),
							 	categoria varchar(10),
							 	fone varchar(14)
							 	);
							 	SQL
      puts "Abrindo DB..."
      @db = SQLite3::Database.open(@xmountain_DB)
    else
      puts "Abrindo DB..."
      @db = SQLite3::Database.open(@xmountain_DB)
    end
    @db.results_as_hash = true

	end

# Popula tabela de atletas
	def insere(atleta)
		if @db.execute("select * from atletas where matricula==#{atleta[0]}").empty? #Atleta não existe, então inclui
				@db.execute("INSERT INTO atletas(matricula, nome, categoria, fone) VALUES(?,?,?,?)", atleta)
        puts "Inserindo atletas no DB..."
		end
	end

  inicializaAmbiente#(xmountain_DB,qnt_atletas_categoria)
 
#  res = criadb
  values = [[
    "1702",
		"Marya Lima",
    "master a",
    "31992320104"
  ],
  [
    "1701",
    "Joao Lima",
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
    "1703",
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
    "1714",
    "Henrik Jailton Souza",
    "Expert",
    "31984954144"
  ],
    [
    "1707",
    "Caca Lima",
    "cadete",
    "31992320098"
  ],
  [
    "1709",
    "Deusdete da Silva",
    "master b",
    "31993500114"
  ],
  [
    "1708",
    "Lula",
    "Expert",
    "3199500083"
  ] 
  ]
  values.each {|item| insere(item)}
	importa#(@planilha_resultados)
  puts @clas_atual_categoria
  @db.close
  puts "DB fechado..."

