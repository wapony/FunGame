App = {
	web3Provider: null,
	contracts: {},

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

			App.getBalance();
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
	},

	buyTicket: function() {
		event.preventDefault();

		var amount = parseFloat($('#enterNumId').val());

		if (amount > 0) {
			var ethFutureInstance;

			web3.eth.getAccounts(function (error, accounts) {
				if (error) {
					console.log(error);
				}

				var account = accounts[0];

				if (account != 0x50123591FA642778682F092Ec269AB2bBDC41a08) {
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

	playGame: function() {

	},

	getBalance: function() {
		App.contracts.EthFuture.deployed().then(function (instance) {
			return instance.getContractBalanceOfEth();
		}).then(function (result) {
			result = result / 10 ** 18;
			$("#etherBalanceId").val(result + ' ether');
		}).catch(function (error) {
			alert(error);
		});
	}
};


$(function(){  
	$(window).on("load", function () {
		App.init();
	});
}); 

