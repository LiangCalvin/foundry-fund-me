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

deploy-anvil:;
	forge script script/DeployFundMe.s.sol:DeployFundMe \
	--rpc-url ${ANVIL_RPC_URL} \
	--account myWallet \
	--sender ${ANVIL_PUBLIC_KEY} \
	--broadcast \
	-vvvv