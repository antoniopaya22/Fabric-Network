ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/arcelormittal.com/orderers/orderer.arcelormittal.com/msp/tlscacerts/tlsca.arcelormittal.com-cert.pem
CORE_PEER_LOCALMSPID="asturiasMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.arcelormittal.com/peers/peer0.asturias.arcelormittal.com/tls/ca.crt
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/asturias.arcelormittal.com/users/Admin@asturias.arcelormittal.com/msp
CORE_PEER_ADDRESS=peer0.asturias.arcelormittal.com:7051
CHANNEL_NAME=datoschannel
ORDERER_SYSCHAN_ID=syschain
peer channel create -o orderer.arcelormittal.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/datoschannel.tx --cafile $ORDERER_CA >&log.txt
cat log.txt