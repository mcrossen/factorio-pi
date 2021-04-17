# factorio-pi
These instructions can be used to run x86 programs on ARM architectures. For this example, I will be installing an x86 factorio
headless server on a raspberry pi running raspbian, but the general method should be adjustable to work for any x86 program on
any ARM architecture running linux.

**WARNING running factorio server in this way is unstable and buggy and not ready for regular use. This guide is intended to be a mere proof of concept. My hope is that others will build and improve upon it.**

## problem
The factorio headless linux server is only available for x86 machines but the raspberry pi is ARM. To run on ARM processors,
like the raspberry pi, virtualization is required. Emulators like qemu-user-static work great for running statically linked
binaries on foreign machines but they don't include all dependancies needed to run dynamically linked executables. The latter
problem can be solved through containerization.

## instructions
First, we'll need to install some utilities. On your raspberry pi, open the 'terminal' application and run the following
commands to install two packages. The first, systemd-container, is used to run containers on your pi. The second,
qemu-user-static, is used to run foreign executables like the factorio headless server. The third, debootstrap, is used to download container images.
```
sudo apt update
sudo apt install systemd-container qemu-user-static qemu-utils debootstrap
```
We'll also need to download the factorio headless server executable itself and extract it.
```
wget https://www.factorio.com/get-download/stable/headless/linux64 -O ~/factorio-server.tar.xz
# or curl https://www.factorio.com/get-download/stable/headless/linux64 -L --output ~/factorio-server.tar.xz
tar -xJf ~/factorio-server.tar.xz -C ~/
rm ~/factorio-server.tar.xz
mkdir ~/factorio/saves/
```
You should now notice a new folder called 'factorio' in your home directory. This contains the config and executable to run the
factorio headless server. You'll probably want to change your server's name, description, and password from the default. To do
that, copy the configuration template and open the file in nano to customize whichever fields you want. Press 'ctrl-x', then
'y', then 'enter' to save and quit when you're done.
```
cp ~/factorio/data/server-settings.example.json ~/factorio/data/server-settings.json
nano ~/factorio/data/server-settings.json
```
You can try to run the server with `~/factorio/bin/x64/factorio`. You should get an error like "No such file or directory". This
means that you're missing the required x86-64 dependancies to run this dynamically linked executable. To fix that you'll need to
download the dependancies as a container image with the following command.
```
sudo qemu-debootstrap --arch=amd64 stable ~/factorio-runtime/ --variant=buildd
```
This downloads a copy of the debian filesystem onto your pi along with all standard x86-64 libraries and dependancies. The
second command copies the emulator into the file tree for use in the containerized environment. Feel free to use a different
x86-64 image if you like. You can now run your factorio server inside this container.
```
sudo systemd-nspawn -D ~/factorio-runtime --bind=/home/$USER/factorio:/factorio /factorio/bin/x64/factorio --start-server-load-latest /factorio/saves/ --server-settings /factorio/data/server-settings.json
```
You can connect to your server in factorio using the ip address of your pi. For example, if your pi has ip address 10.0.0.2 then
enter 10.0.0.2:34197 in the dialog box.
