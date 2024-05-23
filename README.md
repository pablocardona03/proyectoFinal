# proyectoFinal
Balanceador de carga probado con artillery y monitorizado con node exporter,  prometheus y grafana

 Readme

Configuración inicial del entorno virtual:

Inicialmente se requiere crear un entorno virtual compuesto por 3 máquinas virtuales, una que funcionará como balanceadora de carga (loadBalancer) y las dos máquinas que se encargarán de resolver las peticiones de los usuarios (servidorWeb1 y servidorWeb2); de esta manera sabemos que el vVgrantfile tendrá una arquitectura similar a la siguiente.


________________________________________________________________________________________
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    config.vm.define :loadBalancer do |loadBalancer|
        loadBalancer.vm.box = "bento/ubuntu-23.0rm64"
        loadBalancer.vm.network :private_network, ip: "192.168.50.30"
        loadBalancer.vm.hostname = "loadBalancer"
    end

    config.vm.define :webServer1 do |webServer1|
        webServer1.vm.box = "bento/ubuntu-23.04-arm64"
        webServer1.vm.network :private_network, ip: "192.168.50.10"
        webServer1.vm.hostname = "webServer1"
    end

    config.vm.define :webServer2 do |webServer2|
        webServer2.vm.box = "bento/ubuntu-23.04-arm64"
        webServer2.vm.network :private_network, ip: "192.168.50.20"
        webServer2.vm.hostname = "webServer2"
    end
end
________________________________________________________________________________________

Nota: Revisar la box seleccionada pues esta es funcional en equipos macOS con chip de apple silicone.

para windows quedaría de la siguiente manera.
________________________________________________________________________________________
# -- mode: ruby --
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    config.vm.define :loadBalancer do |loadBalancer|
        loadBalancer.vm.box = "bento/ubuntu-22.04"
        loadBalancer.vm.network :private_network, ip: "192.168.50.30"
        loadBalancer.vm.hostname = "loadBalancer"
    end

    config.vm.define :webServer1 do |webServer1|
        webServer1.vm.box = "bento/ubuntu-22.04"
        webServer1.vm.network :private_network, ip: "192.168.50.10"
        webServer1.vm.hostname = "webServer1"
    end

    config.vm.define :webServer2 do |webServer2|
        webServer2.vm.box = "bento/ubuntu-22.04"
        webServer2.vm.network :private_network, ip: "192.168.50.20"
        webServer2.vm.hostname = "webServer2"
    end
end
________________________________________________________________________________________

Posteriormente se crean las máquinas virtuales y se procede a configurar cada una.

Configuración de la máquina "LoadBalancer"

Para la máquina que sirve de balanceadora de Carga ejecutaremos los siguientes comandos.
________________________________________________________________________________________
sudo -i

apt-get update && apt-get upgrade -y

apt-get install nginx
________________________________________________________________________________________

una vez instalado nginx en la máquina balanceador, debemos redirigir las peticiones del puerto 80 de esta máquina hacia los dos servidores donde se encotrará la configuración de las aplicaciones, para lo anterior creamos un archivo con un nombre de dominio, en este caso será "proyecto.com"  en la carpeta 
/etc/nginx/sites-available con el siguiente comando:

________________________________________________________________________________________
sudo vim /etc/nginx/sites-available/proyecto.com
________________________________________________________________________________________

en este documento debemos escribir la siguiente configuración.

________________________________________________________________________________________
server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }

}

upstream backend {

        server 192.168.50.10;
        server 192.168.50.20;

}
________________________________________________________________________________________


Es necesario remover el sitio que viene habilitado por defecto, para esto ejecutamos el siguiente código.

________________________________________________________________________________________
rm -r /etc/nginx/sites-enabled/default
________________________________________________________________________________________

posteriormente habilitamos el sitio web y reiniciamos el servicio de nginx:

________________________________________________________________________________________
ln -s /etc/nginx/sites-available/proyecto.com /etc/nginx/sites-enabled/

systemctl restart nginx
________________________________________________________________________________________

Configuración de la máquina "webServer1" y "webServer2"

Ahora iniciamos las máquinas virtuales "webServer1" y "webServer2" y ejecutamos los siguientes códigos para ambas.
________________________________________________________________________________________
sudo -i

apt install apache2
________________________________________________________________________________________

nota: si sale un error correr "apt-get update" y posteriormente "apt install apache2" nuevamente

