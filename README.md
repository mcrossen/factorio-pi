
# factorio-pi
[![Release](https://github.com/mcrossen/factorio-pi/workflows/Release/badge.svg)](https://github.com/mcrossen/factorio-pi/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/markcrossen/factorio-pi.svg?maxAge=600)](https://hub.docker.com/r/markcrossen/factorio-pi/)
[![Docker Stars](https://img.shields.io/docker/stars/markcrossen/factorio-pi.svg?maxAge=600)](https://hub.docker.com/r/markcrossen/factorio-pi/)

> [!WARNING]
> running factorio server in this way is unstable, slow, and might crash your pi

## deprecated
If your pi is running a 64 bit operating system, then it is highly recommend to
first try using [factoriotools/factorio](https://hub.docker.com/r/factoriotools/factorio).
To determine whether your pi is 64 bit, run the following from a terminal:
```
uname -m  # should say 'aarch64' for 64 bit operating system
```

If your pi is NOT 64 bit, then feel free to try the docker image from this repo.
Ultimately both repos will have difficulties because factorio wasn't made to run
on ARM hosts.

## usage
First, install docker on your raspberry pi

```
sudo apt install docker.io
```

Next, create a folder to hold your savegame and the autosaves. Transfer your
existing save into it.
```
mkdir ~/factorio-saves/
mv /path/to/existing/save.zip ~/factorio-saves/
```

Now create and run the docker container
```
sudo docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v ~/factorio-saves:/home/factorio/saves \
  --name factorio \
  markcrossen/factorio-pi
```

If you're new to docker, lets go over each argument to the above command:
- `-d` run in 'detached' mode so it doesn't capture keyboard input
- `-p 34197:34197/udp -p 27015:27015/tcp` the default network ports required to run
factorio
- `-v ~/factorio-saves:/home/factorio/saves` allow the container to read the folder
where you placed your save
- `-v ~/factorio-settings:/home/factorio/settings` allow the container to read the
folder where you placed your custom server-settings.json
- `--name factorio` names the container to make it easier to start and stop
- `markcrossen/factorio-pi` the docker image to run that contains all dependencies

To stop the server, run the following
```
sudo docker stop factorio
```

To [re]start the server, run the following
```
sudo docker start factorio
```

## problems
> Why is running factorio on a raspberry pi so hard?

The factorio headless linux server is only available for x86 machines but the
raspberry pi has an ARM CPU. To run on ARM processors, like the raspberry pi,
virtualization is required.

> Why is this slow?

Using virtualization/emulators is slower than running factorio on a normal x86
machine because the emulator has a large overhead.

> Why do I need to install docker and run a container?

Emulators like qemu-user-static work great for running
statically linked binaries on foreign machines but they don't include all
dependancies needed to run dynamically linked executables such as factorio. The
latter problem can be solved by shipping all x86 dependencies alongside the emulator
and executable. This is most easily done through containerization.

## contributing
Pull requests welcome!