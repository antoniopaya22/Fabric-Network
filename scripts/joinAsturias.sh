CORE_PEER_LOCALMSPID="asturiasMSP"
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/antonio.com/orderers/orderer.antonio.com/msp/tlscacerts/tlsca.antonio.com-cert.pem
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/peers/peer0.asturias.antonio.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.antonio.com/users/Admin@asturias.antonio.com/msp
CORE_PEER_ADDRESS=peer0.asturias.antonio.com:7051
CHANNEL_NAME=datoschannel

peer channel join -b $CHANNEL_NAME.block  >&log.txt
cat log.txt

echo install

peer chaincode install -n mycontract -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode>&log.txt
cat log.txt
