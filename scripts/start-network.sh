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
. ./setup-org-msp.sh customer

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

