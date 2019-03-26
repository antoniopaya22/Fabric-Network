CORE_PEER_LOCALMSPID="brasilMSP"
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/antonio.com/orderers/orderer.antonio.com/msp/tlscacerts/tlsca.antonio.com-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brasil.antonio.com/users/Admin@brasil.antonio.com/msp
CORE_PEER_ADDRESS=peer0.brasil.antonio.com:7051
CHANNEL_NAME=datoschannel

peer channel join -b $CHANNEL_NAME.block >&log.txt
cat log.txt

echo install

peer chaincode install -n mycontract -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode>&log.txt
cat log.txt
