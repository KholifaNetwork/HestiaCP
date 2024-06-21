server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    # Root location block (Update %docroot%/blesta to your own Directory / @blesta is Default)
    root        %docroot%/blesta;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;

    include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

    # Security: Prevent access to hidden files
    location ~ /\.(?!well-known\/) {
        deny all;
        return 404;
    }

    # Main location block (Update @blesta to your own Directory / @blesta is Default)
    location / {
        try_files $uri @blesta;
        rewrite ^(.*)/install\.php$ /$1/install/ redirect;
    }

    # PHP-FPM configuration for index.php
    location = /index.php {
        try_files $uri =404;

        include /etc/nginx/fastcgi_params;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass %backend_lsnr%;
        include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*;
    }

    # Security: Block access to certain file types
    location ~ /\. {
        log_not_found off;
        return 404;
    }

    location ~* \.(php|pdt|txt)$ {
        log_not_found off;
        return 404;
    }

    # Error handling
    location /error/ {
        alias %home%/%user%/web/%domain%/document_errors/;
    }

    # Stats
    location /vstats/ {
        alias %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/web/%domain%/stats/auth.conf*;
    }

    # Include additional configurations
    include /etc/nginx/conf.d/phpmyadmin.inc*;
    include /etc/nginx/conf.d/phppgadmin.inc*;
    include %home%/%user%/conf/web/%domain%/nginx.conf_*;

    # Core rewrite (Update @blesta to your own Directory / @blesta is Default)
    location @blesta {
        rewrite ^(.*)$ /index.php?$1 last;
    }
}
