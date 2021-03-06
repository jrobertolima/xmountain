require 'net/http'
require 'sqlite3'
require 'roo'

#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#Inicialização de variáveis 
# Files application
@xmountain_DB = './db/xmountain.db'
@planilha_resultados = './db/Listagem.xlsx'
@planilha_categorias = './db/Categorias.ods'

#globals variable
@qnt_atletas_categoria = Hash.new(0)
@categorias = Hash.new(0)
@qnt_atletas_total = 0
@db = nil 

def inicializaAmbiente
  inicializaDB
  inicializaCategorias
end  

#Inicializa hash de categorias e de classificação
def inicializaCategorias
  puts "Inicializando categorias..."

#Initializing categories table/hash    
  lista_categorias = Roo::Spreadsheet.open(@planilha_categorias)

  lista_categorias.default_sheet = lista_categorias.sheets[0]

# Create a hash of the categories code and name
    ((lista_categorias.first_row + 1)..lista_categorias.last_row).each do |row|
        @categorias[lista_categorias.row(row)[0]] = lista_categorias.row(row)[1]
    end      
    
# Create a hash for number of athletes for each category    
    result = @db.execute("select categoria from atletas") 
    result.each do |cat|
      @qnt_atletas_categoria[cat[0]] += 1
      @qnt_atletas_total += 1
    end
end

#Deal with phone number to verify if it's valid
def valida_fone(fone)
# get only numbers
  pn = fone.gsub(/[^\d]/,"")
# get numbers with size <= 11
  if pn =~ /^(\d{0,4})(\d{5})(\d{4})$/
    p1 = $1 #deal with 2 or 4 initial characters
    p1.size == 4 ?  p1 = p1.slice(2,3) : ((p1.size == 2) or (p1.size == 0) ? p1 : pn = false)	
    pn = "#{p1}#{$2}#{$3}" if pn 
  else
    pn = false
  end
  return pn  
end

def preparaEnvioSMSGenerico
  res = @db.execute("select * from atletas where matricula>1710")
  res.each do |atleta|
    msg = "Caro #{atleta['nome'].split[0]}, 
  XMOUNTAIN agradece sua inscricao na categoria #{atleta['categoria']}.
  Nos vemos em 22OUT2017.
  BOA PROVA!
  www.xmountain.com.br"
    fone = atleta['fone'] #{}"992320098"
    if valida_fone fone
      sendSmsGenerico(msg,fone)#atleta[3])
    else
      puts "Fone inválido"
    end    
  end
end

