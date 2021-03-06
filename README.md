# Note:

Thanks to @ids1024, this should no longer be necessary for most users trying to connect to a pulseconnect vpn server. You should be able to use openconnect (pacman -S openconnect), though your mileage may vary based on the configuration of the server.

e.g.: 
  `sudo openconnect --juniper vpn.library.ucdavis.edu`

-----

# Pulse Connect Secure Client

## Description

Arch package for the Pulse Connect Secure client.

## Installation

git clone this repository or download the source, then cd into the source directory and run ```makepkg -ci```

## Usage

### Start the VPN Client

To run the client (from the official documentation): 

```sh
/opt/pulse/PulseClient.sh -h <hostname/IP> -u <VPN username> [-p <VPN password>] [-r <realm>] [-U <PCS signinurl>] [-y <proxy IP/hostname>] [-z <proxy port>]
```
__Note:___ The client does not provide feedback when a connection has been successfully established. It will keep running in the background, even if you hit Ctl-C.

You should leave out the ```-p``` (password) option so that it prompts you to enter the password securely so that your password doesn't end up in cleartext in your command history.

If you don't include the realm, it will default to Users.

### Stop the VPN Client

To kill the VPN client:

```sh
/opt/pulse/PulseClient.sh -K
```

## Package Info

Built from an RPM found on the UC Davis library website since Pulse doesn't make the client publicly available.

This package will only install the command-line tool since the pulseUi is broken on x64 systems. I tried to get it to work correctly, but it depends on lib32-webkitgtk (and several other 32-bit libs), which is no longer available on AUR and wouldn't build successfully after numerous attempts.

There are some extra deps that don't need to be there, but I haven't tried uninstalling them to see which ones will break it. webkitgtk is definitely not needed since it's only used for the broken UI.

