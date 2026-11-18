
# Attach to a running container to the vscode

Return to [main page](README.md).<br>
We will exemplify using **dev-cortex-111721** development container.

## Configure form interface
1. Open Command Palette (Ctrl+Shift+P)
2. Select **Dev Containers: Open Attached Containers Config**
3. Choose the container configuration **dev-cortex-111721**
4. Edit the config file, add remoteuser etc.
``` json
{
	"remoteUser": "valentin",
	"workspaceFolder": "/work"
}
```

## Edit the File directly, even programatically
The *Dev Containers* plugin stores the config file at this location. The config *.json file has the same name as the docker container:

`~/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/imageConfigs/dev-cortex-111721.json`

```
```
