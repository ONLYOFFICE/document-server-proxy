## What this is for
This guide explains how to set your IIS to allow connecting **Document Server** using a virtual path (i.e. when Document Server address is not the root domain address, but is a virtual folder inside the address, e.g. http://docservice/documentserver-virtual-path/).

## How to use it

### Step 1
Edit the **web.config** file. Find `rewrite.rules` in the `configuration` section:
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="DocumentServerRewrite" enabled="true">
          <match url="^documentserver-virtual-path(.*)" />
            <conditions trackAllCaptures="true">
              <add input="{HTTPS}s" pattern="on(s)|offs" />
            </conditions>
            <serverVariables>
              <set name="HTTP_X_FORWARDED_PROTO" value="http{C:1}" />
              <set name="HTTP_X_FORWARDED_HOST" value="{HTTP_HOST}/documentserver-virtual-path" />
            </serverVariables>
            <action type="Rewrite" url="http://docservice{R:1}" />
         </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```
And replace the `docservice` value with **Document Server** real IP (when on local network) or Internet address. The `documentserver-virtual-path` value must be changed to **Document Server** virtual folder address.

### Step 2
Install the additional IIS components:
* [Application Request Routing](https://www.iis.net/downloads/microsoft/application-request-routing) - you can download it here - https://www.iis.net/downloads/microsoft/application-request-routing. After the download, run the installation file and follow the wizard. Then go to the IIS manager, open ARR settings and check the **Enable proxy** check-box.
* [URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite) - you can download it here - https://www.iis.net/downloads/microsoft/url-rewrite. After the download, run the installation file and follow the wizard. Then go to the **Control Panel**, choose **Programs and Features**, then **Turn Windows features on or off** and there expand **Internet Information Services** > **World Wide Web Services** > **Application Development Features** and check the **WebSocket Protocol** option. Click **OK** and wait until the feature is installed.

### Step 3
Add IIS server variables. You will need to add `HTTP_X_FORWARDED_PROTO` and `HTTP_X_FORWARDED_HOST` as new IIS server variables. This can be done the following way:
* Go to the IIS Manager, select the website, then open **URL Rewrite**.
* In the right-side menu locate **Manage Server Variables** and click **View Server Variables**.
* Use the **Add...** action and add the `HTTP_X_FORWARDED_PROTO` and `HTTP_X_FORWARDED_HOST` one after another.
More information on adding the variables to the IIS server can be found [here](https://www.iis.net/learn/extensions/url-rewrite-module/setting-http-request-headers-and-iis-server-variables).
