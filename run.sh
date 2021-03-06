#!/bin/bash
if [ "$1" ] && [ "$2" ]
then
  WERCKER_GRAILS_VERSION=$1
  WERCKER_GRAILS_OPTIONS=$2
fi
if [ "$3" ]
then
WERCKER_GRAILS_COMMIT=$3
fi
if [ "$4" ]
then
  WERCKER_GRAILS_DEPOGIT=$4
else
  WERCKER_GRAILS_DEPOGIT="https://github.com/grails/grails-core.git"
fi
if [ "$WERCKER_GRAILS_VERSION" ]
then
    case "$WERCKER_GRAILS_VERSION" in
        "2.4.4" )
            GRAILS_HOME=/lib/grails-$WERCKER_GRAILS_VERSION;;
        "3.0.0.M1" )
            GRAILS_HOME=/lib/grails-$WERCKER_GRAILS_VERSION;;
        "BUILD-SNAPSHOT" )
            if [ "$WERCKER_GRAILS_COMMIT" ]
            then
                mkdir .target-grails-snapshot
                cd .target-grails-snapshot
                echo "--- GIT CLONE & INSTALL GRAILS $(pwd) form $(WERCKER_GRAILS_DEPOGIT) ---"
                git clone $WERCKER_GRAILS_DEPOGIT ./
                echo "--- CHANGE COMMIT $WERCKER_GRAILS_COMMIT ---"
                if git cat-file -e $WERCKER_GRAILS_COMMIT 2> /dev/null
                then
                  echo "Commit $WERCKER_GRAILS_COMMIT exists !"
                  git checkout $WERCKER_GRAILS_COMMIT
                  ./gradlew install -q
                  GRAILS_HOME=$(pwd)
                  echo "GRAILS_HOME=$GRAILS_HOME"
                  cd ..
                else
                  echo "Missing commit $WERCKER_GRAILS_COMMIT"
                  exit 1
                fi
            else
                echo "commit:<not set>"
            fi;;
        * )
            echo "unknown version:$WERCKER_GRAILS_VERSION"
    esac
    case "$(uname -s)" in
        "Darwin" )
            ;;# export JAVA_HOME=$(dirname $(readlink $(which javac)));;
        "Linux" )
            export JAVA_HOME=/usr/lib/jvm/java-8-oracle;;
        * )
         echo "unknown system: $(uname -s)"
         exit 0
    esac
    export PATH="$PATH:$JAVA_HOME/bin"
    export PATH="$PATH:$GRAILS_HOME/bin"
    echo "--- RUN WITH GRAILS $WERCKER_GRAILS_VERSION ----"
    $GRAILS_HOME/bin/grails $WERCKER_GRAILS_OPTIONS
else
    echo "version:<not set>"
fi