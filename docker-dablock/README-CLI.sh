# 1. clean out all existing crypto and ledger material
./clean.sh

# 2. Generate new crypto material
./generate-docker-crypto.sh [ -o etcdraft]

# 3. test out network comes up using start/stop scripts
./startdablock.sh

# 4. Bring up network using cli (single orderer)
docker-compose -f docker-compose-cli.yaml up -d

# 4a Bring up network using cli (multiple orderers, RAFT, CouchDB)
docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml -f docker-compose-couch.yaml up -d

# 5 
docker exec -it cli bash

docker exec -it chaincode bash

# 5. take down network and clean up
docker-compose -f docker-compose-cli.yaml down --volumes --remove-orphans

# take down all containers (Raft multiple orderers)
docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml down --volumes --remove-orphans


# inside docker cli
export CHANNEL_NAME=dablock-channel

# designer peer 0 create and join channel (inside docker cli)
peer channel create -o orderer.dablock.com:7050 -c dablock-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem
peer channel join -b dablock-channel.block

# shell commands designer peer 0 create and join channel
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer channel create -o orderer.dablock.com:7050 -c dablock-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem


# designer peer 1 join channel
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer1.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer1.designer.dablock.com:8051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

# customer peer 0 join channel
docker exec -e "CORE_PEER_LOCALMSPID=customerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/peers/peer0.customer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/users/Admin@customer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.customer.dablock.com:9051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

# customer  peer 1 join channel
docker exec -e "CORE_PEER_LOCALMSPID=customerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/peers/peer1.customer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/users/Admin@customer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer1.customer.dablock.com:10051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem


# update for anchor peer, peer 0 designer
peer channel update -o orderer.dablock.com:7050 -c dablock-channel \
-f ./channel-artifacts/designerMSPanchors.tx --tls \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem
# update for anchor peer, peer 0 customer
peer channel update -o orderer.dablock.com:7050 -c dablock-channel \
-f ./channel-artifacts/customerMSPanchors.tx --tls \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

# install the example chaincode
# peer chaincode install --lang node --name daledger4 --version v1.0 \
# --path /opt/gopath/src/github.com/chaincode

# peer chaincode instantiate --orderer orderer.dablock.com:7050 \
# --channelID dablock-channel --lang node --name daledger4 --version v1.0 -c '{"Args":["init"]}'

# peer chaincode install --name daledger --version v1.0 \
# --path github.com/chaincode/chaincode_example02/go

# peer chaincode instantiate --orderer orderer.dablock.com:7050 --tls true --name daledger --version v1.0 --channelID dablock-channel -c '{"Args":["init","a","100","b","200"]}'

# Install and instantiate Go Chaincode
peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02/go/
# peer chaincode instantiate -o orderer.dablock.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem -C dablock-channel -n mycc -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P 'AND ('\''designerMSP.peer'\'','\''customerMSP.peer'\'')'

peer chaincode instantiate -o orderer.dablock.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem -C dablock-channel -n mycc -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' 


peer chaincode invoke -o orderer.dablock.com:7050 --tls true \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
-C dablock-channel -n dablock --peerAddresses peer0.designer.dablock.com:7051 \
--tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt \
-c '{"Args":["invoke","a","b","10"]}'

# Install and instantiate Node chaincode
# peer chaincode install -n dablock -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/dablock

# peer chaincode instantiate -o orderer.dablock.com:7050 \
# --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
# -C dablock-channel -n dablock -l node -v 1.0 -c '{"Args":["init","a","100","b","200"]}'

# chaincode-example02
peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/
peer chaincode instantiate -o orderer.dablock.com:7050 --tls true \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
-C dablock-channel -n mycc -l node -v 1.0 \
-c '{"Args":["init","a","100","b","200"]}'

# dablock
peer chaincode install -n dablock -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/dablock/node/
peer chaincode instantiate -o orderer.dablock.com:7050 --tls true \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
-C dablock-channel -n dablock -l node -v 1.0 \
-c '{"Args":["init","a","100","b","200"]}'

peer chaincode query -C dablock-channel -n dablock -c '{"Args":["query","a"]}'
