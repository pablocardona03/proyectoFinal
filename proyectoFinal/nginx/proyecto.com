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
