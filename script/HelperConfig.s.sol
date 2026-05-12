// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of the contract address across different chains by using a config file

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // โครงสร้างข้อมูลที่เราต้องการสำหรับแต่ละ Chain
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    // ตัวแปร Magic Numbers สำหรับ Mock
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // ถ้าเคยสร้างไปแล้ว ให้ส่งค่าเดิมกลับไป (ป้องกันการสร้าง Mock ซ้ำซ้อน)
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy Mocks
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        // 2. Return Address
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
