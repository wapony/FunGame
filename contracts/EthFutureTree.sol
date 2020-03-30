pragma solidity >=0.4.19 < 0.7.0;
import './TutorialToken.sol';

contract EthFutreTree {

    // 邀请码与数组下标对应起来,用来快速找到推荐人
    mapping (string => uint) inviteCodeToIndex;

    // 投资者投资者是否已经投注过
    mapping (address => bool) isRegisted;

    // 投资者投资成功后与数组下标对应, 复投能快速查到对应的节点
    mapping (address => uint) ownerToIndex;

    struct InvestInfo {
        uint256 investAmount;   // 投资额度
        uint256 investTime;     // 当前投注时间戳
        uint256 releasePerDay;  // 每日固定的释放量
    } // 投资信息

    struct Node {
        InvestInfo[] investInfos; // 记录该节点复投的信息
        uint[] sonNodes;          // 用来存放子节点的下标
        string inviteCode;        // 当前节点的推荐码
    } // 节点

    // 存放所有投资用户的信息
    Node[] nodes;

    // 根节点
    Node root;

    constructor() public {
        ownerToIndex[msg.sender] = (nodes.push(root) - 1);

        // 根节点的推荐码如何记录生成呢,这个问题需要思考一下
    }

    // 根据数组的下标生成一个6位数的邀请码
    function _createInviteCode() private pure returns(string memory) {
        string memory inviteCode = "4QU86X";
        return inviteCode;
    }

    // 创建一个节点
    // _reference: 推荐人的邀请码
    function createNode(string memory _reference) internal {
        require(isRegisted[msg.sender] == false);
    
        InvestInfo[] memory investInfos = new InvestInfo[](1);
        uint[] memory sonNodes = new uint[](1);

        // 生成该用户的推荐码
        string memory inviteCode = _createInviteCode();

        uint id = nodes.push(Node({investInfos: investInfos, 
                                      sonNodes: sonNodes,
                                    inviteCode: inviteCode})) - 1;

        // 把推荐码和nodes的下标对应起来，推荐别人注册的时候可以快速定位的推荐人
        inviteCodeToIndex[inviteCode] = id;

        // 推荐码与自身的下标对应，复投的时候定位到自己的位置
        ownerToIndex[msg.sender] = id;

        // 设置地址为已经注册过
        isRegisted[msg.sender] = true;

        // 把id加入推荐人的sonNodes数组中, 记录该id为推荐人的son
        uint referenceId = inviteCodeToIndex[_reference];
        nodes[referenceId].sonNodes.push(id);
    }

    // 获取当前用户的邀请码
    function getOwnerInviteCode() public view returns(string memory) {
        uint id = ownerToIndex[msg.sender];
        return nodes[id].inviteCode;
    }
}