require 'librarian/chef/integration/knife'
cookbook_path Librarian::Chef.install_path,
              "site-cookbooks"
ssl_verify_mode :verify_peer