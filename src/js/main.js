const App = {
	web3Provider: null,
	contracts: {},
	ttBalance: 0,	// ttoken余额

	// address: 

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
			// App.web3Provider = new Web3.providers.HttpProvider("http://39.108.122.77:8545");
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

			// 累计投币
			App.getTotalAmount();
		});

		App.bindEvents();
		App.topTen();
	},

	bindEvents: function() {
		$(".div-inline1").each(function(){
			$(this).click(function(){
				$('#enterNumId').val($(this).attr('value'));
			});
		});

		$(document).on('click', '#tiketButton', App.buyTicket);
		$(document).on('click', '#buyButton', App.playGame);
	},

	buyTicket: function() {
		window.location.href="./buyTicket.html";
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
					var param={
						"account":account,
						"code":"568",
						"pid":"1",
						"voteinfo":"123",
						"fcode":"666",
						"votetimes":"222"
					}


					$('body').dialog({type:'success',
									title:'操作成功',
									buttons:[{name: '确定',className: 'defalut'}],
									discription:'优秀'},
									function(ret){
						window.location.reload();
					});


				}).catch(function(error) {
					alert(error);
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

	// 获取当前用户累计投币量
	getTotalAmount: function() {
		var ethFutureInstance;

		web3.eth.getAccounts(function(error, accounts) {
			if (error) {
				console.log(error);
			}

			var account = accounts[0];

			App.contracts.EthFuture.deployed().then(function(instance) {
				ethFutureInstance = instance;

				return ethFutureInstance.getOwnerTotalAmount({from:account});
			}).then(function(result) {
				var amount = result.c[0] / 10**4;
				amount = amount.toFixed(2);
				$("#etherBalanceId").html(amount);
			}).catch(function(error) {
				console.log(error.message);
			});
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
				$("#ewBalance").html(ttBalance);
			}).catch(function (err) {
				console.log(err.message);
			});
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
	},

	/** 
	 * 获取当前用户所有子节点的数量
	 */
	getSonNodesCount: function() {
		web3.eth.getAccounts(function (error, accounts) {
			var account = accounts[0];

			App.contracts.EthFuture.deployed().then(function (instance) {
				return instance.getSonNodesCount({from: accounts});
			}).then(function(result) {
				alert("直推人数= " + result);
			}).catch(function(error) {
				alert(error);
			});
		});
	},

	/**
	 * 销毁合约把合约账户余额转移到拥有者账户
	 */
	killEveryone: function() {
		web3.eth.getAccounts(function(error, accounts) {
			var account = accounts[0];

			App.contracts.EthFuture.deployed().then(function(instance) {
				instance.destroyContract();
			}).catch(function(error) {
				alert(error);
			});
		});
	},

	// 获取排名前10的用户
	topTen: function() {
		$.ajax({
				//请求方式
				type : "GET",
				//请求地址
				url : "http://39.108.122.77/v1/topTen",
				//请求成功
				success : function(result) {
					console.log("topTen===="+JSON.stringify(result));
					var length=result.data.length;
					for(i=length;i>0;i--){
						
						console.error("topTen===="+i);
						$("#tb_title").after('<tr><th>'+(i)+'</th><th>'+result.data[i-1].code+'</th><th>'+result.data[i-1].cnum+'</th></tr>');
					}
					
					
				},
				//请求失败，包含具体的错误信息
				error : function(e){
					console.log(e.status);
					console.log(e.responseText);
				}
			});
	},

	// 插入投资数据
 	vote: function(param) {
		$.ajax({
				//请求方式
				type : "POST",
				//请求的媒体类型
	
				//请求地址
				url : "http://39.108.122.77/v1/user",
				//数据，json字符串
				data : JSON.stringify(param),
				contentType:"application/json;charset=utf-8",
				//请求成功
				success : function(result) {
					 console.log("vote===="+JSON.stringify(result));
				},
				//请求失败，包含具体的错误信息
				error : function(e){
					console.log(e.status);
					console.log(e.responseText);
				}
			});
	}
};


$(function(){  
	$(window).on("load", function () {
		App.init();
	});
}); 

export {App};
