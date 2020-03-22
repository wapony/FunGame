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

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 releasePerDay;  // 每日释放量
    }

    InvestInfo [] investInfos;  // 记录每次投资

    // 记录一个地址总投资额度
    mapping(address => uint) public ownerToEthAmount;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
        contractOwner = msg.sender;

        ownerToEthAmount[msg.sender] = 0;
    }

    // 创建每次投资的信息
    function _createInvestInfo(uint256 _investAmount, uint256 _releasePerDay) private {
        investInfos.push(InvestInfo(_investAmount, _releasePerDay));
    }

    // 向合约地址转移以太坊
    function buyTToken() public payable {
        ownerToEthAmount[msg.sender] = ownerToEthAmount[msg.sender].add(msg.value);

        uint256 amount = msg.value;
        uint256 release;
        if (amount >= 1 && amount < 6) {
            release = amount * 9 / 10000;
        } else if (amount >= 6 && amount < 10) {
            release = amount * 11 / 10000;
        } else if (amount >= 11 && amount < 30) {
            release = amount * 13 / 10000;
        } else {
            release = amount * 15 / 10000;
        }
    }

    // 获取当前用户的总投资额度
    function getOwnerTotalAmount() public view returns(uint) {
        return ownerToEthAmount[msg.sender];
    }

    // 获取合约以太坊的总额度
    function getContractAmount() public view returns(uint) {
        return address(this).balance;
    }

    // 转移TToken资产到当前地址, ERC20的public transfer方法是账户之间的转账，合约拥有者转账需要用_transfer
    function transferTToken() public returns(bool) {
        uint amount = 100;
        _transfer(contractOwner, msg.sender, amount);
        return true;
    }

    // 提ETH到当前账户
    function withdraw() public returns(bool) {
        // 参数的单位是wei， 所以转移1ETH，需要10 ** 18.  1ETH = 10 ** 18 Wei
        msg.sender.transfer(10 ** 18);
    }
}