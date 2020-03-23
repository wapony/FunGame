pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract EthFuture is TutorialToken, Ownable {

    uint8 level1Rate;
    uint8 level2Rate;
    uint8 level3Rate;
    uint8 level4Rate;

    mapping (address => uint) ownerToEthAmount;

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 releasePerDay;  // 每日释放量
    }

    // 记录每笔投资的信息
    InvestInfo[] investInfos;

    // 限制释放比例在一个区间，防止输错, 1 ~ 20
    modifier rateRestrict(uint rate) {
        require(rate >= 1 && rate <= 20);
        _;
    }

    // 创建投资信息
    function _createInvestInfo(uint _investAmount, uint _releasePerDay) private {
        investInfos.push(InvestInfo(_investAmount, _releasePerDay));
    }

    function setLevel1Rate(uint8 _level1Rate) public onlyOwner rateRestrict(_level1Rate) {
        level1Rate = _level1Rate;
    }

    function setLevel2Rate(uint8 _level2Rate) public onlyOwner rateRestrict(_level2Rate) {
        level2Rate = _level2Rate;
    }

    function setLevel3Rate(uint8 _level3Rate) public onlyOwner rateRestrict(_level3Rate) {
        level3Rate = _level3Rate;
    }

    function setLevel4Rate(uint8 _level4Rate) public onlyOwner rateRestrict(_level4Rate) {
        level4Rate = _level4Rate;
    }

    // 购买门票
    function buyTToken() public payable returns(bool) {
        require(msg.value >= (0.1 * (10 ** 18)));

        // 1Eth = 2000TToken;
        uint amount = (msg.value / 10 ** 18) * 2000;
        transferTToken(amount);

        return true;
    }

    // 投注
    function investGame() public payable returns(bool) {
        // 限定最低1个eth起投,低于1个返回错误提示
        require(msg.value >= (10 ** 18));

        ownerToEthAmount[msg.sender] = ownerToEthAmount[msg.sender].add(msg.value);

        // 创建每次投资的信息
        uint ethMount = msg.value / (10 ** 18);
        uint release;
        if (ethMount >= 1 && ethMount < 6) {
            release = msg.value * level1Rate / 1000;
        } else if (ethMount >= 6 && ethMount < 11) {
            release = msg.value * level2Rate / 1000;
        } else if (ethMount >= 11 && ethMount < 30) {
            release = msg.value * level3Rate / 1000;
        } else {
            release = msg.value * level4Rate / 1000;
        }

        _createInvestInfo(msg.value, release);

        return true;
    }

    // 获取总投资额度
    function getInvestTotalAmount() public view returns(uint) {
        return ownerToEthAmount[msg.sender];
    }

    // 获取合约的剩余额度
    function getBalanceOfContract() public view returns(uint) {
        return address(this).balance;
    }

    // 获取每日的释放额度, 问题有点复杂，需要再想想, 例如：第一次释放的已经释放完，总不能继续释放吧。
    function getReleaseEthPerDay() public view returns(uint) {
        // uint releaseTotalPerDay;

        // for(uint i=0; i<investInfos.length; i++) {
        //     InvestInfo storage temp = investInfos[i];
        //     releaseTotalPerDay = releaseTotalPerDay.add(temp.releasePerDay);
        // }

        // return releaseTotalPerDay;
    }
}
