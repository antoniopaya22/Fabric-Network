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

    if [ -f ./users/ConnectionProfileChicago.yml ]; then
        rm ./users/ConnectionProfileChicago.yml
    fi

    cp ./users/ConnectionProfileChicagoTemplate.yml ./users/ConnectionProfileChicago.yml

    cd crypto-config/peerOrganizations/chicago.antonio.com/users/Admin@chicago.antonio.com/msp/keystore/
    PRIV_KEY=$(ls *_sk)
    cd $DIR
    sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" ./users/ConnectionProfileChicago.yml

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

    node ./users/registerChicagoAdmin.js
}

function registrarUsers(){
    echo 
    echo "---------- Registrando usuarios --------------"
    echo

    cd $DIR
    
    node ./users/registerChicagoUser.js
}

reemplazarClaves
registrarAdmins
registrarUsers



