#!/bin/bash

#
# Autor: Antonio Paya Gonzalez
#
# ================================


# ============ VARIABLES =============
set -e

DIR=$PWD
NUM_ARG="$#"
COMMAND="$1"
ORG_DOCKER="$2"
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric


# ============ FUNCIONES =============


# generarCertificados -> Genera los certificados
function generarCertificados(){

    echo
	echo "##########################################################"
	echo "##### Generate certificates using cryptogen tool #########"
	echo "##########################################################"
	if [ -d ./crypto-config ]; then
		rm -rf ./crypto-config
	fi

    cryptogen generate --config=./crypto-config.yaml
    echo
}

# generarChannelArtifacts -> Genera los certificados
function generarChannelArtifacts(){

    if [ ! -d ./channel-artifacts ]; then
		mkdir channel-artifacts
	fi

    echo
	echo "#################################################################"
	echo "### Generating channel configuration transaction 'channel.tx' ###"
	echo "#################################################################"

    configtxgen -profile DatosOrdererGenesis -channelID syschain  -outputBlock ./channel-artifacts/genesis.block
    
    echo
	echo "#################################################################"
	echo "#######    Generating anchor peer update for MSP       ##########"
	echo "#################################################################"
    configtxgen -profile datoschannel -outputCreateChannelTx ./channel-artifacts/datoschannel.tx -channelID "datoschannel"

    echo
	echo "#################################################################"
	echo "#####   Generating anchor peer update for asturiasMSP    ########"
	echo "#################################################################"
	configtxgen -profile datoschannel -outputAnchorPeersUpdate ./channel-artifacts/asturiasMSPanchors.tx -channelID "datoschannel" -asOrg asturiasMSP

	echo
	echo "#################################################################"
	echo "#######   Generating anchor peer update for brasilMSP  ##########"
	echo "#################################################################"
	configtxgen -profile datoschannel -outputAnchorPeersUpdate ./channel-artifacts/brasilMSPanchors.tx -channelID "datoschannel" -asOrg brasilMSP
	echo

    echo
	echo "#################################################################"
	echo "#######  Generating anchor peer update for chicagoMSP  ##########"
	echo "#################################################################"
	configtxgen -profile datoschannel -outputAnchorPeersUpdate ./channel-artifacts/chicagoMSPanchors.tx -channelID "datoschannel" -asOrg chicagoMSP
	echo
}

# downloadDockerImages -> Descarga las imagenes docker
#  con version 1.4.0
function downloadDockerImages(){
    echo
	echo "**********************************************************"
	echo "*******         Descargando imagenes docker       ********"
	echo "**********************************************************"
    local FABRIC_TAG="1.4.0"
    for IMAGES in peer orderer ccenv tools ca; do
        echo "==> FABRIC IMAGE: $IMAGES"
        echo
        docker pull hyperledger/fabric-$IMAGES:$FABRIC_TAG
        docker tag hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
    done
    echo "==> FABRIC IMAGE: couchdb"
    echo
    docker pull hyperledger/fabric-couchdb
}

# remplazarClavePrivada -> Crea el archivo docker-compose.yaml
#    a partir de docker-compose-template.yaml y remplaza las
#    CAX_PRIVATE_KEY por las claves que se encuentran en la carpeta crypto-config
function remplazarClavePrivada () {
    echo 
    echo "---------- Remplazando clave privada --------------"
    echo
    OPTS="-i"
	cp docker-compose-template-asturias.yaml docker-compose-asturias.yaml
    cp docker-compose-template-brasil.yaml docker-compose-brasil.yaml
    cp docker-compose-template-chicago.yaml docker-compose-chicago.yaml
    CURRENT_DIR=$PWD
    
    cd crypto-config/peerOrganizations/asturias.antonio.com/ca/
    PRIV_KEY=$(ls *_sk)
    cd $CURRENT_DIR
    sed $OPTS "s/CA_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-asturias.yaml

    cd crypto-config/peerOrganizations/brasil.antonio.com/ca/
    PRIV_KEY2=$(ls *_sk)
    cd $CURRENT_DIR
    sed $OPTS "s/CA_PRIVATE_KEY/${PRIV_KEY2}/g" docker-compose-brasil.yaml

    cd crypto-config/peerOrganizations/chicago.antonio.com/ca/
    PRIV_KEY3=$(ls *_sk)
    cd $CURRENT_DIR
    sed $OPTS "s/CA_PRIVATE_KEY/${PRIV_KEY3}/g" docker-compose-chicago.yaml

}


# startNetwork -> Inicia la red Fabric
function startNetwork() {
    echo
    echo "================================================="
    echo "---------- Iniciando la red Fabric --------------"
    echo "================================================="
    echo
    cd $DIR
    docker-compose -f docker-compose.yaml up -d
}

function up() {
    docker stack deploy --compose-file docker-compose-$ORG_DOCKER.yaml --with-registry-auth fabric 2>&1
}

# cleanNetwork -> Borra certificados, imagenes docker, etc.
function cleanNetwork() {
    cd $DIR

    if [ -d ./channel-artifacts ]; then
            rm -rf ./channel-artifacts
    fi

    if [ -d ./crypto-config ]; then
            rm -rf ./crypto-config
    fi

    if [ -d ./tools ]; then
            rm -rf ./tools
    fi

    if [ -f ./docker-compose.yaml ]; then
        rm ./docker-compose.yaml
    fi

    if [ -f ./docker-compose.yamlt ]; then
        rm ./docker-compose.yamlt
    fi

    if [ -d ./hfc-key-store ]; then
            rm -rf ./hfc-key-store
    fi

    if [ -f ./users/ConnectionProfileAsturias.yml ]; then
        rm ./users/ConnectionProfileAsturias.yml
    fi

    if [ -f ./users/ConnectionProfileBrasil.yml ]; then
        rm ./users/ConnectionProfileBrasil.yml
    fi

    if [ -f ./users/ConnectionProfileChicago.yml ]; then
        rm ./users/ConnectionProfileChicago.yml
    fi

    rm -f docker-compose-am.yaml
    rm -f docker-compose-watcher.yaml
    docker swarm leave -f
    docker volume rm -f $(docker volume ls -q)
    docker rmi -f $(docker images -q)
    docker stack rm fabric
    
}

# networkStatus -> Devuelve el estado de la red
function networkStatus() {
    docker ps --format "{{.Names}}: {{.Status}}" | grep '[peer0* | orderer* | cli ]'
}

# dockerCli -> Inicia un docker cli
function dockerCli(){
    docker exec -it cli /bin/bash
}

# comprobarArg -> Comprueba si el numero de parametros es correcto (arg==1)
function comprobarArg() {
    if [ $NUM_ARG -ne 1 ]; then
        echo "Modo de ejecucion: "
        echo "      # payascript.sh start | status | clean | cli"
        exit 1;
        exit 1;
    fi
}

function dc(){
    downloadDockerImages
}


# ============ RUN =============

# Network operations
#comprobarArg
case $COMMAND in
    "start")
        generarCertificados
        generarChannelArtifacts
        remplazarClavePrivada
        downloadDockerImages
        #startNetwork
        ;;
    "status")
        networkStatus
        ;;
    "clean")
        cleanNetwork
        ;;
    "cli")
        dockerCli
        ;;
    "up")
        up
        ;;
    "dc")
        dc
        ;;
    *)
        echo "Modo de ejecucion: "
        echo "      # payascript.sh start | status | clean | cli | up [orderer | org]"
        exit 1;
esac
