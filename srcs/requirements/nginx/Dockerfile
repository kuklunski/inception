FROM debian:bookworm

RUN apt-get update

RUN apt-get install -y nginx

RUN apt-get install -y openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=MA/ST=Marrakech/L=Marrakech/O=Ylemkere/OU=Ylemkere" \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt

COPY ./config/myconf.conf /etc/nginx/conf.d
    
CMD ["nginx", "-g", "daemon off;"]