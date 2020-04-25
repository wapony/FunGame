pragma solidity >=0.4.19 < 0.7.0;
import './EthFutureTree.sol';

contract EthFutureControl is EthFutureTree {
    uint8 public level1Rate;
    uint8 public level2Rate;
    uint8 public level3Rate;
    uint8 public level4Rate;

    uint16 public firstRate;  // 动态第一代
    uint16 public secondRate; // 动态第二代
    uint8 public thirdRate;   // 动态第三代
    uint8 public forthToTenRate;  // 4-10代
    uint8 public elevenToTwentyRate; // 11-20代
    uint8 public moreRate;           // 20代以后

    // 个人收益
    mapping (address => uint) public ownerBenefit;

    // 用户已经提币的数量
    mapping (address => uint) historyBenefit;

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

        firstRate = 500;
        secondRate = 300;
        thirdRate = 200;
        forthToTenRate = 100;
        elevenToTwentyRate = 10;
        moreRate = 5;
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
        uint amount = msg.value.mul(2000) / 10 ** 18;

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
        // 首次投注并且没有邀请码
        if (ownerIsRegisted[msg.sender] == false && bytes(_reference).length == 0) {
            return false;
        }

        // ？当用户输入的邀请码是无效的邀请码如何处理？  直接默认为首用户

        // 限定最低1个eth起投,低于1个返回错误提示
        require(msg.value >= (10 ** 18));

        // 调用者的TToken余额为
        uint ttokenBalance = balanceOf(msg.sender);
        // 1eth = 2000Token, 门票为投注eth的 十分之一
        uint needTtoken = msg.value.mul(2000 / 10) / (10 ** 18);

        // 要求账户ttoken的余额足够门票的支付
        require(ttokenBalance >= needTtoken);

        // 复投不对邀请码做校验
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
    function _getDynamicBenefitPerDayOfNode(Node storage node) private view returns(uint) {
        if (node.sonNodes.length == 0) {
            return 0;
        }

        // 第一代
        uint[] memory firstNodes = node.sonNodes;
        uint firstBenefit;
        for (uint i=0; i<node.sonNodes.length; i++) {
            Node storage sonNode = nodes[node.sonNodes[i]];
            firstBenefit = firstBenefit.add(_getStaticBenefitPerDayOfNode(sonNode));
        }        

        // 总共可以拿多少代
        uint count;
        if (node.level == 1) {
            count = 1;
        } else if (node.level == 2) {
            count = 10;
        } else if (node.level == 3) {
            count = 20;
        } else if (node.level == 4) {
            count = 40;
        } else {
            count = 1;
        }


        uint[] memory tempArr = firstNodes;
        uint[] memory benefits = new uint[](count);
        benefits[0] = firstBenefit;

        //从第二代开始计算
        for (uint i=2; i<=count; i++) {
            (tempArr, benefits[i-1]) = _getSonNodesArrayAndBenefit(tempArr);
        }

        
        uint dynamicBenefit;    // 动态奖金
        for (uint i=0; i<benefits.length; i++) {
            if (i == 0) {
                dynamicBenefit += benefits[i] * firstRate / 1000;
            } else if (i == 1) {
                dynamicBenefit += benefits[i] * secondRate / 1000;
            } else if (i == 2) {
                dynamicBenefit += benefits[i] * thirdRate / 1000;
            } else if (i >= 3 && i < 10) {
                dynamicBenefit += benefits[i] * forthToTenRate / 1000;
            } else if (i >= 10 && i < 20 ) {
                dynamicBenefit += benefits[i] * elevenToTwentyRate / 1000;
            } else {
                dynamicBenefit += benefits[i] * moreRate / 1000;
            }
        }

        return dynamicBenefit;
    }

    // 获取下一代所有子节点的下标数组和收益
    function _getSonNodesArrayAndBenefit(uint[] memory _array) private view returns(uint[] memory, uint) {
        uint[] memory sonNodes;
        uint sonNodesLength = 0;

        for (uint i=0; i<_array.length; i++) {
            uint currentId = _array[i];
            Node storage currentNode = nodes[currentId];
            sonNodesLength += currentNode.sonNodes.length;
        }

        if (sonNodesLength != 0) {
            sonNodes = new uint[](sonNodesLength);
        }

        uint tempK = 0; // sonNodes下标
        uint totalSonBenefit;
        for (uint i=0; i<_array.length; i++) {
            uint currentId = _array[i];
            Node storage currentNode = nodes[currentId];

            for (uint j=0; j<currentNode.sonNodes.length; j++) {
                sonNodes[tempK] = currentNode.sonNodes[j];
                tempK++;

                // 这里已经遍历到所有子节点了，所以可以直接计算所有子节点的静态收益了
                Node storage sonNode = nodes[currentNode.sonNodes[j]];
                totalSonBenefit = totalSonBenefit.add(_getStaticBenefitPerDayOfNode(sonNode));
            }
        }

        return(sonNodes, totalSonBenefit);
    }

    // // 获取当前用户每日的收益，包括静态收益和动态收益
    // function getBenefitPerDay() public view returns(uint) {
    //     require(ownerIsRegisted[msg.sender]);

    //     Node storage node = nodes[ownerToIndex[msg.sender]];
    //     uint staticBenefit = _getStaticBenefitPerDayOfNode(node);
    //     uint dynamicBenefit = _getDynamicBenefitPerDayOfNode(node);

    //     return staticBenefit + dynamicBenefit;
    // }

    // 获取用户从投资开始到当前时间 用户的总收益（静态，动态），也就是总共的收益（包括用户已经提走的）
    function getTotalBenefit() public view returns(uint, uint) {
        Node storage node = nodes[ownerToIndex[msg.sender]];
        InvestInfo storage firstInvest = node.investInfos[0];

        // 从第一次投资开始计算天数
        uint8 timeDay = (uint8)((now - firstInvest.investTime) / 86400);
        
        uint totalStaticBenefit;
        uint totalDynamicBenefit;
        for (uint8 i=0; i<timeDay; i++) {
            totalStaticBenefit = totalStaticBenefit.add(_getStaticBenefitPerDayOfNode(node));
            totalDynamicBenefit = totalDynamicBenefit.add(_getDynamicBenefitPerDayOfNode(node));
        }

        return (totalStaticBenefit, totalDynamicBenefit);
    }

    // 获取截止当前时间可以提现的以太
    function getAbleCash() public returns(uint) {
        uint staticBenefit;
        uint dynamicBenefit;
        (staticBenefit, dynamicBenefit) = getTotalBenefit();

        ownerBenefit[msg.sender] = (staticBenefit.add(dynamicBenefit)).sub(historyBenefit[msg.sender]);

        return ownerBenefit[msg.sender];
    }

    /**
     * uint: 静态每日释放量
     * uint: 动态每日释放量
     * uint: 该账户的投资总额
     * uint: 杠杆资产
     */
    // function accountInfo() public view returns(uint, uint, uint, uint) {
    //     Node storage node = nodes[ownerToIndex[msg.sender]];
    //     uint staticPerDayBenefit = _getStaticBenefitPerDayOfNode(node);
    //     uint dynamicPerDayBenefit = _getDynamicBenefitPerDayOfNode(node);
    //     uint totalAmount;
    //     for (var i=0; i<node.investInfos.length; i++) {
    //         InvestInfo storage temp = investInfos[i];
    //         totalAmount = totalAmount.add(temp.investAmount);
    //     }

    //     // 杠杆资产
    //     uint leverage = totalAmount * 3;

    //     return (staticPerDayBenefit, dynamicPerDayBenefit, totalAmount, leverage);
    // }

    // 获取当前用户的邀请码
    function getInvestorCode() public view returns(string memory) {
        if (ownerIsRegisted[msg.sender] == false) {
            return "该用户尚未注册无法获取邀请码";
        } else {
            return _createInviteCode();
        }
    }

    // 获取当前合约账户的余额
    function getContractBalanceOfEth() public view returns(uint) {
        return address(this).balance;
    }

    // 用户提现
    function withdraw() public returns(bool) {
        uint amount = ownerBenefit[msg.sender];
        ownerBenefit[msg.sender] = 0;

        // 把每次可提的币累加 记录提币的总量
        historyBenefit[msg.sender] = historyBenefit[msg.sender].add(amount);

        msg.sender.transfer(amount);

        return true;
    }

    // 合约销毁
    function destroyContract() external onlyOwner {
        selfdestruct(msg.sender);
    }
}