#!/bin/bash

initialize_workdir() {
        echo "Initializing workdir"
        chown axigen:axigen /var/opt/axigen
        cp -a /var/opt/axigen_rpm/* /var/opt/axigen/
        rm /var/opt/axigen/run/axigen.reg
        rm -rf /var/opt/axigen/serverData
}

BINARY_VERSION=`/opt/axigen/bin/axigen -v`
if [ ! -f /var/opt/axigen/run/version ] ; then
        initialize_workdir
        echo $BINARY_VERSION > /var/opt/axigen/run/version

        # preconfigure axigen
        if [ "$AXIGEN_PRECONFIGURED" == "yes" ]
        then
          if [[ -z "$AXIGEN_ADMIN_PASSWORD_FILE" ]] && [[ -z "$AXIGEN_ADMIN_PASSWORD" ]]
          then
            echo "provide envioronment variable AXIGEN_ADMIN_PASSWORD_FILE | AXIGEN_ADMIN_PASSWORD" >&2
            exit
          fi

          [[ ! -z "$AXIGEN_ADMIN_PASSWORD_FILE" ]] && AXIGEN_ADMIN_PASSWORD=$(cat ${AXIGEN_ADMIN_PASSWORD_FILE})

          if [[ -z "$AXIGEN_ADMIN_PASSWORD" ]]
          then
            echo "no password given in swarm secrets file" >&2
            exit
          else
            # set admin password from ENV variable AXIGEN_ADMIN_PASSWORD
            /opt/axigen/bin/axigen -A $AXIGEN_ADMIN_PASSWORD

            # set onboarding flag to yes
            service axigen start && expect /axigen/app/bin/onboarding_config.expect $AXIGEN_ADMIN_PASSWORD && service axigen stop
          fi
        else
          yes | cp -f /var/opt/axigen/run/axigen.cfg_rpm /var/opt/axigen/run/axigen.cfg
          yes | cp -f /var/opt/axigen/filters/smtpFilters.script_rpm /var/opt/axigen/filters/smtpFilters.script
          chown axigen.axigen /var/opt/axigen/run/axigen.cfg /var/opt/axigen/filters/smtpFilters.script
        fi
else
        WORKDIR_VERSION=`cat /var/opt/axigen/run/version`
        if [ "$BINARY_VERSION" != "$WORKDIR_VERSION" ] ; then
                echo "Updating workdir"
                echo $BINARY_VERSION > /var/opt/axigen/run/version
                for varfolder in webmail webadmin templates kas kav ; do
                        cp -af /var/opt/axigen_rpm/$varfolder/ /var/opt/axigen/
                done
                cp -af /var/opt/axigen_rpm/filters/*.afsl /var/opt/axigen/filters/
        fi
fi


_term() {
  echo "Caught SIGTERM signal!"
  kill -TERM "$child" 2>/dev/null
}

_int() {
  echo "Caught SIGINT signal!"
  kill -TERM "$child" 2>/dev/null
}

trap _term SIGTERM
trap _int SIGINT

/opt/axigen/bin/axigen --foreground
