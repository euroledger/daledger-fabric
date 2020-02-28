echo "================================================================================="
echo "Starting DABlock..."
echo "================================================================================="

rm .env
echo "COMPOSE_PROJECT_NAME=dablock" >> .env
echo "IMAGE_TAG=latest" >> .env
echo "CA_DESIGNER_PRIVATE_KEY="$(cd crypto-config/peerOrganizations/designer.dablock.com/ca && ls *_sk) >> .env
echo "CA_CUSTOMER_PRIVATE_KEY="$(cd crypto-config/peerOrganizations/customer.dablock.com/ca && ls *_sk) >> .env
echo "SYS_CHANNEL=dablock_sys_channel" >> .env

# docker-compose -f docker-compose-e2e.yaml up -d 2>&1
docker-compose -f docker-compose-e2e.yaml up 
