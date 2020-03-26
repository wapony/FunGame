pragma solidity >=0.4.19 < 0.7.0;
import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './EthFutureData.sol';

contract EthFutureControl is Ownable {
    EthFutureData ethFutureDataContract;

    constructor (address _address) public {
        ethFutureDataContract = EthFutureData(_address);
    }

    // 购买门票
    function buyTToken() public view returns(bool) {
        require(msg.value >= (0.1 * (10 ** 18)));

        // 1Eth = 2000TToken;
        uint amount = (msg.value / 10 ** 18) * 2000;

        ethFutureDataContract.transferTokenToBuyer(msg.sender, amount);

        return true;
    }

    // // 投注
    // function investGame() public payable returns(bool) {
    //     // 限定最低1个eth起投,低于1个返回错误提示
    //     require(msg.value >= (10 ** 18));

    //     // 调用者的TToken余额为
    //     uint ttokenBalance = balanceOf(msg.sender);
    //     // 1eth = 2000Token, 门票为投注eth的 十分之一
    //     uint needTtoken = (msg.value / (10 ** 18) ) * (2000 / 10);

    //     // 要求账户ttoken的余额足够门票的支付
    //     require(ttokenBalance >= needTtoken);

    //     _createInvestInfo(msg.value, _getDayBenifitOfInvestment(msg.value));

    //     // 扣除账户的门票
    //     _transfer(msg.sender, contractOwner, needTtoken);

    //     return true;
    // }
}