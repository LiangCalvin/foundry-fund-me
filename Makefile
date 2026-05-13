-include .env

build:; forge build

deploy-sepolia:;
	forge script script/DeployFundMe.s.sol:DeployFundMe \
	--rpc-url ${SEPOLIA_RPC_URL} \
	--account myTestAccount \
	--sender ${PUBLIC_KEY} \
	--broadcast \
	--verify \
	--etherscan-api-key ${ETHERSCAN_API_KEY} \
	-vvvv