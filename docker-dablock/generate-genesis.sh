# Generates the orderer | generate genesis block for ordererchannel
# export ORDERER_GENERAL_LOGLEVEL=debug
export FABRIC_LOGGING_SPEC=INFO
export FABRIC_CFG_PATH=$PWD

export CONSENSUS_TYPE=solo
while getopts "o:anv" opt; do
    case "$opt" in
    o)
        CONSENSUS_TYPE=$OPTARG
        ;;
    esac
done

echo "CONSENSUS_TYPE=$CONSENSUS_TYPE"
echo '================ Writing Genesis Block ================'

if [ "$CONSENSUS_TYPE" == "solo" ]; then
    configtxgen -profile TwoOrgsDABlockGenesis -channelID dablock-system-channel -outputBlock ./channel-artifacts/genesis.block
elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
    configtxgen -profile SampleDevModeKafka -channelID dablock-system-channel -outputBlock ./channel-artifacts/genesis.block
elif [ "$CONSENSUS_TYPE" == "etcdraft" ]; then
    configtxgen -profile DABlockMultiNodeEtcdRaft -channelID dablock-system-channel -outputBlock ./channel-artifacts/genesis.block
else
    set +x
    echo "unrecognized CONSESUS_TYPE='$CONSENSUS_TYPE'. exiting"
    exit 1
fi

echo '================ Generate Channel Tranaction ================'
configtxgen -profile TwoOrgsDABlockChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID dablock-channel

# Anchor Peers
echo '================ Generate the anchor Peer updates ==============================='

echo "================================================================================="
echo "                 Generate Anchor Peer Update for designerMSP"
echo "================================================================================="
configtxgen -profile TwoOrgsDABlockChannel -outputAnchorPeersUpdate ./channel-artifacts/designerMSPanchors.tx -channelID dablock-channel -asOrg designerMSP

echo "================================================================================="
echo "                 Generate Anchor Peer Update for customerMSP"
echo "================================================================================="
configtxgen -profile TwoOrgsDABlockChannel -outputAnchorPeersUpdate ./channel-artifacts/customerMSPanchors.tx -channelID dablock-channel -asOrg customerMSP

echo "================================================================================="
