# HTS Jupyter notebook container

As part of the National Institutes of Health (NIH) Big Data to Knowledge (BD2K)
initiative, the Department of Biostatistics and Bioinformatics, together with 
faculty from the Duke Center for Genomic and Computational Biology, has been 
funded to host a 6-week summer course from July 5–August 10 2017 on 
High Throughput Sequencing (HTS). Our goal is to teach the next generation 
of scientists the biological, statistical, computational and informatics 
knowledge for implementing a well-designed genomics experiment.

     https://biostat.duke.edu/education/high-throughput-sequencing-course

This is the source for the Docker container used to run the course Jupyter
notebooks. This is based on the Minimal Jupyter Notebook Stack from

    https://github.com/jupyter/docker-stacks

## What it Gives You

* Jupyter Notebook server (v4.0.x or v3.2.x, see tag)
* Conda Python 3.4.x
* Unprivileged user `jovyan` (uid=1000, configurable, see options) in group `users` (gid=100) with ownership over `/home/jovyan` and `/opt/conda`
* Options for HTTPS, password auth, and passwordless `sudo`

## Basic Use

The following command starts a container with the Notebook server listening for HTTP connections on port 8888 without authentication configured.

```
docker run -d -p 8888:8888 mccahill/jupyter-hts-2018
```

But you probably want to run the container something like this so that there is at least a password and you map a persistent directory to hold your notebooks in the container:

```
docker run -d -p 8888:8888 \
  -e PASSWORD="badpassword" \
  -v /your_homedir_path_here:/home/jovyan/work \
  -e NB_UID=1000 \
  mccahill/jupyter-hts-2018 
```

Of course, it would be better either configure HTTPS (see the options section below) or run an Nginx proxy in front of the container instance so you get https (encryption) instead of http.

## Options

You may customize the execution of the Docker container and the Notebook server it contains with the following optional arguments.

* `-e PASSWORD="YOURPASS"` - Configures Jupyter Notebook to require the given password. Should be conbined with `USE_HTTPS` on untrusted networks.
* `-e USE_HTTPS=yes` - Configures Jupyter Notebook to accept encrypted HTTPS connections. If a `pem` file containing a SSL certificate and key is not provided (see below), the container will generate a self-signed certificate for you.
* **(v4.0.x)** `-e NB_UID=1000` - Specify the uid of the `jovyan` user. Useful to mount host volumes with specific file ownership.
* `-e GRANT_SUDO=yes` - Gives the `jovyan` user passwordless `sudo` capability. Useful for installing OS packages. **You should only enable `sudo` if you trust the user or if the container is running on an isolated host.**
* `-v /some/host/folder/for/work:/home/jovyan/work` - Host mounts the default working directory on the host to preserve work even when the container is destroyed and recreated (e.g., during an upgrade).
* **(v3.2.x)** `-v /some/host/folder/for/server.pem:/home/jovyan/.ipython/profile_default/security/notebook.pem` - Mounts a SSL certificate plus key for `USE_HTTPS`. Useful if you have a real certificate for the domain under which you are running the Notebook server.
* **(v4.0.x)** `-v /some/host/folder/for/server.pem:/home/jovyan/.local/share/jupyter/notebook.pem` - Mounts a SSL certificate plus key for `USE_HTTPS`. Useful if you have a real certificate for the domain under which you are running the Notebook server.
* `-e INTERFACE=10.10.10.10` - Configures Jupyter Notebook to listen on the given interface. Defaults to '*', all interfaces, which is appropriate when running using default bridged Docker networking. When using Docker's `--net=host`, you may wish to use this option to specify a particular network interface.
* `-e PORT=8888` - Configures Jupyter Notebook to listen on the given port. Defaults to 8888, which is the port exposed within the Dockerfile for the image. When using Docker's `--net=host`, you may wish to use this option to specify a particular port.
