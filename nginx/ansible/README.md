## Virtual path ansible-playbook

To install a DocumentServer into a virtual directory behing nginx proxy with Ansible, you need to follow a few steps.  

### Step 1 

Install ansible if not already installed, installation instructions can be found [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Step 2 

Clone this repository on your local machine

```bash
git clone https://github.com/ONLYOFFICE/document-server-proxy.git
```

### Step 3 

Navigate to cloned repository to directory `document-server-proxy/nginx/ansible`

### Step 4 

Make your [ansible inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) and execute the ansible playbook command:

```bash 
ansible-playbook -i <inventory_file_name> virtual-path-playbook.yaml
```

Note: Inside the `virtual-path-playbook.yaml` you can also override the port variable on which the DocumentServer will be installed. `42800` by default.