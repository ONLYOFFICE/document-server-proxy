## Ansible-playbook

DocumentServer can be installed on virtual path behind nginx proxy with ansible. 

Below present playbook that you can use for it.

Variables, that can be configured before execute playbook:

- **ds_port**: Set the value of the port variable on which the document server is running.

       - hosts: all
   
         vars:
           nginx_package_name: "nginx"
           nginx_remove_default_vhost: true
           ds_port: ""
  
           nginx_extra_http_options: |
             proxy_set_header Upgrade $http_upgrade;
             proxy_set_header Connection $proxy_connection;
             proxy_set_header X-Forwarded-Host $the_host/ds_virtual_path;
             proxy_set_header X-Forwarded-Proto $the_scheme;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
           nginx_vhosts:
             - listen: "80 default_server"
               server_name: “”
               server_tokens: "off"
               template: "{{ nginx_vhost_template }}"
               filename: "onlyoffice.conf"
               extra_parameters: |
                 location /ds_virtual_path/ {
                     proxy_pass http://localhost:{{ ds_port }}/;
                     proxy_http_version 1.1;
                 }

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
           - geerlingguy.postgresql
           - geerlingguy.redis
           - onlyoffice.rabbitmq
           - onlyoffice.documentserver
           - geerlingguy.nginx
                

Note: When execute playbook, you need redefine `nginx_vhost_path` variable in geerlingguy.nginx with extra-variable parameter like that: 

     ansible-playbook <playbook_name>.yaml -e "nginx_vhost_path=/etc/nginx/conf.d"

