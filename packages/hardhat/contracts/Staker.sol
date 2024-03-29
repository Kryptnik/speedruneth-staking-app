// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  event Stake(address, uint256);

  // mapping of individual balances
  mapping(address => uint256) public balances;
  // goal threshold
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed());
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() notCompleted public payable {
    address sender = msg.sender;
    uint256 amount = msg.value;

    balances[sender] += amount;
    emit Stake(sender, amount);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() notCompleted public {
    require(block.timestamp >= deadline);
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else{
      openForWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
    require(openForWithdraw, "Can't withdraw at this time");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "No funds to withdraw");
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    return block.timestamp >= deadline ? 0 : deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}
