## What this is for
This guide explains how to setup your IIS to allow connections to DocumentServer instance with HTTP/HTTPS using IIS as reverse proxy. 

## How to use it

### Step 1
Edit the **web.config** file. Find `rewrite.rules` in the `configuration` section:
```
﻿<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
     <rewrite>
      <rules>
        <rule name="INIT_SERVER_VARIABLE_FROM_PROXY" stopProcessing="false">
          <match url=".*" /> 
          <serverVariables>		  
		    <set name="HTTP_THE_SCHEME" value="{HTTP_X_FORWARDED_PROTO}" replace="true" />			
			<set name="HTTP_THE_HOST" value="{HTTP_X_FORWARDED_HOST}" replace="true" />
          </serverVariables>
		  <action type="None" />
        </rule>	
		<rule name="INIT_SERVER_VARIABLE_DEFAULT" stopProcessing="false">
          <match url=".*" /> 
		  <conditions trackAllCaptures="true">
			<add input="{HTTPS}s" pattern="on(s)|offs" />
          </conditions>
          <serverVariables>		  
			 <set name="HTTP_THE_SCHEME" value="http{C:1}" replace="false" />			
			 <set name="HTTP_THE_HOST" value="{HTTP_HOST}" replace="false" />		
          </serverVariables>
		  <action type="None" />
        </rule>
                <rule name="ReverseProxyInboundRule1" stopProcessing="true">
                    <match url="(.*)" />
                    <action type="Rewrite" url="http://<ds_address>/{R:1}" />
                    <conditions>
                        <add input="{HTTPS}s" pattern="on(s)|offs" />
                    </conditions>
                    <serverVariables>
                        <set name="HTTP_X_FORWARDED_PROTO" value="{HTTP_THE_SCHEME}" />
                        <set name="HTTP_X_FORWARDED_HOST" value="{HTTP_THE_HOST}" />
                    </serverVariables>
                </rule>
      </rules>
    </rewrite>

  </system.webServer>
</configuration>
```
And replace the `<ds_address>` value with DocumentServer real IP (when on local network) or Internet address. After that Workspace will be accessible from your IIS ip/dns address.

### Step 2
Install the additional IIS components:
* [Application Request Routing](https://www.iis.net/downloads/microsoft/application-request-routing) - you can download it here - https://www.iis.net/downloads/microsoft/application-request-routing. After the download, run the installation file and follow the wizard. Then go to the IIS manager, open ARR settings and check the **Enable proxy** check-box.
* [URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite) - you can download it here - https://www.iis.net/downloads/microsoft/url-rewrite. After the download, run the installation file and follow the wizard. Then go to the **Control Panel**, choose **Programs and Features**, then **Turn Windows features on or off** and there expand **Internet Information Services** > **World Wide Web Services** > **Application Development Features** and check the **WebSocket Protocol** option. Click **OK** and wait until the feature is installed.

### Step 3
Add IIS server variables. You will need to add `HTTP_X_FORWARDED_PROTO`,`HTTP_X_FORWARDED_HOST`,`HTTP_THE_SCHEME` and `HTTP_THE_HOST` as new IIS server variables. This can be done the following way:
* Go to the IIS Manager, select the website, then open **URL Rewrite**.
* In the right-side menu locate **Manage Server Variables** and click **View Server Variables**.
* Use the **Add...** action and add the `HTTP_X_FORWARDED_PROTO`,`HTTP_X_FORWARDED_HOST`,`HTTP_THE_SCHEME` and `HTTP_THE_HOST` one after another.
More information on adding the variables to the IIS server can be found [here](https://www.iis.net/learn/extensions/url-rewrite-module/setting-http-request-headers-and-iis-server-variables).

> **Tip**: This config also can be used for proxy connections for some another products. For example Docker-Workspace.
