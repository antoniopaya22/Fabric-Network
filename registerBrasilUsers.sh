#!/bin/bash

# ====== HF3D-BACKEND =========
#
# Autor: Antonio Paya Gonzalez
#
# =============================

# ============ VARIABLES =============
set -e
DIR=$PWD

function reemplazarClaves(){
    echo 
    echo "---------- Remplazando clave privada --------------"
    echo

    OPTS="-i"

    if [ -f ./users/ConnectionProfileBrasil.yml ]; then
        rm ./users/ConnectionProfileBrasil.yml
    fi

    cp ./users/ConnectionProfileBrasilTemplate.yml ./users/ConnectionProfileBrasil.yml

    cd crypto-config/peerOrganizations/brasil.antonio.com/users/Admin@brasil.antonio.com/msp/keystore/
    PRIV_KEY=$(ls *_sk)
    cd $DIR
    sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" ./users/ConnectionProfileBrasil.yml

    echo 
    echo "-----> Done"
    echo
}

function registrarAdmins(){
    echo 
    echo "---------- Registrando administradores --------------"
    echo

    if [ -d ./hfc-key-store ]; then
            rm -rf ./hfc-key-store
    fi

    cd $DIR

    node ./users/registerBrasilAdmin.js
}

function registrarUsers(){
    echo 
    echo "---------- Registrando usuarios --------------"
    echo

    cd $DIR
    
    node ./users/registerBrasilUser.js
}

reemplazarClaves
registrarAdmins
registrarUsers



