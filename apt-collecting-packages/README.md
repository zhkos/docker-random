This dockerfile is downloading packages for debian-based systems.
It creates a local repository with dpkg-dev so that you can install packages without the Internet.

How to use:

docker run --rm -v /home/user/dir_to_download/:/debsdir -e TARGET_PACKAGES="ping vim sl bash" pkgs:latest

On target server:
deb [trusted=yes] file:///home/my_user/local_repo ./ in /etc/apt/sources.list