killall -9 fabric-ca-server
killall -9 orderer
sudo killall -9 peer


cd ca-client
./clean.sh

echo "Please make sure couchdb docker process is running..."

cd ../ca-server
./server.sh start 2> ../logs/ca.log &

sleep 3s

# enroll admin identity
# reqires fabric-ca-client-config.yaml in ca-client
./server.sh enroll

cd ../ca-client
./register-enroll-admins-2org.sh

. ./setup-org-msp.sh designer
. ./setup-org-msp.sh orderer
#. ./setup-org-msp.sh customer

# add some users to the designer org...mrichardson and the rest
echo "================================================================================="
echo "add user mrichardson"
echo "================================================================================="
. ./setclient.sh designer admin
ATTRIBUTES='"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.company.role=des1:ecert","department=des1:ecert"'
fabric-ca-client register --id.type user --id.name mrichardson --id.secret pw --id.affiliation designer.des2 --id.attrs $ATTRIBUTES

# enroll the user richardson...sets the directory to store the msp credentials
. ./setclient.sh designer mrichardson
fabric-ca-client enroll -u http://mrichardson:pw@localhost:7054

./add-admincerts.sh designer mrichardson

# check identity created successfully
. ./setclient.sh designer admin

fabric-ca-client identity list
cd ..

echo "================================================================================="
echo "generate genesis block"
echo "================================================================================="
./generate-genesis.sh 

# ./register-enroll-orderer.shnote this command creates an orderer folder under ca-client/client/orderer
./register-enroll-orderer.sh

# generate the egov channel tx config file
./generate-dablock-channel-tx.sh

#######################################################################################
# ALL STUFF FROM HERE TO GO IN DOCKER CONFIG
#######################################################################################

# sign the channel using the default org for the orderer (egov)
cd peer0designer
export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/admin/msp
peer channel signconfigtx -f ../channel-artifacts/dablock-channel.tx

# start orderer...requires orderer.yaml
cd ..
export FABRIC_CFG_PATH=$PWD
orderer 2> logs/orderer.log &

echo "orderer starting..."
sleep 3s

cd peer0designer
export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/admin/msp
peer channel create -o localhost:7050 -c dablockchannel -f ../channel-artifacts/dablock-channel.tx

../set-identity.sh designer admin
./register-enroll-peer.sh designer peer0

# start peer0 as ANCHOR
export CORE_PEER_FILESYSTEMPATH="/home/mike/ledgers/multi-org-ca/designer/peer0/ledger" 
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/peer0/msp
sudo -E peer node start --peer-chaincodedev 2> ../logs/peer0designer.log &

export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/admin/msp
# echo "TRYING peer channel list..."
# peer channel list

# echo "TRYING peer channel list AGAIN..."
# peer channel list

sleep 2s

echo "================================================================================="
echo "fetch and join dablockchannel"
echo "================================================================================="

# fetch and join dablockchannel 
peer channel fetch 0 ./dablockchannel.block -o localhost:7050 -c dablockchannel
peer channel join -o localhost:7050 -b ./dablockchannel.block


echo "================================================================================="
echo "peer channel update - dablock"
echo "================================================================================="
peer channel update -o localhost:7050 -c dablockchannel -f ../channel-artifacts/designerAnchors.tx

sleep 2s
peer channel list


# register peer 1 for designer org
cd ../peer1designer
export FABRIC_CFG_PATH=$PWD
. ./set-identity.sh designer admin
./register-enroll-peer.sh designer peer1

export CORE_PEER_FILESYSTEMPATH="/home/mike/ledgers/multi-org-ca/designer/peer1/ledger" 
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/peer1/msp
sudo -E peer node start --peer-chaincodedev 2> ../logs/peer1designer.log &

# list channels for peer1 (should be none)
export FABRIC_CFG_PATH=$PWD
export CORE_PEER_MSPCONFIGPATH=../ca-client/client/designer/admin/msp

# peer channel list

# fetch the 0th block file (dablockchannel.block is the output of this command)
peer channel fetch 0 ./dablockchannel.block -o localhost:7050 -c dablockchannel
peer channel join -o localhost:7050 -b ./dablockchannel.block

while [ $? -ne 0 ]; do
    sleep 1s
    echo "Retry channel join..."
    peer channel join -o localhost:7050 -b ./dablockchannel.block
done

echo "Channels for designer ORG (peer1)"
peer channel list














