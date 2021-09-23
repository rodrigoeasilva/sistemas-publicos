#!/bin/bash
echo "Configurando e preparando o ambiente para instalação do postgresql"
sudo apt-get install python-software-properties | cd /etc/apt/sources.list.d/ && touch pgdg.list 
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get install wget ca-certificates && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update && apt-get upgrade
	#instalando o postgresql e em seguida configurando cluster para o ambiente
sudo apt-get install postgresql-9.5 pgadmin3 | sudo pg_dropcluster --stop 9.5 main
	#inserindo linha no LC_COLLATE, linha 49
sed -i "50s/^/reorder-after <U00A0>\n   <U0020><CAP>;<CAP>;<CAP>;<U0020>\n reorder-end\n/" /usr/share/i18n/locales/pt_BR
	#redefinindo o locale
sudo localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR && locale-gen pt_BR
	#deixe todas as opções padroes, somente aperte OK.
sudo dpkg-reconfigure locales && export LC_ALL=pt_BR && echo LC_ALL=pt_BR >> /etc/environment
	#criar novo cluster como LATIN1 e Iniciando servidor postgresl.
sudo pg_createcluster -e LATIN1 9.2 main && /etc/init.d/postgresql start

	#Alterando arquivos de configuração pg_hba.conf e removendo comantario das linhas logo abaixo
sed -i '97,98,99s/#/ /' /etc/postgresql/9.5/main/pg_hba.conf
	#Alterando as linhas do final do arquivo pg_hba.conf
sed -i '97s/peer/trust' /etc/postgresql/9.5/main/pg_hba.conf && sed -i '98s/md5/trust' /etc/postgresql/9.5/main/pg_hba.conf && sed -i '99s/md5/trust' /etc/postgresql/9.5/main/pg_hba.conf
	#Alterar as linhas no final do arquivo que estão sem o #, colocando trust no lugar da última coluna:
	#local   all         all                               peer    | 	#host    all         all         127.0.0.1/32          md5 | 	#host    all         all         ::1/128               md5
	#recarregar as configurações do postgreSQL
sudo /etc/init.d/postgresql reload
	#entrar com usuario do postgres para alterar senha
	#su postgres
	#psql -U postgres
	#  alter user postgres with encrypted password 'versa@123';
	#verificar as tabelas se foram todas criadas de forma exata ao manual.
	#psql -U postgres -h localhost -l
	
	#Modificar arquivos para o postregres modifica os # fazendo a remoção nas linhas 59,526,570,584,585,590.
sed -i '59,526,570,584,585,590s/#/ /' /etc/postgresql/9.2/main/postgresql.conf
	#Nas linhas abaixo é trocado a palavra dentro da primeira / pelo que está dentro da segunda /
sed -i '59s/localhost/*/' /etc/postgresql/9.2/main/postgresql.conf && sed -i '64s/100/20/' etc/postgresql/9.2/main/postgresql.conf && sed -i '526s/hex/escape/' etc/postgresql/9.2/main/postgresql.conf
sed -i '570s/64/256/' etc/postgresql/9.2/main/postgresql.conf && sed -i '584s/off/on/' etc/postgresql/9.2/main/postgresql.conf && sed -i '585,590s/on/off/' etc/postgresql/9.2/main/postgresql.conf
	#Restart postgresql
sudo /etc/init.d/postgresql restart
echo "instalando Apache."
sudo apt-get install apache2
	#altarando linha do timeout de 300 para 12000
sed -i '86s/300/12000' /etc/apache2/apache2.conf
	#Alterando o arquivo charset dentro de /etc/apache2/conf.d/
sed -i '6s/#/ /' /etc/apache2/conf.d/charset && sed -i '6s/UTF-8/ISO-8859-1' /etc/apache2/conf.d/charset

	#Criando diretorio /tmp dentro de /var/www/ e dando permissao
sudo mkdir /var/www/tmp && sudo chwon -R www-data.www-data /var/www/tmp && sudo chmod -R 777 /var/www/tmp

echo "Instalando php5."
	#php7.0-mhash biblioteca não existe no php7.0
sudo apt-get install php7.0 
	#criando pasta de logs para o php7.0
sudo mkdir /var/www/log && sudo chown -R www-data.www-data /var/www/log

	#acertando permissoes de /var/lib/php7
sudo chown root.www-data /var/lib/php5 && sudo chmod g+r /var/lib/php5
	#editando as linhas do arquivo /etc/php/7.0/cli/php.ini
sed -i '633s/Off/on/' /etc/php/7.0/cli/php.ini && sed -i '656s/8M/64M/' /etc/php/7.0/cli/php.ini && sed -i '798s/2M/64M/' /etc/php/7.0/cli/php.ini sed -i '826s/60/60000/' /etc/php/7.0/cli/php.ini && sed -i '368s/30/60000/' /etc/php/7.0/cli/php.ini && sed -i '378s/60/60000/' /etc/php/7.0/cli/php.ini
sed -i '389s/-1/512M/' /etc/php/7.0/cli/php.ini && sed -i '633s/Off/on/' /etc/php/7.0/cli/php.ini && sed -i '445s/~E_DEPRECATED/ /' /etc/php/7.0/cli/php.ini && sed -i '445s/~E_STRICT/~E_NOTICE /' /etc/php/7.0/cli/php.ini
sed -i '568s/^/error_log = /var/www/log/php-scripts.log/' /etc/php/7.0/cli/php.ini && sed -i '1387s/1440/7200/' /etc/php/7.0/cli/php.ini

echo "Instalação do libre office, python e java."
sudo apt-get install libreoffice-script-provider-python && sudo apt-get install openjdk-8-jre-headless
	#inserindo a linha abaixo dentro de rc.local, inserindo na linha 13
sed -i "13s/^//usr/bin/soffice -accept="socket,host=localhost,port=8100;urp;" -nofirststartwizard -headless &/" /etc/rc.local
	#Não é necessario baixar o pacote do e-cidade, apenas suba o arquivo do nosso servidor local para ele dentro da pasta /tmp | 	#echo "baixando o e-cidade" 
	#cd /tmp | 	#wget -c https://softwarepublico.gov.br/social/profile/e-cidade/plugin/software_communities/download_file?block_id=500&download_id=10&title=Baixar+o+software && 	#sudo wget -c --no-check-certificate https://portal.softwarepublico.gov.br/social/articles/0000/5470/e-cidade-2.3.30-linux.tar.bz2
sudo tar -jxvf e-cidade-2.3.30-linux.tar.bz2
echo "Criando usuario para administrar o e-cidade."
sudo useradd -d /home/dbseller -g www-data -k /etc/skel -m -s /bin/bash dbseller
sudo passwd dbseller
	#Senha Padrao do usuario dbseller = dbseller
echo "Corrigindo permissoes de criação de arquivo em /etc/login.defs."
sed -i "151s/022/002/" /etc/login.defs

echo "Criando base de dados para e-cidade."
sudo cd e-cidade-2.3.3-linux.completo/sql