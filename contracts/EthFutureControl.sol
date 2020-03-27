pragma solidity >=0.4.19 < 0.7.0;
import './EthFutureData.sol';

contract EthFutureControl is EthFutureData {

    // 购买门票
    function buyTToken() public payable returns(bool) {
        require(msg.value >= (0.1 * (10 ** 18)));
        
        // 1Eth = 2000TToken;
        uint amount = (msg.value / 10 ** 18) * 2000;

        // 转移对应的token到购买者的账户
        _transfer(contractOwner, msg.sender, amount);

        return true;
    }

   // 每次投注固定每日的释放量, 这个是固定的释放量
    function _getDayBenefitOfInvestment(uint _amount) private view returns(uint) {
        uint ethMount = _amount / (10 ** 18);
        uint release;
        if (ethMount >= 1 && ethMount < 6) {
            release = _amount * level1Rate / 1000;
        } else if (ethMount >= 6 && ethMount < 11) {
            release = _amount * level2Rate / 1000;
        } else if (ethMount >= 11 && ethMount < 30) {
            release = _amount * level3Rate / 1000;
        } else {
            release = _amount * level4Rate / 1000;
        }

        return release;
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

        createInvestInfo(msg.value, _getDayBenefitOfInvestment(msg.value));
        
        // 扣除账户的门票
        _transfer(msg.sender, contractOwner, needTtoken);

        return true;
    }

    // 获取单次投资每日收益
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
    function getStaticReleaseEthPerDay() public returns(uint) {
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
    
    // 获取当前合约账户的余额
    function getContractBalanceOfEth() public view returns(uint) {
        return address(this).balance;
    }

    // 用户提现
    function withdraw() public returns(bool) {
        uint amount = ownerBenefit[msg.sender];
        ownerBenefit[msg.sender] = 0;
        msg.sender.transfer(amount);

        return true;
    }
}