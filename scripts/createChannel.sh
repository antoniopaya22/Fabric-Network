ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/antonio.com/orderers/orderer.antonio.com/msp/tlscacerts/tlsca.antonio.com-cert.pem
CORE_PEER_LOCALMSPID="asturiasMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/peers/peer0.asturias.antonio.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/users/Admin@asturias.antonio.com/msp
CORE_PEER_ADDRESS=peer0.asturias.antonio.com:7051
CHANNEL_NAME=datoschannel
ORDERER_SYSCHAN_ID=syschain
peer channel create -o orderer.antonio.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/datoschannel.tx --cafile $ORDERER_CA >&log.txt
cat log.txt