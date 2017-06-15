# Deployment / Hosting
The server-side components (everything but the frontend) of the application is put on a remotely accessible machine. This machine(s) is associated with a URL, through which the frontpage is requested and interaction with the API is performed. To ensure that this process of deployment is as uniform as possible, the container platform *Docker* is used.

## General info
This describes some general info about the used technologies and services.

### Docker
Docker is a container platform. It allows for the creation of containers, in which an application is placed in an isolated environment. This environment can be reproduced on any machine (that has Docker), such that behaviour will be the same everywhere. Docker containers are created using a Docker configuration script, the so called `Dockerfile`. Using this script, a container image can be created. These images are binary files, that contain the entire operating environment, but also execution instructions, for the application to run. This binary can then be put on any machine, where this contained application will be run.

### Heroku
Heroku is an application platform, that is currently used for hosting this application. Heroku will run an executable, which is usually a webservice, such that it is remotely accessible. Heroku supports Docker images. This means a Docker container image can be uploaded to Heroku, and Heroku will run it as a webservice.

Note that Heroku requires a user account before its services can be utilised. Also, through following the instructions on the Heroku website, a web project should be created. This allocates dyno space and an URL.

## Setting up
Building a Docker image, and uploading it to Heroku is explained here as follows.

For these instructions it is assumed that Docker is installed on the build machine; and if Heroku is used, it is assumed that an Heroku account is created, as well as a Heroku web project.

It follows the following general steps:

* Setup the local file structure
* Build the Docker image
* Push the image to Heroku

### Setup local file structure
The `Dockerfile` as it is currently provided expects the following directory structure:
```
Dockerfile
environment.yml
app/ # Clone the `2017-Web-Service-Author-Analysis` repo (deployment branch) here
|- backend/
|  |- resources/
|  |  |- glad/ # Clone the `rug-authorship-web` repo (deployment branch) here
|  |- # All other backend files are here
|
|- frontend/
|  |- # All frontend files are here
```
If adhered to this file structure, it should be setup properly.
Note, however, that these directories should contain ALL resources required to run. (attribution models, etc. - These are currently in the `deployment` branch of the repo; make sure this is always the case)

### Build Docker image
The Docker image is built by Docker, for which the `Dockerfile` configuration script is used. Execute from main directory (the directory in which `app/` and `Dockerfile` are located):
```
docker build -t author .
```
Note here that `author` is the name of the image, and is arbitrary; as long as the same name is used whenever this image is referenced.
This takes a while, as it will be building the entire application. This will likely take several gigabytes of storage space.

### Push image to Heroku
*These instructions are specific for Heroku, but will likely be similar if another service platform is used.*

The image that previously was built can now be uploaded to Heroku. This is done using the following two commands:
```
docker tag author registry.heroku.com/aabeta/web
docker push registry.heroku.com/aabeta/web
```
The first command tags the newly built image, so that Docker knows which image should be uploaded. This should be performed every time a new image is built; otherwise the old image (from the previous build) will be uploaded again.
The second command will upload the entire image to Heroku. Although Docker only uploads incremental changes (only files that were not there before), it likely still requires uploading several gigabytes of data, and might take a while depending on the network speed.

Note that this will push to the Heroku project `aabeta`, which is the name of the Heroku project that is under the control of the development team of this application. Anybody else will likely have another Heroku project, which also has a different name. In that case, substitute `aabeta` by the name of the Heroku project of which ownership is acquired.

### Making changes
Whenever a change is made to the project which is to be published, the steps in section 'Setting up' still apply.

Make sure the contents of the local files represent the state of the project that is to be published (This means pull everything from Git). Then build the docker image again, and push it to Heroku.

## Dockerfile
The contents of the `Dockerfile` are posted in this section. These contents are not posted in their own individual file, because that would imply a different file structure than is described in section 'Setup local file structure'. This explicitely removes the `Dockerfile` from the filestructure.
Note that this `Dockerfile` is specifically created for use with Heroku. It will likely work with different services, but issues could be caused when these services run different versions of Docker.
The `Dockerfile` is as follows:
```text
FROM debian:latest

WORKDIR /app

### Install dependencies ###

RUN apt-get -qq update

# Install Node.js
RUN apt-get -qq -y install curl python-software-properties
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get -qq -y install nodejs
RUN npm install -g nodemon
RUN npm install -g elm

# Install Anaconda
RUN apt-get -qq -y install wget bzip2
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /bin/anaconda
RUN rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH="/bin/anaconda/bin:$PATH"
RUN /bin/bash -c "conda update -y conda"

# Setup conda environment
ADD environment.yml .
RUN /bin/bash -c "conda env create -q -f=environment.yml"
RUN /bin/bash -c "rm ./environment.yml"

### Setup application ###

ADD app /app

WORKDIR /app/frontend
RUN elm-package install -y

WORKDIR /app/backend

ENV NLTK_DATA="/app/backend/nltk_data"
RUN /bin/bash -c "source activate glad && python3 -m nltk.downloader -d $NLTK_DATA punkt"

RUN npm install
RUN npm run build-frontend:linux

EXPOSE 8080  # This is ignored by Heroku, but is great for local execution
CMD ["/bin/bash", "-c", "source activate glad && npm run deploy:linux"]
```

## environment.yml
The current `Dockerfile` expects a `environment.yml` file that described the required Conda environment. This file should be in the same directory as the `Dockerfile` and `app/` directory.
```yml
name: glad
channels:
- defaults
dependencies:
- libgfortran=3.0.0=1
- mkl=2017.0.1=0
- nltk=3.2.2=py35_0
- numpy=1.12.0=py35_0
- openssl=1.0.2k=1
- pip=9.0.1=py35_1
- python=3.5.3=0
- readline=6.2=2
- scikit-learn=0.18.1=np112py35_1
- scipy=0.18.1=np112py35_1
- setuptools=27.2.0=py35_0
- six=1.10.0=py35_0
- sqlite=3.13.0=0
- tk=8.5.18=0
- wheel=0.29.0=py35_0
- xz=5.2.2=1
- zlib=1.2.8=3
```
