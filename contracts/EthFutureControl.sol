pragma solidity >=0.4.19 < 0.7.0;
// import './EthFutureData.sol';
import './EthFutureTree.sol';

contract EthFutureControl is EthFutureTree {
    uint8 public level1Rate;
    uint8 public level2Rate;
    uint8 public level3Rate;
    uint8 public level4Rate;

    // 个人收益
    mapping (address => uint) public ownerBenefit;

    // 限制释放比例在一个区间，防止输错, 1 ~ 20
    modifier rateRestrict(uint rate) {
        require(rate >= 1 && rate <= 20);
        _;
    }

    constructor () public {
        level1Rate = 9;
        level2Rate = 11;
        level3Rate = 13;
        level4Rate = 15;
    }

    // 设置释放比例
    function setLevel1Rate(uint8 _level1Rate) external onlyOwner rateRestrict(_level1Rate) {
        level1Rate = _level1Rate;
    }

    function setLevel2Rate(uint8 _level2Rate) external onlyOwner rateRestrict(_level2Rate) {
        level2Rate = _level2Rate;
    }

    function setLevel3Rate(uint8 _level3Rate) external onlyOwner rateRestrict(_level3Rate) {
        level3Rate = _level3Rate;
    }

    function setLevel4Rate(uint8 _level4Rate) external onlyOwner rateRestrict(_level4Rate) {
        level4Rate = _level4Rate;
    }

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

    // 投注, _reference :推荐人的邀请码
    function investGame(string memory _reference) public payable returns(bool) {
        // 限定最低1个eth起投,低于1个返回错误提示
        require(msg.value >= (10 ** 18));

        // 调用者的TToken余额为
        uint ttokenBalance = balanceOf(msg.sender);
        // 1eth = 2000Token, 门票为投注eth的 十分之一
        uint needTtoken = (msg.value / (10 ** 18) ) * (2000 / 10);

        // 要求账户ttoken的余额足够门票的支付
        require(ttokenBalance >= needTtoken);

        // createInvestInfo(msg.value, _getDayBenefitOfInvestment(msg.value));
        createInvestmentInfo(_reference, msg.value, _getDayBenefitOfInvestment(msg.value));
        
        // 扣除账户的门票
        _transfer(msg.sender, contractOwner, needTtoken);

        return true;
    }

    // 获取单次投资每日收益
    function _investInfoReleasePerDay(InvestInfo storage _investInfo) private view returns(uint) {
        uint8 timeDay = (uint8)((now - _investInfo.investTime) / 86400);

        if ((3 * _investInfo.investAmount) > (_investInfo.benefitPerDay * timeDay)) {
            // 还有收益可以释放
            uint benefitPerDay = (3 * _investInfo.investAmount) - (_investInfo.benefitPerDay * timeDay);
            if (benefitPerDay > _investInfo.benefitPerDay) {
                // 剩余的收益 > 单日释放的量
                return _investInfo.benefitPerDay;
            } else {
                // 剩余的收益 <= 单日释放的量
                return benefitPerDay;
            }

        } else {
            // 无收益释放
            return 0;
        }
    }

    // 获取一个节点每日的静态收益
    function _getStaticBenefitPerDayOfNode(Node storage node) private view returns(uint) {
        uint staticBenefit;
        for (uint8 i = 0; i < node.investInfos.length; i++) {
            InvestInfo storage investInfo = node.investInfos[i];
            staticBenefit = staticBenefit.add(_investInfoReleasePerDay(investInfo));
        }

        return staticBenefit;
    }

    // 获取当前用户每日的动态收益
    function _getDynamicBenefitPerDayOfOwner(Node storage node) private view returns(uint) {
        if (node.sonNodes.length == 0) {
            return 0;
        }

        // 第一代
        uint[] storage firstNodes = node.sonNodes;

        // 第二代
        uint[] memory secondeArr;
        uint secondLength = 0;
        for (uint i=0; i<firstNodes.length; i++) {
            uint firstId = firstNodes[i];
            Node storage firstNode = nodes[firstId];
            secondLength += firstNode.sonNodes.length;
        }

        secondeArr = new uint[](secondLength);
        uint secondTempK = 0;
        for (uint i=0; i<firstNodes.length; i++) {
            uint firstId = firstNodes[i];
            Node storage firstNode = nodes[firstId];

            for(uint j=0; j<firstNode.sonNodes.length; j++) {
                secondeArr[secondTempK] = firstNode.sonNodes[j];
                secondTempK++;
            }
        }

        // 第三代
        uint[] memory thirdArr;
        uint thirdLength = 0;
        for (uint i=0; i<secondeArr.length; i++) {
            uint secondId = secondeArr[i];
            Node storage secondNode = nodes[secondId];
            thirdLength += secondNode.sonNodes.length;
        }

        thirdArr = new uint[](thirdLength);
        uint thirdTempK = 0;
        for (uint i=0; i<secondeArr.length; i++) {
            uint secondId = secondeArr[i];
            Node storage secondNode = nodes[secondId];

            for (uint j=0; j<secondNode.sonNodes.length; j++) {
                thirdArr[thirdTempK] = secondNode.sonNodes[j];
                thirdTempK++;
            }
        }
    }

    // // 获取当前节点的所有子节点的下标
    // function _getSonNodesBenefitPerDay(Node storage node) private view returns(uint[] memory) {
    //     uint[] memory results = new uint[](node.sonNodes.length);

    //     for (uint i=0; i<node.sonNodes.length; i++) {
    //         results[i] = node.sonNodes[i];
    //     }

    //     return results;
    // }

    

    // 获取当前用户每日的收益，包括静态收益和动态收益
    function getBenefitPerDay() public view returns(uint) {
        require(ownerIsRegisted[msg.sender]);

        // Node storage node = nodes[ownerToIndex[msg.sender]];
        // uint staticBenefit = _getStaticBenefitPerDayOfNode(node);

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