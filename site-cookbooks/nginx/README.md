Installs nginx from package OR source code and sets up configuration
handling similar to Debian's Apache2 scripts.

## Requires
* [apt][1] (for nginx::default)
* build-essential (for nginx::source)

## Platform
Debian or Ubuntu though may work where 'build-essential' works.
Only tested on Ubuntu.

## Apps
Take this SSL-only app being served by [rainbows][2]:

```ruby
:nginx => {
  :distribution => 'precise',
  :components => ['main'],
  :apps => {
    :myapp_ssl => {
      :listen      => [443],
      :server_name => "www.domain.com",
      :public_path => "/home/myapp/app/public",
      :try_files   => [
        "$uri @myapp_ruby"
      ],
      :locations   => [
        {
          :path => "@myapp_ruby",
          :directives => [
            "proxy_set_header X-Forwarded-Proto $scheme;",
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;",
            "proxy_set_header X-Real-IP $remote_addr;",
            "proxy_set_header Host $host;",
            "proxy_redirect off;",
            "proxy_http_version 1.1;",
            "proxy_set_header Connection '';",
            "proxy_pass http://myapp_ruby;"
          ]
        }
      ],
      :upstreams => [
        {
          :name => "myapp_ruby", # defaults to your apps name (eg. myapp_ssl)
          :servers => [
            "unix:/home/myapp/app/tmp/web.sock max_fails=3 fail_timeout=1s",
            "failover-host:5000 max_fails=3 fail_timeout=1s backup"
          ]
        }
      ],
      :custom_directives => [
        "ssl on;",
        "ssl_certificate /var/certs/myapp.crt;",
        "ssl_certificate_key /var/certs/myapp.key;",
        "ssl_session_cache shared:SSL:10m;",
        "ssl_session_timeout 10m;"
      ]
    }
  }
}
```

We're running the ruby app on the local host and we're using a unix
socket to connect to it. If for whatever reason the local app is
inaccessible, we're falling back to a different host and connecting on
TCP socket 5000.

In a horizontally scalable environment, your front-end servers will only
run nginx (so no chance of proxying to a unix socket). You will have
multiple back-end servers to which nginx will connect via TCP sockets.

The `proxy_set_header Connection` directive is a hint that this cookbook
supports [nginx upstream keepalive][3]. Default is 4 connections. This can be
easily adjusted via the **nginx_app** provider.

If you find yourself specifying the `proxy_set_header` directives for
multiple nginx apps, you can extract them into a common config file, eg.
`/etc/nginx/conf.d/proxy.conf`. Same is true for ssl directives.

[More nginx load balancing and reverse proxying tips] [4].

[1]: https://github.com/gchef/apt-cookbook
[2]: http://rainbows.rubyforge.org/
[3]: http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive
[4]: http://spin.atomicobject.com/2012/02/28/load-balancing-and-reverse-proxying-with-nginx
