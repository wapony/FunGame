pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';

contract EthFutureData is TutorialToken, Ownable {
    uint8 public level1Rate;
    uint8 public level2Rate;
    uint8 public level3Rate;
    uint8 public level4Rate;

    event NewInvestment(uint investmentId,  uint investAmount, uint investmentTime);

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 investTime;     // 当前投注时间戳
        uint256 releasePerDay;  // 每日固定的释放量
    }

    // 限制释放比例在一个区间，防止输错, 1 ~ 20
    modifier rateRestrict(uint rate) {
        require(rate >= 1 && rate <= 20);
        _;
    }

    mapping (uint => address) public investmentToOwner;
    mapping (address => uint) public ownerInvestmentCount;
    mapping (address => uint) public ownerBenefit;

    // 记录每笔投资的信息
    InvestInfo[] public investInfos;

    constructor () public {
        // level1Rate = 9;
        // level2Rate = 11;
        // level3Rate = 13;
        // level4Rate = 15;
    }

    // // 设置释放比例
    // function setLevel1Rate(uint8 _level1Rate) public onlyOwner rateRestrict(_level1Rate) {
    //     level1Rate = _level1Rate;
    // }

    // function setLevel2Rate(uint8 _level2Rate) public onlyOwner rateRestrict(_level2Rate) {
    //     level2Rate = _level2Rate;
    // }

    // function setLevel3Rate(uint8 _level3Rate) public onlyOwner rateRestrict(_level3Rate) {
    //     level3Rate = _level3Rate;
    // }

    // function setLevel4Rate(uint8 _level4Rate) public onlyOwner rateRestrict(_level4Rate) {
    //     level4Rate = _level4Rate;
    // }

    // 创建投资信息
    function createInvestInfo(uint _investAmount, uint _releasePerDay) internal {
        uint id = investInfos.push(InvestInfo(_investAmount, now, _releasePerDay)) - 1;
        investmentToOwner[id] = msg.sender;
        ownerInvestmentCount[msg.sender] = ownerInvestmentCount[msg.sender].add(1);

        emit NewInvestment(id, _investAmount, now);
    }
  
}