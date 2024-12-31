server {
        listen      %ip%:%web_port%;
        server_name %domain_idn% %alias_idn%;
        root        %docroot%/application;
        index       index.php index.html index.htm;
        access_log  /var/log/nginx/domains/%domain%.log combined;
        access_log  /var/log/nginx/domains/%domain%.bytes bytes;
        error_log   /var/log/nginx/domains/%domain%.error.log error;

        # Include SSL forcing config (if applicable)
        include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

        # Main location block to handle requests
        location / {
                try_files $uri $uri/ /index.php?$query_string;

                # Custom rewrite rule for install.php
                rewrite ^(.*)/install.php$ /$1/install/redirect;
        }

        # PHP-FPM configuration for processing PHP files
        location = /index.php {
                include /etc/nginx/fastcgi_params; # Load default FastCGI params
                fastcgi_index index.php; # Default PHP entry point
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; # Set PHP script path
                fastcgi_pass %backend_lsnr%; # Pass to the backend PHP listener
                include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*; # Include caching configuration
        }

        # Security: Block access to hidden files (e.g., .git, .env)
        location ~ /\. {
                log_not_found off;
                return 404;
        }

        # Security: Block specific file types
        location ~* \.(php|pdt|txt)$ {
                log_not_found off;
                return 404;
        }

        # Handle custom error pages
        location /error/ {
                alias %home%/%user%/web/%domain%/document_errors/;
        }

        # Handle vstats (web stats) access
        location /vstats/ {
                alias   %home%/%user%/web/%domain%/stats/; # Path to stats files
                include %home%/%user%/web/%domain%/stats/auth.conf*; # Include auth configuration
        }

        # Include additional configurations
        include /etc/nginx/conf.d/phpmyadmin.inc*;
        include /etc/nginx/conf.d/phppgadmin.inc*;
        include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
