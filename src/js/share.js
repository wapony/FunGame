function segmentButtonClick(obj) {
    $(obj).siblings().attr('class', 'unselected');
    $(obj).attr('class', 'selected');

    var objId = $(obj).attr('id');

    if (objId == "urlShareButton") {
        $(".content_urlShare").css("display", "inline");
        $(".content_myShare").css("display", "none");
        $(".content_community").css("display", "none");
    } else if (objId == "myShareButton") {
        $(".content_urlShare").css("display", "none");
        $(".content_myShare").css("display", "inline");
        $(".content_community").css("display", "none");
    } else {
        $(".content_urlShare").css("display", "none");
        $(".content_myShare").css("display", "none");
        $(".content_community").css("display", "inline");
    }
}

function copy() {
    var clipboard = new ClipboardJS("#copyButton", {
        text : function() {
            return $("#myInviteUrl").val();
        }
    });

    clipboard.on('success',function(e){
        $('#show').slideDown().delay(1500).slideUp(300);
        alert("复制成功");
    });

    clipboard.on('error',function(e){
        $('#show').slideDown().delay(1500).slideUp(300);
        alert("复制失败");
    });
}   

function showShareInfo() {
    var tab = document.getElementById('table_shareInfo');
    var tradd = tab.insertRow(1);
    tradd.innerHTML='<td>1</td><td>sdng06</td><td>11.000</td>'; 
    
    tradd = tab.insertRow(2);
    tradd.innerHTML = '<td>2</td><td>sdng07</td><td>12.000</td>';

    tradd = tab.insertRow(3);
    tradd.innerHTML = '<td>3</td><td>sdng08</td><td>13.000</td>';

}

const Page = {
    web3Provider: null,
    contracts: {},

    init: function() {
        Page.web3Provider = App.web3Provider;
        Page.initContracts();
    },

    initContracts: function() {
        $.getJSON('EthFutureControl.json', function(data) {
            var ethFutureAirtifact = data;
			Page.contracts.EthFuture = TruffleContract(ethFutureAirtifact);
            Page.contracts.EthFuture.setProvider(Page.web3Provider); 

            Page.getInvestorCode();
        });
    },

    getInvestorCode: function() {
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
                return;
            }

            var account = accounts[0];

            Page.contracts.EthFuture.deployed().then(function(instance) {
                return instance.getInvestorCode({from: account});
            }).then(function(result) {
                if (result == "该用户尚未注册无法获取邀请码") {
                    alert("该用户尚未注册无法获取邀请码");
                } else {
                    $("#myInviteUrl").val("http://localhost:3000/?code=" + result);
                }
                
            }).catch(function(error) {
                alert(error);
            });

        });
    },
};

$(function() { 
    $(window).on("load", function () {
		Page.init();
    });

    copy();
    showShareInfo();
}); 