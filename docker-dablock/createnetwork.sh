# 1. clean out all existing crypto and ledger material
#./clean.sh

toilet 'Starting'
toilet 'DABlock...'

# 2. Generate new crypto material
#./generate-docker-crypto.sh

rm .env
echo "COMPOSE_PROJECT_NAME=dablock" >>.env
echo "IMAGE_TAG=latest" >>.env
echo "CA_DESIGNER_PRIVATE_KEY="$(cd crypto-config/peerOrganizations/designer.dablock.com/ca && ls *_sk) >>.env
echo "CA_CUSTOMER_PRIVATE_KEY="$(cd crypto-config/peerOrganizations/customer.dablock.com/ca && ls *_sk) >>.env
echo "SYS_CHANNEL=dablock_sys_channel" >>.env

export CONSENSUS_TYPE=solo
while getopts "o:anv" opt; do
    case "$opt" in
    o)
        CONSENSUS_TYPE=$OPTARG
        ;;
    esac
done

echo "CONSENSUS_TYPE=$CONSENSUS_TYPE"

# 3. Bring up network using cli with correct consensus type
if [ "$CONSENSUS_TYPE" == "solo" ]; then
    echo "Bringing up DABlock using solo orderer"
    docker-compose -f docker-compose-cli.yaml up -d
elif [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
    echo "Bringing up DABlock orderer cluster using raft consensus with peers running on CouchDB"
    docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml -f docker-compose-couch.yaml up -d

else
    set +x
    echo "unrecognized CONSESUS_TYPE='$CONSENSUS_TYPE'. exiting"
    exit 1
fi

echo "sleeping while the Fabric DABlock network comes up..."
sleep 15

# shell commands designer peer 0 create and join

echo "================================================================================="
echo "                 create channel dablock-channel"
echo "================================================================================="

docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer channel create -o orderer.dablock.com:7050 -c dablock-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Designer Peer 0 join channel dablock-channel"
echo "================================================================================="

docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Designer Peer 1 join channel dablock-channel"
echo "================================================================================="
# designer peer 1 join channel
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer1.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer1.designer.dablock.com:8051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Customer Peer 0 join channel dablock-channel"
echo "================================================================================="

# customer peer 0 join channel
docker exec -e "CORE_PEER_LOCALMSPID=customerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/peers/peer0.customer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/users/Admin@customer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.customer.dablock.com:9051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Customer Peer 1 join channel dablock-channel"
echo "================================================================================="

# customer  peer 1 join channel
docker exec -e "CORE_PEER_LOCALMSPID=customerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/peers/peer1.customer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/users/Admin@customer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer1.customer.dablock.com:10051" \
    cli peer channel join -b dablock-channel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Designer Peer 0 peer channel update (anchor) dablock-channel"
echo "================================================================================="

# designer peer 0 anchor update for channel
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer channel update -o orderer.dablock.com:7050 -c dablock-channel \
    -f ./channel-artifacts/designerMSPanchors.tx --tls \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Customer Peer 0 peer channel update (anchor) dablock-channel"
echo "================================================================================="

# customer peer 0 anchor update for channel
docker exec -e "CORE_PEER_LOCALMSPID=customerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/peers/peer1.customer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.dablock.com/users/Admin@customer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer1.customer.dablock.com:10051" \
    cli peer channel update -o orderer.dablock.com:7050 -c dablock-channel \
    -f ./channel-artifacts/customerMSPanchors.tx --tls \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem

echo "================================================================================="
echo "                 Designer Peer 0 install chaincode"
echo "================================================================================="
# install chaincode peer o designer
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer chaincode install -n dablock -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/dablock/node/

# instantiate chaincode
echo "================================================================================="
echo "                 Designer Peer 0 instantiate chaincode"
echo "================================================================================="
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer chaincode instantiate -o orderer.dablock.com:7050 --tls true \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
    -C dablock-channel -n dablock -l node -v 1.0 \
    -c '{"Args":["init","a","100","b","200"]}'

# query chaincode
sleep 5
echo "================================================================================="
echo "                 Designer Peer 0 query chaincode"
echo "================================================================================="
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer chaincode query -C dablock-channel -n dablock -c '{"Args":["query","a"]}'

echo "================================================================================="
echo "                 Designer Peer 0 invoke chaincode"
echo "================================================================================="
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    cli peer chaincode invoke -o orderer.dablock.com:7050 --tls true \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dablock.com/orderers/orderer.dablock.com/msp/tlscacerts/tlsca.dablock.com-cert.pem \
    -C dablock-channel -n dablock --peerAddresses peer0.designer.dablock.com:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt \
    -c '{"Args":["invoke","a","b","10"]}'

sleep 5
echo "================================================================================="
echo "                 Designer Peer 0 query chaincode for new result"
echo "================================================================================="
docker exec -e "CORE_PEER_LOCALMSPID=designerMSP" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/peers/peer0.designer.dablock.com/tls/ca.crt" \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/designer.dablock.com/users/Admin@designer.dablock.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.designer.dablock.com:7051" \
    cli peer chaincode query -C dablock-channel -n dablock -c '{"Args":["query","a"]}'

toilet 'Network'
toilet 'DABlock UP!'
