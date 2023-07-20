# tomcat

zip new.zip hello-world.war script1.sql script2.sql script3.sql script4.sql
docker build -t servidor_arquivos .
docker run -it -p 8081:80 servidor_arquivos
script1.sql
script2.sql
script3.sql
script4.sql
hello-world.war

