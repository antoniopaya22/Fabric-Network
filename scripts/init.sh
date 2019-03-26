ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/antonio.com/orderers/orderer.antonio.com/msp/tlscacerts/tlsca.antonio.com-cert.pem
CORE_PEER_LOCALMSPID="asturiasMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/peers/peer0.asturias.antonio.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/users/Admin@asturias.antonio.com/msp
CORE_PEER_ADDRESS=peer0.asturias.antonio.com:7051
CHANNEL_NAME=datoschannel

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
   		exit 1
	fi
}
queryChaincode () {
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option

	peer chaincode invoke -o orderer.antonio.com:7050 --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycontract -c '{"function":"initLedger","Args":[""]}' >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Fallo al iniciar el Ledger en el canal '$CHANNEL_NAME'"
	echo "===================== Ledger iniciado correctamente en el canal '$CHANNEL_NAME' ===================== "
	echo
	
}

queryChaincode