// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // สร้าง User จำลองสำหรับเทส
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1 gwei;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _; // สัญลักษณ์นี้บอกให้กลับไปรันโค้ดในฟังก์ชัน Test ของเรา
    }

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, ) = deployer.run();
        vm.deal(USER, STARTING_BALANCE); // เติมเงินให้ User จำลอง
    }
    // 1. ทดสอบว่าเจ้าของ Contract คือคนที่สั่ง deploy (ก็คือตัว FundMeTest เอง)
    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // 2. ทดสอบว่าค่า Minimum USD ตั้งไว้ถูกต้อง (5 * 10^18)
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // ตัวอย่างการปรับโค้ดใน Test ให้ตรงกับ FundMe.sol ล่าสุด
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        // เรียกผ่าน public mapping ตรงๆ (Solidity จะสร้าง getter ให้โดยอัตโนมัติ)
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testFundFailsWithoutEnoughETH() public {
        // 1. เราจะใช้ Cheatcode 'vm.expectRevert'
        // เพื่อบอก Foundry ว่า "ธุรกรรมบรรทัดถัดไปจะต้องพังนะ"
        vm.expectRevert();

        // 2. ส่งเงินไป 0 ETH (ซึ่งน้อยกว่า MINIMUM_USD แน่นอน)
        // เนื่องจากไม่ได้ใส่ {value: ...} มันจะเป็น 0 โดยปริยาย
        fundMe.fund();
    }

    // เทสว่าคนอื่นถอนเงินไม่ได้
    function testOnlyOwnerCanWithdraw() public funded {
        // ต้องพังเพราะ USER ไม่ใช่เจ้าของ
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    // เทสการถอนเงินโดยเจ้าของ (แบบเบื้องต้น)
    function testWithdrawWithASingleFunder() public funded {
        // Arrange (เตรียมตัว)
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (กระทำ)
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        // Assert (ตรวจสอบ)
        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWhoIsOwner() public {
        // console.log("Owner is:", fundMe.i_owner());
        // console.log("User is: ", USER);
        // console.log("Test Contract is:", address(this));

        assertEq(fundMe.i_owner(), msg.sender); // ลองเช็คว่าใช่ตัว Test Contract ไหม
    }

    function testWithdrawFromMultipleFunders() public funded {
        // 1. Arrange (เตรียมการ)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // เริ่มที่ 1 เพราะบางครั้ง address(0) อาจมีปัญหา

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // สร้าง address จำลอง: hoax คือการรวม vm.prank + vm.deal เข้าด้วยกัน
            // ช่วยให้เราสร้าง user และให้เงินได้ในบรรทัดเดียว
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act (กระทำ)
        vm.startPrank(fundMe.i_owner());
        fundMe.withdraw();
        vm.stopPrank();

        // 3. Assert (ตรวจสอบ)
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.i_owner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // 1. Arrange (เตรียมการ)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // เริ่มที่ 1 เพราะบางครั้ง address(0) อาจมีปัญหา

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // สร้าง address จำลอง: hoax คือการรวม vm.prank + vm.deal เข้าด้วยกัน
            // ช่วยให้เราสร้าง user และให้เงินได้ในบรรทัดเดียว
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2. Act (กระทำ)
        vm.startPrank(fundMe.i_owner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // 3. Assert (ตรวจสอบ)
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.i_owner().balance
        );
    }
}
