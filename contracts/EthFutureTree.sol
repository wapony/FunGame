pragma solidity >=0.4.19 < 0.7.0;

contract EthFutreTree {

    // 邀请码与数组下标对应起来,用来快速找到推荐人
    mapping (string => uint) inviteCodeToIndex;

    // 投资者与生成的邀请码绑定
    mapping (address => string) ownerToInviteCode;

    struct Node {
        uint[] sonNodes;   // 用来存放子节点的下标
    }

    Node[] nodes;


    // 根据数组的下标生成一个6位数的邀请码
    
}