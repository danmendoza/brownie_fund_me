//SPDX-License-Identifier:MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;

    AggregatorV3Interface public priceFeed;

    address addressEtherUsd = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
    address public owner;
    address[] public funders;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        //establecemos el pago minimo de 50$
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "minimumUSD = 50$, You need to spend more ETH"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender); //si alguien invierte más de una vez el array será redundante, pero lo dejaremos pasar por el momento
    }

    function getVersion() public view returns (uint256) {
        return uint256(priceFeed.version());
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000);
    }

    //1000000000000000000wei = 1 eth
    // 100000000 gwei = 1 eth USD
    // 1 eth = $3,364.63
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10**18);
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withDraw() public payable onlyOwner {
        //antes de transferir necesitamos comprobar que el sender es el propietario, de eso se encargará el constructor
        msg.sender.transfer(address(this).balance);

        //reseteamos todas las cuentas de los inversores que participaron en el crowdfounding
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
