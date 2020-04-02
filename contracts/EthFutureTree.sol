pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';

contract EthFutureTree is TutorialToken, Ownable {
    // 邀请码与数组下标对应起来,用来快速找到推荐人
    mapping (string => uint) inviteCodeToIndex;

    // 投资者投资者是否已经投注过
    mapping (address => bool) ownerIsRegisted;

    // 投资者投资成功后与数组下标对应, 复投能快速查到对应的节点
    mapping (address => uint) ownerToIndex;

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 investTime;     // 当前投注时间戳
        uint256 benefitPerDay;  // 每日固定的释放量
    } // 投资信息

    struct Node {
        InvestInfo[] investInfos; // 记录该节点复投的信息
        uint[] sonNodes;          // 用来存放子节点的下标
        string inviteCode;        // 当前节点的推荐码
        uint8  level;             // 当前节点的等级
    } // 节点

    // 存放所有投资用户的信息
    Node[] nodes;

    // 根节点
    Node root;

    constructor () public {
        ownerToIndex[msg.sender] = (nodes.push(root) - 1);
        ownerIsRegisted[msg.sender] = true;

        // 根节点的推荐码如何记录生成呢,这个问题需要思考一下
        root.level = 10;
        root.inviteCode = "4QU86X";
    }

    // 根据数组的下标生成一个6位数的邀请码
    function _createInviteCode() private pure returns(string memory) {
        string memory inviteCode = "4QU86X";
        return inviteCode;
    }

    // 根据投资量计算等级
    function _getLevelFromAmount(uint _amount) private pure returns(uint8) {
        uint ethAmount = _amount / (10 ** 18);
        uint8 level;
        if (ethAmount >= 1 && ethAmount < 6) {
            level = 1;
        } else if (ethAmount >= 6 && ethAmount < 11) {
            level = 2;
        } else if (ethAmount >= 11 && ethAmount < 30) {
            level = 3;
        } else {
            level = 4;
        }
        
        return level;
    }

    // 创建一个节点
    // _reference: 推荐人的邀请码
    function _createNode(string memory _reference, uint _amount, uint _benefitPerDay) private {
        // 生成该用户的推荐码
        string memory inviteCode = _createInviteCode();

        // solidity的坑，不能新建一个node,然后在push，要先扩展nodes的length然后直接给下标赋值
        uint id = nodes.length++; // 先把nodes.length赋值给id，然后node.length才加1
        nodes[id].investInfos.push(InvestInfo(_amount, now,  _benefitPerDay));
        nodes[id].inviteCode = inviteCode;
        // 首次注册根据投资数额获取初始level
        nodes[id].level = _getLevelFromAmount(_amount);

        // 把推荐码和nodes的下标对应起来，推荐别人注册的时候可以快速定位的推荐人
        inviteCodeToIndex[inviteCode] = id;

        // 地址与自身的下标对应，复投的时候定位到自己的位置
        ownerToIndex[msg.sender] = id;

        // 设置地址为已经注册过
        ownerIsRegisted[msg.sender] = true;

        // 把id加入推荐人的sonNodes数组中, 记录该id为推荐人的son
        uint referenceId = inviteCodeToIndex[_reference];
        nodes[referenceId].sonNodes.push(id);
    }

    // 复投
    function _reInvestment(uint _amount, uint _benefitPerDay) private {
        uint id = ownerToIndex[msg.sender];
        nodes[id].investInfos.push(InvestInfo(_amount, now, _benefitPerDay));

        uint totalAmount;
        for (uint i=0; i< nodes[id].investInfos.length; i++) {
            totalAmount = totalAmount.add(nodes[id].investInfos[i].investAmount);
        }
        // 更新node的level
        nodes[id].level = _getLevelFromAmount(totalAmount);
    }

    // 投资 分两种情况 1、复投  2、第一次投资
    function createInvestmentInfo(string memory _reference, uint _amount, uint _benefitPerDay) public {
        if (!ownerIsRegisted[msg.sender]) {
            _createNode(_reference, _amount, _benefitPerDay);
        } else {
            _reInvestment(_amount, _benefitPerDay);
        }
    }

    // 获取当前用户的邀请码
    function getOwnerInviteCode() public view returns(string memory) {
        uint id = ownerToIndex[msg.sender];
        return nodes[id].inviteCode;
    }
}