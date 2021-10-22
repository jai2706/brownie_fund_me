// SPDX-Licence_Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe{
    
    using SafeMathChainlink for uint256;
    
    mapping(address=>uint256)public addressToAmountFunded;
    address[]public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed) public{
        priceFeed=AggregatorV3Interface(_priceFeed);
        owner=msg.sender;
    }
    
    function fund()public payable{
        uint256 minimumUSD = 50*(10**18);
        require(getConversion(msg.value)>=minimumUSD , "You need to spend more ETH!");
        addressToAmountFunded[msg.sender]+=msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
         (
          ,
          int256 answer,
          ,
          ,
          
          ) = priceFeed.latestRoundData();
          return uint256(answer*10000000000);
    }
    
    function getConversion(uint256 ethAmount)public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountinUSD = (ethPrice * ethAmount)/1000000000000000000;
        return ethAmountinUSD;
    }

    function getEntranceFee()public view returns (uint256){
        // minimumUSD
        uint256 minimumUSD=50*(10**18);
        uint256 price=getPrice();
        uint256 precesion=1*(10**18);
        return (minimumUSD*precesion)/price;
    }
    
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    
    function withdraw()payable onlyOwner public{
        
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex=0;funderIndex<funders.length;funderIndex++)
        {
            address funder=funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        funders=new address[](0);
        
    }
}