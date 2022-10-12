## How to use it

## Nginx

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

## Ansible-playbook

Also DocumentServer can be installed on virtual path behind nginx proxy with ansible. 

Below present playbook that you can use for it.

Variables, that can be configured before execute playbook:

- **ds_backend_address**: Address where backend docservice is actualy running. By default `localhost:8000`
- **ds_virtual_path**: The virtual path for backend documentserver. By default `<nginx_server_address>/ds_path/`

       - hosts: all
   
         vars:
           nginx_package_name: "nginx-extras"
           nginx_worker_connections: "768"
           nginx_keepalive_timeout: "65"
           nginx_server_tokens: "off"
           ds_virtual_path: "ds_path"
           ds_backend_address: "localhost:8000"
  
           nginx_extra_http_options: |
             proxy_set_header Upgrade $http_upgrade;
             proxy_set_header Connection $proxy_connection;
             proxy_set_header X-Forwarded-Host $the_host/{{ ds_virtual_path }};
             proxy_set_header X-Forwarded-Proto $the_scheme;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
             map $http_x_forwarded_proto $the_scheme {
                default $http_x_forwarded_proto;
                "" $scheme;
             }
 
             map $http_x_forwarded_host $the_host {
                default $http_x_forwarded_host;
                "" $host;
             }
     
             map $http_upgrade $proxy_connection {
                default upgrade;
                "" close;
             }
  
           nginx_vhosts:
             - listen: "80 default_server"
               server_name: "documentserver"
               server_tokens: "off"
               template: "{{ nginx_vhost_template }}"
               filename: "ds.conf"
               extra_parameters: |
                 location /{{ ds_virtual_path }}/ {
                     proxy_pass http://docservice/;
                     proxy_http_version 1.1;
                 }

           nginx_upstreams:     
             - name: docservice
               servers:
                 - "{{ ds_backend_address }}"


           postgresql_global_config_options:
             - option: listen_addresses
               value: "*"
             - option: unix_socket_directories
               value: '{{ postgresql_unix_socket_directories | join(",") }}'
             - option: log_directory
               value: 'log'

           postgresql_hba_entries:
             - type: local
               database: all
               user: postgres
               auth_method: peer
             - type: local
               database: all
               user: all
               auth_method: peer 
             - type: host
               database: all
               user: all
               address: 127.0.0.1/32
               auth_method: md5
             - type: host
               database: all
               user: all
               address: ::1/128
               auth_method: md5
             - type: host
               database: all
               user: all
               address: 0.0.0.0/0
               auth_method: md5

           postgresql_databases:
             - name: "{{ db_server_name }}"

           postgresql_users:
             - name: "{{ db_server_user }}"
               password: "{{ db_server_pass }}"

           rabbitmq_users:
             - name: "{{ rabbitmq_server_user }}"
               password: "{{ rabbitmq_server_pass }}"
               vhost: "{{ rabbitmq_server_vpath }}"
               configure_priv: .*
               read_priv: .*
               write_priv: .*
               tags: administrator

           rabbitmq_users_remove: []

           redis_bind_interface: 0.0.0.0

         roles:
           - geerlingguy.nginx
           - geerlingguy.postgresql
           - geerlingguy.redis
           - ONLYOFFICE.rabbitmq
           - ONLYOFFICE.documentserver

Note: When execute playbook, you need redefine `nginx_vhost_path` variable in geerlingguy.nginx with extra-variable parameter like that: 

     ansible-playbook <playbook_name>.yaml -e "nginx_vhost_path=/etc/nginx/conf.d"
