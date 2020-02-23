# Generates the orderer | generate the dablockchannel channel transaction

# export ORDERER_GENERAL_LOGLEVEL=debug
export FABRIC_LOGGING_SPEC=INFO
export FABRIC_CFG_PATH=$PWD


echo    '================ Writing dablockchannel ================'

configtxgen -profile dablockChannel -outputCreateChannelTx ./channel-artifacts/dablock-channel.tx -channelID dablockchannel

echo    '======= Done. Launch by executing orderer ======'
