// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {priceConverter} from "contracts/priceConverter.sol";

error NotOwner(); 

contract FundMe {

    using priceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;

    address [] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor () { // constructor is a special keyword in solidity. while deploying it will sets the msg.sender = owner
        i_owner = msg.sender;
    }

    function fund () public payable {
        // allow users to send money 
        // have a minimum $ sent 
        require (msg.value.getConversionRate() >= MINIMUM_USD,"didnt send enough eth"); // 1e18 = 1000000000000000000 = 1 * 10 ** 18
        //what is revert ? undo any action that have been done and send the remaining gas back 
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner,"Must be a Owner!"); // = is used for set ; == is used for equal to in solidity
        // for loop 
        // [1, 2, 3, 4] elements 
        //  0, 1, 2, 3  indexes 
        // for (starting index; ending index; step amount)

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // actually withdraw the funds 
        /*
        How to send Ether?
        You can send Ether to other contracts by

        transfer (2300 gas, throws error)
        send (2300 gas, returns bool)
        call (forward all gas or set gas, returns bool)
        */
        // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // send 
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require (sendSuccess, "send failed");
        // call is the mose convenient way to withdraw money; if it is confusing try with ai 
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require (callSuccess, "call failed"); 

    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "sender is not Owner!");
        if (msg.sender != i_owner){
            revert NotOwner();
            }
        _; // this means execute the following lines in the function after the require
    }

    receive() external payable {
        fund();
     }

    fallback() external payable {
        fund();
     }

}
