pragma solidity >=0.4.24 < 0.7.0;
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/math/SafeMath.sol';
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract TutorialToken is ERC20 {
    using SafeMath for uint256;

    string public name = "TutorialToken";
    string public symbol = "TT";
    uint8 public decimals = 0;
    uint public INITIAL_SUPPLY = 120000;
    address contractOwner;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
        contractOwner = msg.sender;
    }
}