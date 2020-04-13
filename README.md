# Axigen Docker Image
<hr />
These images are based on CentOS 8 with Axigen 10.3.1 pre-installed and pre-configured.

### Table of Contents
**[Image Types](#image-types)**<br>
**[Tags Explanation](#tags-explanation)**<br>
**[Usage Instructions](#usage-instructions)**<br>
**[Building Image](#building-image)**<br>
**[Feedback](#feedback)**<br>

## Types of Image
<br>
Currently we support two types of image are
  - Pre-installed
  - Pre-installed and Pre-configured

#### Pre-installed
<br>
This image contains Axigen 10.3.1 with latest patches such as 10.3.1.10.

#### Pre-installed and Pre-configured
<br>
This image contains Axigen 10.3.1 with latest patches such as 10.3.1.10 and initialized with onboarding configurations are

  - Basic Acceptance Routing
  - Admin Password
  - Services
    - SMTPS, POPS, IMAPS, Webmail(HTTPS), Webadmin(HTTP), CLI, FTP

## Tags Explanation
<br>
Currently we support three tags are

```
  latest    : pre-installed image
  10.3.1    : pre-installed image
  10.3.1-pc : pre-installed and pre-configured image
```

## Usage Instructions

#### Environment Variables
<br>
Request you to use these environment variables while using pre-configured image.

> `AXIGEN_ADMIN_PASSWORD`       - to update admin password of axigen<br>
> `AXIGEN_ADMIN_PASSWORD_FILE`  - to support swarm secrets<br>
> `AXIGEN_PRECONFIGURED`        - intimate to apply pre-configuration. Options: no | yes. Default: no. Make sure to provide **yes** to apply configuration.<br>


#### Deploy Containers
<br>
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
      - AXIGEN_PRECONFIGURED="yes"
      - AXIGEN_ADMIN_PASSWORD="unknownadmin"
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
    configs:
      - source: axigen-license
        target: /var/opt/axigen/axigen_lk.bin
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure

volumes:
  axigen_data:

secrets:
  adminpass:
    file: ./axigen_admin_secure
```


## Building Image
<br>
#### Building pre-installed image

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1 .
```

#### Building pre-installed image

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1-pc --build-arg AXIGEN_VERSION=10.3.1 --build-arg AXIGEN_PRECONFIGURE="yes" --build-arg AXIGEN_PRECONFIGURE_SMTPFILTERS="yes" .
```

#### Building on your base image
<br>
Some people/companies want to use their base image so they can have more control on container what they are running on thier premises. For them

```bash
git clone https://github.com/apandiyan/axigen.git
cd axigen
sudo docker image build -t apandiyan/axigen:10.3.1 --build-arg BASE_IMAGE=centos .
```

This command will use the image centos:latest reside in your images or else will pull from [Docker Hub](https://hub.docker.com).

<hr />
## Feedback

All bugs, feature requests, pull requests, feedback, etc., are welcome. [Create an issue](https://github.com/apandiyan/axigen/issues).
