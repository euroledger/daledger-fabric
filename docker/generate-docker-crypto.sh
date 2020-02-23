killall -9 fabric-ca-server
killall -9 orderer
sudo killall -9 peer

./clean.sh
echo "Please make sure couchdb docker process is running..."
# Generate crypto material...we need this to get the TLS certs 
mkdir crypto-config
mkdir channel-artifacts

cryptogen generate --output=crypto-config --config=./crypto-config.yaml
                            

echo "DABLOCK_CA1_PRIVATE_KEY="$DABLOCK_CA1_PRIVATE_KEY
echo "DABLOCK_CA2_PRIVATE_KEY="$DABLOCK_CA2_PRIVATE_KEY

echo "================================================================================="
echo "generate genesis block"
echo "================================================================================="
./generate-genesis.sh 


echo "================================================================================="
echo "generate channel tx config"
echo "================================================================================="
./generate-dablock-channel-tx.sh


