# Docker PHP 7.1 base image

## Services included

* PHP 7.1 FPM from official php docker image
* Nginx 1.11
* Supervisor

## Usage

### 1. Add vhost

Put file in dir `etc/nginx.d/example.conf`:
```
server {
    listen 80 default_server;

    server_name _;

    root /var/www;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location = /_healthcheck {
        return 204;
    }

    location ~ /\. {
        deny all;
    }

    location ~ \.php(/|$) {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        fastcgi_param  SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param  DOCUMENT_ROOT   $realpath_root;
        fastcgi_param  REMOTE_ADDR     $http_x_real_ip if_not_empty;
        fastcgi_param  HTTPS           $forwarded_proto_https;
                
        # extra fcgi php params
        fastcgi_intercept_errors on;
        fastcgi_read_timeout 300;
        send_timeout 300;

        expires epoch;
    }
}
```

### 2. Adjust php settings

Edit `usr/local/etc/php-fpm.d/app.conf` add custom settings

### 3. Install additional php extensions

Details https://hub.docker.com/_/php/ 

#### PHP Core Extensions

In Dockerfile add for example:

```
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
```

#### PECL extensions

In Dockerfile add for example:

```
RUN pecl install redis-3.1.0 \
    && pecl install xdebug-2.5.0 \
    && docker-php-ext-enable redis xdebug
```

## Advanced configuration

Base image https://hub.docker.com/_/php/
PHP is installed in `/usr/local/etc/`.

### Nginx

Vhost dir is `/etc/nginx/apps.d`
Files from `etc/nginx.d/` are copied to container dir `/etc/nginx/apps.d`

### PHP FPM configuration structure

```
/usr/local/etc/php-fpm.d
    - docker.conf (base file, global and www settings)
    - www.conf (default www.conf)
    - www.conf.default (not used, just for backup)
    - zz-docker.conf (docker settings, overriding previous files)
    - zzz-last.conf (last custom settings, file copied from "config/fpm.d/app.conf", overriding settings from previous files)
```

### Overriding settings

- Files from `etc/` are copied and overriding files in container `/etc`
- Files from dir `usr/local/etc` are copied and overriding files in container `/usr/local/etc`
