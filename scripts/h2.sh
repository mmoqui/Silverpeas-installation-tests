#!/usr/bin/env bash

workdir="$1"
libdir="$workdir"/lib
H2_JAR="$libdir/h2.jar"

print_help() {
    echo "$0 start|stop"
    echo "requires SILVERPEAS_HOME and JBOSS_HOME to be set"
}

case "$2" in
    start)
        echo "Start H2 database..."
        exec java -classpath "$H2_JAR" org.h2.tools.Server -tcp -baseDir "$workdir/h2" -ifNotExists -tcpPassword sa &
        ;;
    stop)
        echo "Stop H2 database..."
        exec java -classpath "$H2_JAR" org.h2.tools.Server -tcpShutdown tcp://localhost:9092 -tcpPassword sa
        ;;
    *)
        print_help
        exit 1
esac
