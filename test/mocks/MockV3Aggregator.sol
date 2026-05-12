// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MockV3Aggregator is AggregatorV3Interface {
    uint8 public decimals;
    int256 public latestAnswer;
    uint256 public version = 4;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        latestAnswer = _initialAnswer;
    }

    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, latestAnswer, 0, 0, 0);
    }

    function getRoundData(
        uint80
    ) external view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, latestAnswer, 0, 0, 0);
    }

    function description() external pure returns (string memory) {
        return "MockV3Aggregator";
    }
}