#Envia SMS com texto definido
def sendSmsGenerico(msg, fone)

  username = 'xmountainrace'
  password = 'xmountain@2017'
  msisdn = fone.gsub(/\D/,"") #retira o que não for número do telefone
  
    puts msg + " " + msisdn
    uri = URI('https://sms4geeks.appspot.com/smsgateway')#ction=out&username=YourUserName&password=YourPassword&msisdn=555123456&msg=hello')

    request = Net::HTTP::Post.new(uri)
  	request.set_form_data('action' => 'out', 'username' => username, 'password' => password,
  		     		'msisdn' => msisdn, 'msg' => msg)

  	res = Net::HTTP.start(uri.hostname,  uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
  	end	
end

#Send athlete result
def sendSmsResultado(atleta, categoria, tempo, fone, poscat, posgeral)

  username = 'jbetol'
  password = 'Petom@123'
  msisdn = fone.gsub!(/\D/,"") #retira o que não for número do telefone
  msg = "#{atleta.split[0]},
  XMountain informa seu resultado:
  Categoria #{@categorias[categoria]}
  Tempo #{tempo.strftime("%HH:%MM:%SS")}
  Clas na categ #{poscat}/#{@qnt_atletas_categoria[@categorias[categoria]]}
  Clas geral #{posgeral}/#{@qnt_atletas_total}.
  www.xmountain.com.br"

# Definir tamanho maximo msg cortando a última linha.
  
    puts msg + " " + msisdn
    uri = URI('https://sms4geeks.appspot.com/smsgateway')#ction=out&username=YourUserName&password=YourPassword&msisdn=555123456&msg=hello')

    request = Net::HTTP::Post.new(uri)
  	request.set_form_data('action' => 'out', 'username' => username, 'password' => password,
  		     		'msisdn' => msisdn, 'msg' => msg)

  	res = Net::HTTP.start(uri.hostname,  uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
   	end	
end

# Prepara dados para envio do resultado do atleta
def preparaEnvioSMSResultado

  workbook = Roo::Spreadsheet.open(@planilha_resultados)

  workbook.default_sheet = workbook.sheets[0]

# Create a hash of the headers so we can access columns by name (assuming row
# 1 contains the column headings).  This will also grab any data in hidden
# columns.
  headers = Hash.new
  workbook.row(1).each_with_index {|header,i|
    headers[header] = i
  }
  
# Iterate over courses PRO and Sport
  0.upto(1) do |i|
    workbook.default_sheet = workbook.sheets[i] # Setting default sheet for PRO and SPORT

# Iterate over the rows using the `first_row` and `last_row` methods.  Skip
# the header row in the range.
    ((workbook.first_row + 1)..workbook.last_row).each do |row|

# Get the column data using the column heading.
#Fetch all data directly from spreadsheet Results_real
      matricula = workbook.row(row)[headers['PLAQUETA']]
      nome = workbook.row(row)[headers['NOME']]
      cod_categoria = workbook.row(row)[headers['COD CAT']]
      tempo = workbook.row(row)[headers['TEMPO PROVA']]
      fone = valida_fone(workbook.row(row)[headers['Celular']].to_s)
      pos_categoria = workbook.row(row)[headers['POSIÇAO CAT']]
      pos_geral = workbook.row(row)[headers['POSIÇAO GERAL']]

      if fone and matricula > 1710
         sendSmsResultado(nome, cod_categoria, tempo, fone, pos_categoria, pos_geral)
         # 1.upto(1000) {}

      end
    end 
  end      
  workbook.close
end

# Popula tabela de atletas no banco de dados XMountain
def insereAtleta
  
  atleta =[]  
  workbook = Roo::Spreadsheet.open(@planilha_resultados)

  workbook.default_sheet = workbook.sheets[0]

# Create a hash of the headers so we can access columns by name (assuming row
# 1 contains the column headings).  This will also grab any data in hidden
# columns.
  headers = Hash.new
  workbook.row(1).each_with_index {|header,i|
    headers[header] = i
  }
  
# Iterate over courses PRO and Sport
  0.upto(1) do |i|
    workbook.default_sheet = workbook.sheets[i] # Setting default sheet for PRO and SPORT

# Iterate over the rows using the `first_row` and `last_row` methods.  Skip
# the header row in the range.
    ((workbook.first_row + 1)..workbook.last_row).each do |row|

# Get the column data using the column heading.
        atleta[0] = workbook.row(row)[headers['PLAQUETA']]
        atleta[1] = workbook.row(row)[headers['NOME']]
        atleta[2] = @categorias[workbook.row(row)[headers['COD CAT']]]
        atleta[3] = workbook.row(row)[headers['Celular']].to_s
# Inclui atleta na tabela        
        if @db.execute("select * from atletas where matricula==#{atleta[0]}").empty? #Atleta não existe, então inclui
            @db.execute("INSERT INTO atletas(matricula, nome, categoria, fone) VALUES(?,?,?,?)", atleta)
            puts "Inserindo atletas no DB..."
        end
    end 
  end      
  workbook.close

	end

#	Criando e configurando BD
def inicializaDB
  puts "Inicializando DB..."

#Verifica se planilha de resultados já está no local apropriado   
  if !File.exist?@planilha_resultados
    puts "#{@planilha_resultados} não encontrada em " + File.dirname(@planilha_resultados) + "... saindo..."
    exit     
  else
    puts "Planilha Ok."
  end
  
#Inicializa banco de dados e tabelas, caso necessários    
  if !File.exist?@xmountain_DB
    puts "Banco de dados não encontrado em " + File.dirname(@xmountain_DB) + "... saindo..."
    exit     
  else
    puts "Abrindo DB..."
    @db = SQLite3::Database.open(@xmountain_DB)
    @db.results_as_hash = true
  end
end
inicializaAmbiente#(xmountain_DB,qnt_atletas_categoria)

#  res = criadb
#insereAtleta # In order to prepare xmountain_DB
#preparaEnvioSMSResultado
preparaEnvioSMSGenerico
@db.close
puts "Saindo em paz..."
 
  
  
=begin
		if @db.nil?
      puts "Criando DB..."
      @db = SQLite3::Database.new(@xmountain_DB) 
      @db.execute <<-SQL
							create table IF NOT EXISTS atletas(
							 	matricula INTEGER PRIMARY KEY,
							 	nome varchar(50),
							 	categoria varchar(10),
							 	fone varchar(14)
							 	);
							 	SQL
end
	end
Set environment for SSL 
set SSL_CERT_FILE=C:\Users\88630447753\Developer\RailsInstaller\cacert.pem 
=end
