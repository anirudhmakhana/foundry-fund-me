//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    uint256 number = 1;
    FundMe fundMe;

    function setUp() external{
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
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

}