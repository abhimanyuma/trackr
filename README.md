# About Trackr

Trackr /t'rækə(r)/ is a simple web application to track contact with companies written in Ruby on Rails.

# Deployment

Ensure you have nginx installed (`apt-get install nginx` or equivalent), 

`cp trackr.conf.nginx /etc/nginx/sites-available/trackr.conf`

link via: `sudo ln -s /etc/nginx/sites-available/trackr.conf /etc/nginx/sites-enabled/`

Generate a certificate:

`# openssl req -new -x509 -days 365 -nodes -out /etc/nginx/trackr.pem -keyout /etc/nginx/trackr.key`

Add `127.0.0.1 trackr.dev` to `/etc/hosts` and reload nginx

Specify `APP_ROOT` & `AS_USER` variables in `config/unicorn_init.sh`

Specify `root` variable in `config/unicorn.rb`

> fix other variable if need be

To deploy:
> ensure db is created; from inside `trackr/` folder

`./config/unicorn_init.sh start`


## Credits

- Abhimanyu M A @abhimanyuma abhi@manyu.in
