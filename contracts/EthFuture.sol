pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract EthFuture is TutorialToken, Ownable {

    uint8 level1Rate;
    uint8 level2Rate;
    uint8 level3Rate;
    uint8 level4Rate;

    event NewInvestment(uint investmentId,  uint investAmount, uint investmentTime);

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 investTime;     // 当前投注时间戳
        uint256 releasePerDay;  // 每日固定的释放量
    }

    // 记录每笔投资的信息
    InvestInfo[] public investInfos;

    // 限制释放比例在一个区间，防止输错, 1 ~ 20
    modifier rateRestrict(uint rate) {
        require(rate >= 1 && rate <= 20);
        _;
    }

    mapping (uint => address) public investmentToOwner;
    mapping (address => uint) public ownerInvestmentCount;
    mapping (address => uint) public ownerBenefit;

    constructor () public {
        level1Rate = 9;
        level2Rate = 11;
        level3Rate = 13;
        level4Rate = 15;
    }

    // 创建投资信息
    function _createInvestInfo(uint _investAmount, uint _releasePerDay) private {
        uint id = investInfos.push(InvestInfo(_investAmount, now, _releasePerDay)) - 1;
        investmentToOwner[id] = msg.sender;
        ownerInvestmentCount[msg.sender] = ownerInvestmentCount[msg.sender].add(1);

        emit NewInvestment(id, _investAmount, now);
    }

    // 每次投注固定每日的释放量
    function _getDayBenifitOfInvestment(uint _amount) private view returns(uint) {
        uint ethMount = _amount / (10 ** 18);
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

        return release;
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
        // uint amount = (msg.value / 10 ** 18) * 2000;
        // transferTToken(msg.sender, amount);

        return true;
    }

    // 投注
    function investGame() public payable returns(bool) {
        // 限定最低1个eth起投,低于1个返回错误提示
        require(msg.value >= (10 ** 18));

        // 调用者的TToken余额为
        uint ttokenBalance = balanceOf(msg.sender);
        // 1eth = 2000Token, 门票为投注eth的 十分之一
        uint needTtoken = (msg.value / (10 ** 18) ) * (2000 / 10);

        // 要求账户ttoken的余额足够门票的支付
        require(ttokenBalance >= needTtoken);

        _createInvestInfo(msg.value, _getDayBenifitOfInvestment(msg.value));

        // 扣除账户的门票
        _transfer(msg.sender, contractOwner, needTtoken);

        return true;
    }

    // 获取合约的剩余额度
    function getBalanceOfContract() public view returns(uint) {
        return address(this).balance;
    }

    // 单次投资每天的释放量
    function _investInfoReleasePerDay(InvestInfo storage _investInfo) private view returns(uint) {
        uint8 timeDay = (uint8)((now - _investInfo.investTime) / 86400);

        if ((3 * _investInfo.investAmount) > (_investInfo.releasePerDay * timeDay)) {
            // 还有收益可以释放
            uint benefitPerDay = (3 * _investInfo.investAmount) - (_investInfo.releasePerDay * timeDay);
            if (benefitPerDay > _investInfo.releasePerDay) {
                // 剩余的收益 > 单日释放的量
                return _investInfo.releasePerDay;
            } else {
                // 剩余的收益 <= 单日释放的量
                return benefitPerDay;
            }

        } else {
            // 无收益释放
            return 0;
        }
    }

    // 获取静态每日的释放额度
    function getStaticReleaseEthPerDay() internal returns(uint) {
        // 获取msg.sender的所有投资信息
        for (uint i = 0; i < investInfos.length; i++) {
            if (investmentToOwner[i] == msg.sender) {
                InvestInfo storage investInfo = investInfos[i];
                
                // 记录截止到当前时间为止用户可以提走的eth
                ownerBenefit[msg.sender] = ownerBenefit[msg.sender].add(_investInfoReleasePerDay(investInfo));
            }
        }

        return ownerBenefit[msg.sender];
    }

    // 合约拥有者提币
    function ownerGetBenefit(uint amount) external payable onlyOwner returns(bool) {
        require((amount * (10 ** 18)) <= address(this).balance);

        // 参数的单位是wei， 所以转移1ETH，需要10 ** 18.  1ETH = 10 ** 18 Wei
        msg.sender.transfer(amount * (10 ** 18));

        return true;
    }

    // 用户提币
    function withdraw() public payable returns(bool) {
        require((ownerBenefit[msg.sender] <= address(this).balance) && (ownerBenefit[msg.sender] > 0));

        uint amount = ownerBenefit[msg.sender];
        msg.sender.transfer(amount);

        ownerBenefit[msg.sender] = 0;

        return true;
    }
}
