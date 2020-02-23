# Generates the orderer | generate genesis block for ordererchannel
# export ORDERER_GENERAL_LOGLEVEL=debug
export FABRIC_LOGGING_SPEC=INFO
export FABRIC_CFG_PATH=$PWD

# Create the Genesis Block
echo    '================ Writing Genesis Block ================'
configtxgen -profile designerOrdererGenesis -outputBlock ./channel-artifacts/dablock-genesis.block -channelID ordererchannel

# Anchor Peers
echo '================ Generate the anchor Peer updates ==============================='

echo "================================================================================="
echo "                 Generate Anchor Peer Update for designerMSP"
echo "================================================================================="
configtxgen -outputAnchorPeersUpdate ./channel-artifacts/designerAnchors.tx -profile dablockChannel -asOrg designer -channelID dablockchannel


echo "================================================================================="
echo "                 Generate Anchor Peer Update for customerMSP"
echo "================================================================================="
configtxgen -outputAnchorPeersUpdate ./channel-artifacts/customerAnchors.tx -profile dablockChannel -asOrg customer -channelID dablockchannel
echo "================================================================================="
