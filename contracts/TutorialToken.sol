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

    // 转移TToken资产到当前地址, ERC20的public transfer方法是账户之间的转账，合约拥有者转账需要用_transfer
    function transferTToken(uint amount) internal returns(bool) {
        // 调用者不能等于合约的主人
        require(msg.sender != contractOwner);

        _transfer(contractOwner, msg.sender, amount);
        return true;
    }

    // // 提ETH到当前账户
    // function withdraw() public returns(bool) {
    //     // 参数的单位是wei， 所以转移1ETH，需要10 ** 18.  1ETH = 10 ** 18 Wei
    //     msg.sender.transfer(10 ** 18);
    // }
}