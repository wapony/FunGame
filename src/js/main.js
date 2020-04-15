App = {
	web3Provider: null,
	contracts: {},
	ttBalance: 0,	// ttoken余额

	init: function() {
		return App.initWeb3();
	},

	initWeb3: function() {
		if (window.ethereum) {
			App.web3Provider = window.ethereum;

			try {
				window.ethereum.enable();
			} catch(error) {
				console.error("user denied account access");
			}
		} else if (window.web3) {
			App.web3Provider = window.web3.currentProvider;
		} else {
			App.web3Provider = new Web3.providers.HttpProvider("http://127.0.0.1:8545");
		}
		web3 = new Web3(App.web3Provider);

		return App.intContract();
	},

	intContract: function() {
		$.getJSON('EthFutureControl.json', function(data) {
			var ethFutureAirtifact = data;
			App.contracts.EthFuture = TruffleContract(ethFutureAirtifact);

			App.contracts.EthFuture.setProvider(App.web3Provider);

			// 获取合约余额
			App.getEthBalance();

			// 获取TToken余额
			App.getTTokenBalace();
		});

		App.bindEvents();
	},

	bindEvents: function() {
		$(".numclass").each(function(){
			$(this).click(function(){
				$('#enterNumId').val($(this).attr('value'));
			});
		});

		$(document).on('click', '#tiketButton', App.buyTicket);
		$(document).on('click', '#buyButton', App.playGame);
		$(document).on('click', '#showCodeButton', App.getInvestorCode);
	},

	buyTicket: function() {
		event.preventDefault();

		var amount = parseFloat($('#enterNumId').val());

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

					App.contracts.EthFuture.deployed().then(function (instance) {
						ethFutureInstance = instance;

						return ethFutureInstance.buyTToken({from: account, value: etherValue});
					}).then(function (result) {
						App.getBalance();
					}).catch(function (error) {
						alert("error");
					});
				} else {
					alert("自己不能向自己买Token");
				}
				
			});

		} else {
			alert("请输入正确的门票数量");
		}
	},

	// 投注
	playGame: function() {
		event.preventDefault();

		var code = App.getQueryVariable('code');
		if (code.length != 6) {
			alert("邀请码不对");
			return;
		}

		var amount = parseInt($('#enterNumId').val());

		if (amount >= 1) {
			if (ttBalance < (amount * 2000 / 10)) {
				alert("门票余额不足");
				return;
			}

			web3.eth.getAccounts(function(error, accounts) {
				if (error) {
					console.log(error);
					return;
				}

				var account = accounts[0];
				var etherValue = web3.toWei(amount, 'ether');

				App.contracts.EthFuture.deployed().then(function (instance) {
					return instance.investGame(code, {from: account, value: etherValue});
				}).then(function(result) {
					App.getEthBalance();
				}).catch(function(error) {
					alert("error");
				});

			});
		} else {
			alert("最少1个ether");
		}

	},

	// 获取合约账户的余额
	getEthBalance: function() {
		var ethFutureInstance;
		App.contracts.EthFuture.deployed().then(function (instance) {
			ethFutureInstance = instance;
			return ethFutureInstance.getContractBalanceOfEth();
		}).then(function (result) {
			result = result / 10 ** 18;
			$("#etherBalanceId").val(result + ' ether');
		}).catch(function (error) {
			alert(error);
		});
	},

	// 获取当前用户TT余额
	getTTokenBalace: function() {
		var ethFutureInstance;

		web3.eth.getAccounts(function (error, accounts) {
			if (error) {
				console.log(error);
			}

			var account = accounts[0];

			App.contracts.EthFuture.deployed().then(function (instance) {
				ethFutureInstance = instance;

				return ethFutureInstance.balanceOf(account);
			}).then(function (result) {
				ttBalance = result.c[0];
				console.log("TToken 余额：" + ttBalance);
			}).catch(function (err) {
				console.log(err.message);
			});
		});
	},

	// 获取用户的推荐码
	getInvestorCode: function() {
		var ethFutureInstance;
		App.contracts.EthFuture.deployed().then(function (instance) {
			ethFutureInstance = instance;
			return ethFutureInstance.getInvestorCode();
		}).then(function (result) {
			alert(result);
		}).catch(function (error) {
			alert(error);
		});
	},

	// 获取推荐人的邀请码
	getQueryVariable: function(variable) {
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable) {
				   return pair[1];
				}
		}
       return(false);
	}
};


$(function(){  
	$(window).on("load", function () {
		App.init();
	});
}); 
