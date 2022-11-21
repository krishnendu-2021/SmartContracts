//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe{

    address public owner;
    uint256 public minUSD = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public fundersDetails;

    constructor(){
        owner = msg.sender;
    }

    function getVersion() public view returns(uint256) {
        return AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e).version();
    }

    function getPrice() public view returns(uint256){
        (,int256 price,,,) = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e).latestRoundData();
        return uint256(price* 1e10);
    } 

    function EtherToUsdConversion(uint256 userFunded) public view returns(uint256){
        uint256 price = getPrice();
        uint256 priceValue = (userFunded * price) / 1e18;
        return priceValue;
    }
    
    function sendEthers() public payable{
        require(EtherToUsdConversion(msg.value) >= minUSD,"please donate more");
        funders.push(msg.sender);
        fundersDetails[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner{
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"call failed");
        for(uint256 senderIndex = 0; senderIndex < funders.length; senderIndex++){
            address senders = funders[senderIndex] ;
            fundersDetails[senders] = 0;
        }
        funders = new address[](0);
    }

    modifier onlyOwner{
        require(msg.sender == owner , "only owner can transfer funds");
        _;
    }
}