//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    uint256 number = 1;
    FundMe fundMe;

    address USER = makeAddr("user");
    uint constant SEND_VALUE = 1e18;
    uint constant STARTING_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external{
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    } 

    function testMinimumDollarIsFive() public{
        //this will pass
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        //thii will fail
        // assertEq(fundMe.MINIMUM_USD(), 16e18);
    }

    function testOwnerIsMessageSender() public{
        //This will fail since msg.sender is not the owner of FundMe, its the contract that owns since its deploying it.
        // assertEq(fundMe.i_owner(), msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public{
        assertEq(fundMe.getVersion(), 4);
    }

    function testFund() public{
        vm.expectRevert(); //hey, the next line, should revert!
        fundMe.fund();
    }

    function testFundUpdatesDataStrucutre() public{
        vm.prank(USER); //THE next line, should be called by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER); //THE next line, should be called by USER
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        // assertEq(funders.length, 1);
        assertEq(funder, USER);
    }

    modifier funded(){
        vm.prank(USER); //THE next line, should be called by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert(); //hey, the next line, should revert!
        vm.prank(USER); //THE next line, should be called by USER
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft(); //built in function in solidity, it tells you how much gas you have left
        // // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithDrawFromMultipleFunders() public funded {
        //if we want to  use numbers to generate addresses, we need to use uint160
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

}