killall -9 fabric-ca-server
killall -9 orderer
sudo killall -9 peer

./clean.sh
echo "Please make sure couchdb docker process is running..."
# Generate crypto material...we need this to get the TLS certs 
mkdir crypto-config
mkdir channel-artifacts

cryptogen generate --output=crypto-config --config=./crypto-config.yaml
                            
echo "================================================================================="
echo "generate genesis block"
echo "================================================================================="
./generate-genesis.sh 




