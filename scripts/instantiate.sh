ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/arcelormittal.com/orderers/orderer.arcelormittal.com/msp/tlscacerts/tlsca.arcelormittal.com-cert.pem
CORE_PEER_LOCALMSPID="asturiasMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.arcelormittal.com/peers/peer0.asturias.arcelormittal.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.arcelormittal.com/users/Admin@asturias.arcelormittal.com/msp
CORE_PEER_ADDRESS=peer0.asturias.arcelormittal.com:7051
CHANNEL_NAME=datoschannel


verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
   		exit 1
	fi
}
instantiateChaincode () {
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option

		peer chaincode instantiate -o orderer.arcelormittal.com:7050 --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycontract -v 1.0 -c '{"Args":[""]}' >&log.txt

	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on PEER on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode Instantiation on PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

instantiateChaincode
