
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

            Page.getSoldAndDestoryAmount();
        });

        Page.bindEvents();
    },

    bindEvents: function() {
        // $(document).on('click', '#confirm', Page.confirmBuyTicket);
        // $("#confirm").click(function() {Page.confirmBuyTicket});

        $(document).on('click', '#confirm', Page.confirmBuyTicket);
    },

    // 获取出售的门票和销毁的门票
    getSoldAndDestoryAmount: function() {
        Page.contracts.EthFuture.deployed().then(function(instance) {
            return instance.getSoldAndDestoryedTicketAmount();
        }).then(function(reslut) {
            console.log(reslut[0].c[0]);
            console.log(reslut[1].c[0]);
        }).catch(function(error) {
            console.log(error);
        });
    },

    // 购买门票
    confirmBuyTicket: function() {
        event.preventDefault();

		var amount = parseFloat($('#ethAmount').val());

		if (amount > 0) {
			var ethFutureInstance;

			web3.eth.getAccounts(function (error, accounts) {
				if (error) {
					console.log(error);
					return;
				}

				var account = accounts[0];

				if (account != 0x5d352131227C35E87E870D6ddFb5be1C921e283e) {
					var etherValue = web3.toWei(amount, 'ether');

					Page.contracts.EthFuture.deployed().then(function (instance) {
						ethFutureInstance = instance;

						return ethFutureInstance.buyTToken({from: account, value: etherValue});
					}).then(function (result) {
                        alert("购买成功");
                        window.history.back('main.html');
					}).catch(function (error) {
						alert(error);
					});
				} else {
					alert("自己不能向自己买Token");
				}
				
			});

		} else {
			alert("请输入正确的门票数量");
		}

    },
};

$(function() { 
	// $(window).on("load", function() {
    //     $('#ethAmount').attr("value");
	// 	Page.init();
    // });
    Page.init();
}); 