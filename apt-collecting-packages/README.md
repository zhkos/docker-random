This dockerfile downloads packages for debian-based systems.
It creates a local repository with dpkg-dev so that you can install packages without the Internet.

How to use:

1. select the desired distribution and add it to the dockerfile
2. docker run --rm -v /home/user/dir_to_download/:/debsdir -e TARGET_PACKAGES="ping vim sl bash" pkgs:latest
3. On target server: deb [trusted=yes] file:///home/my_user/local_repo ./ in /etc/apt/sources.list
