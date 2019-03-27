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

    if [ -f ./users/ConnectionProfileAsturias.yml ]; then
        rm ./users/ConnectionProfileAsturias.yml
    fi


    cp ./users/ConnectionProfileAsturiasTemplate.yml ./users/ConnectionProfileAsturias.yml

    cd crypto-config/peerOrganizations/asturias.antonio.com/users/Admin@asturias.antonio.com/msp/keystore/
    PRIV_KEY=$(ls *_sk)
    cd $DIR
    sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" ./users/ConnectionProfileAsturias.yml

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

    node ./users/registerAsturiasAdmin.js
}

function registrarUsers(){
    echo 
    echo "---------- Registrando usuarios --------------"
    echo

    cd $DIR

    node ./users/registerAsturiasUser.js
}

reemplazarClaves
registrarAdmins
registrarUsers



