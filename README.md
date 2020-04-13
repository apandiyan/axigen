# Axigen Docker Image

These images are based on CentOS 8 with Axigen 10.3.1 pre-installed and pre-configured.

### Table of Contents
**[Image Types](#image-types)**<br>
**[Tags Explanation](#tags-explanation)**<br>
**[Usage Instructions](#usage-instructions)**<br>
**[Building Image](#building-image)**<br>
**[Upgrade Axigen](#upgrade-axigen)**<br>
**[Feedback](#feedback)**<br>

## Types of Image

Currently we support two types of image are

  - Pre-installed
  - Pre-installed and Pre-configured

#### Pre-installed

This image contains Axigen 10.3.1 with latest patches such as 10.3.1.10. Checkout [Building Image](#building-image) to build image with latest patches available for the version of 10.3.1.

#### Pre-installed and Pre-configured

This image contains Axigen 10.3.1 with latest patches such as 10.3.1.10 and initialized with onboarding configurations are

  - Basic Acceptance Routing
  - Admin Password
  - Services
    - SMTPS, POPS, IMAPS, Webmail(HTTPS), Webadmin(HTTP), CLI, FTP

## Tags Explanation

Currently we support three tags are

```
  latest    : pre-installed image
  10.3.1    : pre-installed image
  10.3.1-pc : pre-installed and pre-configured image
```

## Usage Instructions

#### Environment Variables

Request you to use these environment variables while using pre-configured image.

```
  AXIGEN_ADMIN_PASSWORD       : to update admin password of axigen<br>
  AXIGEN_ADMIN_PASSWORD_FILE  : to support swarm secrets<br>
  AXIGEN_PRECONFIGURED        : yes | no. to apply pre-configuration<br>
```


#### Deploy Containers

For pre-installed image

```bash
sudo docker run -itd --rm -v axigen_data:/var/opt/axigen -p 9000:9000 -p 7000:7000 -p 443:443 -p 21:21 -p 465:465 -p 995:995 -p 993:993 apandiyan/axigen:10.3.1
```

For pre-installed and pre-configured image

```bash
sudo docker run -itd --rm -v axigen_data:/var/opt/axigen -e AXIGEN_ADMIN_PASSWORD="Soft@run56" -e AXIGEN_PRECONFIGURED="yes" -p 9000:9000 -p 7000:7000 -p 443:443 -p 21:21 -p 465:465 -p 995:995 -p 993:993 apandiyan/axigen:10.3.1-pc
```

Apply license while deploying container

```bash
sudo docker run -itd --rm -v axigen_data:/var/opt/axigen -v ./axigen_lk.bin:/var/opt/axigen/axigen_lk.bin apandiyan/axigen:10.3.1
```

Deploy container using docker-compose

```bash
sudo docker-compose -p axigen -f docker-compose.yml up -d
```

You can change docker-compose.yml as per your need

```yaml
version: '3'
services:
  axigen:
    image: apandiyan/axigen:10.3.1-pc
    environment:
      - AXIGEN_PRECONFIGURED=yes
      - AXIGEN_ADMIN_PASSWORD=unknownadmin
    ports:
      - 9000:9000
      - 7000:7000
      - 21:21
      - 443:443
      - 465:465
      - 995:995
      - 993:993
    volumes:
      - axigen_data:/var/opt/axigen
      - ./axigen_lk.bin_secure:/var/opt/axigen/axigen_lk.bin:ro

volumes:
  axigen_data:
```

Deploy service on docker swarm

```bash
sudo docker config create axigen-license ./axigen_lk.bin_secure
sudo docker secret create adminpass ./axigen_admin_secure
sudo docker network create --driver overlay axigen-net

sudo docker service create --name axigen --mount type=volume,source=axigen_data,target=/var/opt/axigen --config source=axigen-license,target=/var/opt/axigen/axigen_lk.bin --secret adminpass -e AXIGEN_ADMIN_PASSWORD_FILE=/run/secrets/adminpass -e AXIGEN_PRECONFIGURED=yes -p 9000:9000 -p 7000:7000 -p 443:443 -p 21:21 -p 465:465 -p 995:995 -p 993:993 --network axigen-net apandiyan/axigen:10.3.1-pc
```

In here, we are using

> docker config : to apply license<br>
> docker secret : as admin password to set<br>


## Building Image

#### Build Arguments

```
  BASE_IMAGE                      : to change base image
  AXIGEN_VERSION                  : version of axigen in 3 digits (10.3.x)
  AXIGEN_PRECONFIGURE             : yes | no. to pre-configure axigen
  AXIGEN_PRECONFIGURE_SMTPFILTERS : yes | no. to pre-configure basic acceptance routing
```

#### Building pre-installed image

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1 .
```

#### Building pre-configured image

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1-pc --build-arg AXIGEN_VERSION=10.3.1 --build-arg AXIGEN_PRECONFIGURE="yes" --build-arg AXIGEN_PRECONFIGURE_SMTPFILTERS="yes" .
```

#### Building on your base image

Some people/companies want to use their base image so they can have more control on container what they are running on thier premises. For them

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1 --build-arg BASE_IMAGE=centos .
```

**Note:** You can use build arguments to have pre-configured image.

This command will use the image centos:latest reside in your images or else will pull from [Docker Hub](https://hub.docker.com).

## Upgrade Axigen

There is small difference between update and upgrade are

  > update  : to update version from 10.3.1.1 to 10.3.1.10<br>
  > upgrade : to update version from 10.3.1.x to 10.x.x<br>

To update, use any section of [Building Image](#building-image). <br>
To upgrade, use any section of [Building Image](#building-image) with [Build Arguments](#build-arguments).


## Feedback

All bugs, feature requests, pull requests, feedback, etc., are welcome. [Create an issue](https://github.com/apandiyan/axigen/issues).
