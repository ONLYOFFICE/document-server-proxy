##How to use it
### Step 1 
Install Nginx server. How to do this, see [Nginx documentation](http://nginx.org/en/linux_packages.html#stable).

### Step 2
Delete the default site configuration file /etc/nginx/conf.d/default.conf and /etc/nginx/sites-enabled/default. 
Put corresponding configuration file into /etc/nginx/conf.d/ directory.
Change the 'backend-server' statment in configuration file with the address where onlyoffice-documentserver run.
Make sure that the file /etc/nginx/nginx.conf include files from /etc/nginx/conf.d/ like this
```
include /etc/nginx/conf.d/*.conf;
```
### Step 3
Reload nginx service. Run command:
```
sudo service nginx reload
```
