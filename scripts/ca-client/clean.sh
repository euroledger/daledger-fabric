rm -rf client/caserver/admin
rm -rf client/designer/admin
rm -rf client/designer/msp
rm -rf client/designer/peer*
rm -rf client/designer/mrichardson
rm -rf client/designer/john
rm -rf client/designer/anil
rm -rf client/designer/mary
rm -rf client/customer/admin
rm -rf client/customer/peer*
rm -rf client/orderer/admin
rm -rf client/orderer/msp
rm -rf client/orderer/orderer/msp
rm -rf crypto-config

rm -rf ../ca-server/msp
rm -rf ../ca-server/*.pem
rm -rf ../ca-server/*.db
rm -rf ../ca-server/Issuer*

sudo -E rm -rf $HOME/ledgers/
rm ../channel-artifacts/*.block 2> /dev/null
rm ../channel-artifacts/*.tx 2> /dev/null

echo "all stuff deleted"


