pragma solidity >=0.4.24 < 0.7.0;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract TutorialToken  {
    // string public name = "TutorialToken";
    // string public symbol = "TT";
    // uint8 public decimals = 2;
    // uint public INITIAL_SUPPLY = 12000;
    // address contractOwner;

    constructor() public {
        // _mint(msg.sender, INITIAL_SUPPLY);
        // contractOwner = msg.sender;
    }

    // 实现购买TT操作
    // function buyTT() payable public returns(uint amount) {
        
    //     // 向合约的拥有者转移以太币
    //     require(contractOwner.transfer(msg.value));


    // }

    // 转移以太币试试看能不能测试
    function sellEth() payable public {

    }
}