posterior a la instalación configuramos nuestra página web, en este caso se usará la que se encuentra habilitada por defecto, accediendo al siguiente archivo y editándolo según la preferencia, se borra todo el contenido del archivo y se introduce el código HTML de la página que será clonada en ambas máquinas:

________________________________________________________________________________________
sudo vim /var/www/html/index.html
________________________________________________________________________________________

Una vez realizado esto se reinicia el servicio apache2:

________________________________________________________________________________________
systemctl restart apache2
________________________________________________________________________________________

finalmente, repetimos el mismo proceso para el otro servidor web, se recomienda alojar una página clon con un cambio que indique cuando la respuesta proviene del servidor 1 y el servidor 2, como el ejemplo que se muestra a continuación.


________________________________________________________________________________________
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Página Web en CMD Linux numero 1</title>
    <style>
        /* Estilos CSS aquí */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f0f0;
            color: #333;
        }
        header {
            background-color: #333;
            color: #fff;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 0 20px;
        }
        h1 {
            font-size: 2em;
            margin-bottom: 20px;
        }
        p {
            font-size: 1.1em;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <header>
        <h1>Mi Página Web en CMD 1 Linux</h1>
    </header>
    <div class="container">
        <p>Bienvenido a mi página web 1 ejecutada desde la línea de comandos en Linux.</p>
        <p>¡Aquí puedes agregar tu contenido HTML y CSS personalizado!</p>
    </div>
</body>
</html>
________________________________________________________________________________________

Para la página del servidor web dos puede ser la siguiente.
________________________________________________________________________________________

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Página Web en CMD Linux numero 1</title>
    <style>
        /* Estilos CSS aquí */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f0f0;
            color: #333;
        }
        header {
            background-color: #333;
            color: #fff;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 0 20px;
        }
        h1 {
            font-size: 2em;
            margin-bottom: 20px;
        }
        p {
            font-size: 1.1em;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <header>
        <h1>Mi Página Web 2 en CMD Linux</h1>
    </header>
    <div class="container">
        <p>Bienvenido a mi página web 2 ejecutada desde la línea de comandos en Linux.</p>
        <p>¡Aquí puedes agregar tu contenido HTML y CSS personalizado!</p>
    </div>
</body>
</html>
________________________________________________________________________________________

En este punto podemos acceder a través de la ip del balanceador de carga (192.168.50.30) desde nuestro navegador y deberíamos observar como al recargar la página cambia entre la página alojada en el servidor web 1 y 2.

Configuración de la máquina "webServer1" y "webServer2" empleando Docker compose + Flask + MySQL

Con el fin de aumentar la exigencia de las pruebas a realizar y simular una aproximación mayor a la vida real se puede implementar una aplicación empleando Docker compose, Flask y MySQL, en este orden de ideas, si deseamos implementar esto, debemos seguir los siguientes comandos en ambas máquinas.

________________________________________________________________________________________
sudo apt-get update

sudo apt-get install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
________________________________________________________________________________________

Una vez instalado docker relogueamos la máquina para permitir la ejecución de comandos sin necesidad de usar el comando sudo y posteriormente ejecutamos los siguientes comandos para clonar un repositorio de un tutorial que servirá para esta aplicación.
________________________________________________________________________________________
git clone https://github.com/stavshamir/docker-tutorial
________________________________________________________________________________________

Posteriormente modificamos el archivo de configuración del docker compose para que mapee el puerto de la aplicación hacia el puerto 80.
________________________________________________________________________________________
cd docker-tutorial

vim docker-compose.yml
________________________________________________________________________________________

En este archivo debemos reemplazar en el apartado de app la linea "ports:5000:5000"  por "ports:80:5000" y subir los contenedores.
________________________________________________________________________________________
sudo docker compose up -d
________________________________________________________________________________________
para mac:
Es necesario realizar algunas modificaciones adicionales en los siguientes puntos.

En Dockerfile, se debe cambiar "FROM python:3.6" por "FROM python"; en requirements.txt se debe cambiar  "mysql-connector" por "mysql-connector-python" y finalmente, en el archivo "docker-compose.yml" se debe cambiar "image: mysql:5.7" por "image: mysql".

Finalmente se sugiere agregar un dato en cada máquina virtual para diferenciar entre el servidor uno y el servidor 2 siguiendo los siguientes comandos. IMPORTANTE: la contraseña de este usuario es root

________________________________________________________________________________________
sudo apt-get install mysql-client

mysql --host=127.0.0.1 --port=32000 -u root -p

use knights;

INSERT INTO favorite_colors (name, color) VALUES ('Servidor', 'uno');
________________________________________________________________________________________

Nota: Si ya realizó la configuración para emplear apache, es necesario detener este servicio puesto que ocupa el puerto 80. Para esto ejecutar: "sudo systemctl stop apache2"


Pruebas de carga empleando artillery

Desde la máquina anfitrión lo primero que debemos hacer es descargar node.js desde este link: https://nodejs.org/en , una vez realizado esto abrimos una nueva pestaña de cmd y confirmamos la instalación desde ejecutando el comando.
________________________________________________________________________________________
node -v
________________________________________________________________________________________
Nota: si tiene una pestaña de CMD ya abierta es necesario cerrarla y volverla a abrir

Una vez confirmada la instalación podemos realizar los siguientes comandos para instalar artillery en nuestra máquina.
para mac:
________________________________________________________________________________________
sudo npm install -g npm@latest

npm install -g artillery
________________________________________________________________________________________

para windows:
________________________________________________________________________________________
npm install -g npm@latest

npm install -g artillery
________________________________________________________________________________________

Una vex instalado artillery se debe entrar a la ruta donde está alojado el vagrantfile del proyecto, posteriormente crear un archivo con el editor de texto, es necesario que este quede guardado con el nombre "configuracion.yaml"  
________________________________________________________________________________________
config:
  target: "http://192.168.50.30"
  phases:
    - duration: 10  #Aquí debe colocar la duración del testeo en segundos
      arrivalRate: 800  #Aquí debe colocar la cantidad de peticiones por segundo
scenarios:
  - flow:
      - get:
          url: "/"
________________________________________________________________________________________

Nota: se recomienda duplicar el vagrantfile y editar la copia del archivo, posteriormente presionar guardar como, y en tipo de archivo "Todos los archivos" de esta manera se garantiza que el archivo tome el formato .yaml y no .txt al ser editado

Vemos entonces como esta prueba por defecto entregará 8000 peticiones, en grupos de 800 peticiones/segundo durante 10 segundos; estos parámetros pueden ser modificados para obtener resultados diferentes donde es relevante observar la cantidad de peticiones resueltas, las peticiones fallidas, porcentaje de fallas entre otros. (Artillery entrega un informe detallando esta información)
Para realizar la prueba se ejecutará el siguiente comando.

________________________________________________________________________________________
artillery run configuracion.yaml
________________________________________________________________________________________

Configuración de Firewall 

Con el fin de prevenir la conexión directa a las páginas alojadas en las ip's 192.168.50.10 y 192.168.50.30 se configura un firewall que contendrá la siguiente lista de reglas en orden:
- Se admite la conexión SSH
- Se admite el tráfico desde la ip 192.168.50.30 por el puerto 80
- Se deniega el trafico del puerto 80 para cualquier otra ip
- Se admite completamente el tráfico por el puerto 9100
para conseguir esto, debemos ejecutar las siguientes lineas de comando en ambas máquinas virtuales

________________________________________________________________________________________
sudo ufw status

sudo ufw allow ssh

sudo ufw enable

sudo ufw allow from 192.168.50.30 to any port 80 proto tcp

sudo ufw deny 80/tcp

sudo ufw allow 9100/tcp

sudo ufw allow 9100/udp

sudo ufw reload

sudo ufw disable

sudo ufw enable

sudo ufw reload
________________________________________________________________________________________



Monitoreo de las máquinas empleando node exporter, prometheus y grafana 

Para contextualizar lo que se va a realizar tendremos node exporter instalado en la máquinas que alojan el servicio web (webServer1 y webServer2) permitiendo exportar las métricas de la máquina por el puerto 9100, prometheus se encarga de recopilar los datos que entrega el node exporter de cada máquina, almacenándolos en una base de datos, finalmente, grafana se emplea como una interfaz gráfica de visualización de las métricas y tiene fácil implementación con prometheus.

node exporter:
Lo primero que debemos hacer es descargar, extraer y node exporter desde el repositorio de github en cada máquina de servidor web, para esto ejecutamos los siguientes comandos en ambas máquinas.
para mac:
________________________________________________________________________________________
cd

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-arm64.tar.gz

tar xvfz node_exporter-1.8.0.linux-arm64.tar.gz

cd node_exporter-1.8.0.linux-arm64

./node_exporter
________________________________________________________________________________________
para windows:
________________________________________________________________________________________
cd

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz

tar xvfz node_exporter-1.8.0.linux-amd64.tar.gz

cd node_exporter-1.8.0.linux-amd64

./node_exporter
________________________________________________________________________________________

En este punto las dos máquinas deben estar exportando las métricas de sus sistemas.


Prometheus y grafana empleando docker:

Para la implementación de prometheus y grafana se decidió implementar ambos servicios en contenedores docker permitiendo así emplear la misma máquina para ambos servicios, en este caso se empleará la máquina  "loadBalancer", sin embargo, sería recomendable emplear una máquina externa al balanceador para su monitoreo.

________________________________________________________________________________________
sudo apt-get update

sudo apt-get install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
________________________________________________________________________________________

Una vez realizado esto habremos instalado correctamente docker en nuestra máquina virtual y podremos crear  nuestra estructura de proyecto para correr por medio de docker-compose los contenedores de prometheus y grafana al mismo tiempo.

Nota: recuerde reloguearse en la máquina para aplicar los cambios en los permisos del usuario y que pueda emplear los comandos Docker sin sudo.

________________________________________________________________________________________

└── project
  	  ├── docker-compose.yml
    	  └── prometheus
  	  	    ├── Dockerfile
  	  	    └── prometheus.yml
________________________________________________________________________________________

partiendo de esta arquitectura, sabemos que debemos ejecutar los siguientes comandos.
________________________________________________________________________________________ 
cd
 
mkdir project

cd project/

vim docker-compose.yml
________________________________________________________________________________________

Posteriormente debemos introducir lo siguiente en el archivo docker-compose.yml.
________________________________________________________________________________________
version: '3'

services:
  prometheus:
    build: ./prometheus
    ports:
      - "9090:9090"
    volumes:
      - /home/vagrant/sincro:/etc/prometheus

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
________________________________________________________________________________________

Ahora debemos crear el directorio de prometheus y el archivo Dockerfile dentro de este.
________________________________________________________________________________________
mkdir prometheus
cd prometheus/
vim Dockerfile
________________________________________________________________________________________

El Dockerfile tendrá el siguiente archivo de configuración
________________________________________________________________________________________
FROM prom/prometheus

# Copiar el archivo de configuración a la imagen
COPY prometheus.yml /etc/prometheus/prometheus.yml

________________________________________________________________________________________
Ahora debemos crear el archivo de configuración de prometheus
________________________________________________________________________________________
 vim prometheus.yml
________________________________________________________________________________________
E introducir el siguiente archivo.

________________________________________________________________________________________
global:
  scrape_interval: 5s
  evaluation_interval: 5s
  scrape_timeout: 4s

scrape_configs:
  - job_name: 'node_exporter'
    scrape_interval: 5s
    scrape_timeout: 4s
    static_configs:
      - targets: ['192.168.50.10:9100', '192.168.50.20:9100']

________________________________________________________________________________________

una vez realizado esto volveremos al directorio de project y ejecutaremos el comando que sube los contenedores creados.
________________________________________________________________________________________
cd ..
docker-compose up -d
________________________________________________________________________________________

y verificamos el estado de los contenedores
________________________________________________________________________________________
docker ps
________________________________________________________________________________________

una vez realizado esto podemos acceder a desde el navegador a la ip: 192.168.50.30:9090 para observar el estado de prometheus, donde si todo salió correctamente debería mostrar desde la pestaña status>Targets las dos máquinas en estado UP.

Nota: Recuerde que en las máquinas de los servidores web debe estar el node exporter activo.

Para ver el servicio de grafana podemos acceder a desde el navegador a la ip: 192.168.50.30:3000 con las credenciales:
username: admin
password: admin

crear nueva contraseña, se recomienda una fácil de recordar como grafana

Para la configuración de los dashboards, en la barra lateral acceder a connections > Data sources seleccionar prometheus, en el apartado de connection se pone el URL http://192.168.50.30:9090/ y posteriormente se presiona “Save & test” posteriormente en la barra lateral se selecciona Dashboards, se crea un nuevo dashboard, se presiona “Import a dashboard” y se selecciona el dashboard de tu preferencia, se pueden buscar en la página https://grafana.com/grafana/dashboards/ o en su defecto se recomienda usar la ID del dashboard “11074” se carga el dashboard y en victorial metrics se selecciona el Data Source creado.





