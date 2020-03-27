pragma solidity >=0.4.24 < 0.7.0;
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/math/SafeMath.sol';
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract TutorialToken is ERC20 {
    using SafeMath for uint256;

    string public name = "TutorialToken";
    string public symbol = "TT";
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 12000;
    address contractOwner;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
        contractOwner = msg.sender;
    }

    // // 支付TToken到付款账户
    // function payoffTToken(address _reciept, uint amount) internal returns(bool) {
    //     // 调用者不能等于合约的主人
    //     require(_reciept != contractOwner);

    //     _transfer(contractOwner, _reciept, amount);
    //     return true;
    // }

    // // 回收TToken
    // function recycleTToken(address _spender, uint amount) internal returns(bool) {
    //     _transfer(_spender, contractOwner, amount);
    //     return true;
    // }
}