maintainer        "Gerhard Lazu"
maintainer_email  "gerhard@lazu.co.uk"
license           "Apache 2.0"
description       "Installs and configures nginx"
version           "2.7.1"

recipe "nginx", "Installs nginx package and sets up configuration with Debian apache style with sites-enabled/sites-available"
recipe "nginx::source", "Installs nginx from source and sets up configuration with Debian apache style with sites-enabled/sites-available"
recipe "nginx::apps", "Sets up a reverse proxy for every app, regardless whether it's Ruby, node.js. For Python, you should use the uwsgi_pass proxy_type"
recipe "nginx::status", "Enables nginx status on http://nginx_status"
recipe "nginx::disable", "Disables favicon.ico & robots.txt logging, denies access to .hidden files"
recipe "nginx::real_ip", "Correctly updates the client IP address from the request header, defaults to ELB X-Forwarded-For"

supports "ubuntu"
supports "debian"

depends "build-essential"
depends "apt"
