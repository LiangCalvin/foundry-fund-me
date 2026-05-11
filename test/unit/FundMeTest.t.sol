// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // สร้าง User จำลองสำหรับเทส
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        fundMe = new FundMe();
        vm.deal(USER, STARTING_BALANCE); // เติมเงินให้ User จำลอง
    }
    // 1. ทดสอบว่าเจ้าของ Contract คือคนที่สั่ง deploy (ก็คือตัว FundMeTest เอง)
    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));
    }

    // 2. ทดสอบว่าค่า Minimum USD ตั้งไว้ถูกต้อง (5 * 10^18)
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // function testPriceFeedVersionIsAccurate() public {
    //     // ต้องรันด้วย --fork-url เท่านั้นถึงจะผ่าน
    //     uint256 version = fundMe.getVersion();
    //     assertEq(version, 4);
    // }

    // function testFundUpdatesFundedDataStructure() public {
    //     vm.prank(USER);
    //     // การเรียก fund() จะไปเรียก getConversionRate() ซึ่งจะพังบน Anvil ธรรมดา
    //     fundMe.fund{value: SEND_VALUE}();

    //     uint256 amountFunded = fundMe.addressToAmountFunded(USER);
    //     assertEq(amountFunded, SEND_VALUE);
    // }

    // function testAddsFunderToArrayOfFunders() public {
    //     vm.prank(USER);
    //     fundMe.fund{value: SEND_VALUE}();

    //     address funder = fundMe.funders(0);
    //     assertEq(funder, USER);
    // }
}
