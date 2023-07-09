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

}