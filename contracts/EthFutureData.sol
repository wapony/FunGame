pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract EthFutureData is TutorialToken, Ownable {
    mapping (address => bool) accessAllowed;

    modifier addressAllowed() {
        require(accessAllowed[msg.sender]);
        _;
    }

    constructor () public {
        accessAllowed[msg.sender] = true;
    }

    function setAccessAllow(address _address) public onlyOwner {
        accessAllowed[_address] = true;
    }

    function denyAccessAllow(address _address) public onlyOwner {
        accessAllowed[_address] = false;
    }

    // 转TToken到付款账户
    function transferTokenToBuyer(address _buyer, uint _amount) public addressAllowed {
        transferTToken(_buyer, _amount);
    }
}