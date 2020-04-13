ARG BASE_IMAGE=centos:8.1.1911

# use base image.
FROM $BASE_IMAGE

# information about dockerfile
LABEL maintainer="Arun Pandiyan P <pandiyan.satheesh@gmail.com>" description="axigen image based on centos"

# pass AXIGEN_VERSION to install
ARG AXIGEN_VERSION=10.3.1
ARG AXIGEN_PRECONFIGURE="no"
ARG AXIGEN_PRECONFIGURE_SMTPFILTERS="no"

# respective services are running in these ports
#EXPOSE 25 465 143 993 110 995 8443 80 9000 9443 7000
EXPOSE 465 993 995 443 9000 7000 21

# add healthcheck for containers
HEALTHCHECK --interval=1m --timeout=3s --start-period=3m CMD curl -sfk -o /dev/null http://localhost:9000 || exit 1

# install axigen, move conf & static files then create volume on /var/opt/axigen
RUN set -x \
  && dnf clean all && dnf -y install git \
  && git clone https://github.com/apandiyan/axigen.git \
  && cd axigen/app && dnf -y remove git \
  && RPM_NAME=axigen-$AXIGEN_VERSION.x86_64.rpm.run \
  && curl -O -# https://www.axigen.com/usr/files/axigen-$AXIGEN_VERSION/$RPM_NAME \
  && sed -i "s/^sfx_license$//g" $RPM_NAME \
  && chmod +x $RPM_NAME bin/*.sh \
  && export AXIGEN_INSTALL_DONT_START_SERVICE="yes" \
  && echo "1" | ./$RPM_NAME --nomd5 --quiet \
  && echo "Docker" > /var/opt/axigen/os.info \
  && if [ "$AXIGEN_PRECONFIGURE" == "yes" ]; then \
      dnf -y install expect initscripts && \
      service axigen start && service axigen stop && \
      yes | cp -fp /var/opt/axigen/run/axigen.cfg /var/opt/axigen/run/axigen.cfg_rpm && \
      yes | cp -f pre_config/pre-configured-axigen.cfg /var/opt/axigen/run/axigen.cfg && \
      chown axigen.axigen /var/opt/axigen/run/axigen.cfg && \
      chmod 640 /var/opt/axigen/run/axigen.cfg && \
      unset AXIGEN_PRECONFIGURE ; fi \
  && if [ "$AXIGEN_PRECONFIGURE_SMTPFILTERS" == "yes" ]; then \
      yes | cp -fp /var/opt/axigen/filters/smtpFilters.script /var/opt/axigen/filters/smtpFilters.script_rpm && \
      yes | cp -f pre_config/pre-configured-smtpFilters.script /var/opt/axigen/filters/smtpFilters.script && \
      chown axigen.axigen /var/opt/axigen/filters/smtpFilters.script && \
      chmod 600 /var/opt/axigen/filters/smtpFilters.script && \
      unset AXIGEN_PRECONFIGURE_SMTPFILTERS ; fi \
  && rm -rf $RPM_NAME pre_config \
  && unset AXIGEN_VERSION \
  && unset RPM_NAME \
  && sh bin/update-patches.sh \
  && mv /var/opt/axigen /var/opt/axigen_rpm \
  && mkdir /var/opt/axigen \
  && history -c

CMD /axigen/app/bin/run_axigen.sh
