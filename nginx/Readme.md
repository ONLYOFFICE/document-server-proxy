##How to use it
### Step 1 
Install Nginx server. How to do this, see [Nginx documentation](http://nginx.org/en/linux_packages.html#stable).

### Step 2
Put corresponding configuration file into /etc/nginx/conf.d/ directory.
Change the 'backend-server' statment in configuration file with the address where onlyoffice-documentserver run.

### Step 3
Reload nginx service. Run command:
```
sudo service nginx reload
```
