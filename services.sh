#!/bin/bash
# 
#  Command Line Interface to start all services associated with the Smart Campus UFC
#

set -e

dockerCmd="docker-compose"

if (( $# < 1 )); then
    echo "Illegal number of parameters"
    echo "usage: services [create|start|stop|help]"
    exit 1
fi

loadData () {
        waitForMongo
        addDatabaseIndex
        waitForOrion
        docker run --rm -v $(pwd)/data/import-data.sh:/import-data.sh \
                --network smartufc_main-net -e ORION_PORT="${ORION_PORT}" \
                --entrypoint /bin/ash curlimages/curl import-data.sh
        echo ""
}

stoppingContainers () {
        echo "Stopping running containers"
        ${dockerCmd} -f docker-compose.yml down -v --remove-orphans
}

displayServices () {
        echo ""
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter name=fiware-*
        echo ""
}

addDatabaseIndex () {
        printf "Adding appropriate \033[1mMongoDB\033[0m indexes for \033[1;34mOrion\033[0m  ..."
        docker exec  db-mongo mongo --eval '
        conn = new Mongo();db.createCollection("orion");
        db = conn.getDB("orion");
        db.createCollection("entities");
        db.entities.createIndex({"_id.servicePath": 1, "_id.id": 1, "_id.type": 1}, {unique: true});
        db.entities.createIndex({"_id.type": 1});
        db.entities.createIndex({"_id.id": 1});' > /dev/null

        docker exec  db-mongo mongo --eval '
        conn = new Mongo();db.createCollection("orion-smartufc");
        db = conn.getDB("orion-smartufc");
        db.createCollection("entities");
        db.entities.createIndex({"_id.servicePath": 1, "_id.id": 1, "_id.type": 1}, {unique: true});
        db.entities.createIndex({"_id.type": 1});
        db.entities.createIndex({"_id.id": 1});' > /dev/null
        echo -e " \033[1;32mdone\033[0m"

}

waitForMongo () {
        echo -e "\n Waiting for \033[1mMongoDB\033[0m to be available\n"
        while ! [ `docker inspect --format='{{.State.Health.Status}}' db-mongo` == "healthy" ]
        do
                sleep 1
        done
}

waitForOrion () {
        echo -e "\n Waiting for \033[1;34mOrion\033[0m to be available\n"

        while ! [ `docker inspect --format='{{.State.Health.Status}}' fiware-orion` == "healthy" ]
        do
          echo -e "Context Broker HTTP state: " `curl -s -o /dev/null -w %{http_code} 'http://localhost:1026/version'` " (waiting for 200)"
          sleep 1
        done
}

command="$1"
case "${command}" in
        "help")
        echo "usage: services [create|start|stop]"       
                ;;
        "stop")
                export $(cat .env | grep "#" -v)
                stoppingContainers
                ;;
        "start")
                export $(cat .env | grep "#" -v)
                stoppingContainers
                echo -e "Starting containers: \033[1;34mOrion\033[0m, a \033[1mGrafana\033[0m metrics dashboard and \033[1mMongoDB\033[0m databases"
                echo -e "- \033[1;34mOrion\033[0m is the context broker"
                echo -e "- \033[1mGrafana\033[0m will read from CrateDB"
                echo ""
                ${dockerCmd} -f docker-compose.yml up -d --remove-orphans
                loadData
                displayServices
                ;;
        "create")
                export $(cat .env | grep "#" -v)
                echo "Pulling Docker images"
                docker pull curlimages/curl
                ${dockerCmd} -f docker-compose.yml pull
                ;;
        *)
                echo "Command not Found."
                echo "usage: services [create|start|stop|help]"
                exit 127;
                ;;
esac


