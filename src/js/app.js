const App = {
  web3Provider: null,
  contracts: {},

  init: function () {
    return App.initWeb3();
  },

  initWeb3: function () {
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        window.ethereum.enable();
      } catch (error) {
        console.error("user denied account access");
      }
    } else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function () {
    $.getJSON('EthFutureControl.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var ethFutureArtifact = data;
      App.contracts.EthFuture = TruffleContract(ethFutureArtifact);

      // Set the provider for our contract.
      App.contracts.EthFuture.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.getBalances();
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '#transferButton', App.handleTransfer);
    $(document).on('click', '#tiketButton', App.handleBuyTicket);
    $(document).on('click', '#buyButton', App.handlePlay);
  },

  handleTransfer: function (event) {
    // event.preventDefault();
    
    // var amount = parseInt($('#TTTransferAmount').val());
    // var toAddress = $('#TTTransferAddress').val();

    // console.log('Transfer ' + amount + ' TT to ' + toAddress);

    // var ethFutureInstance;

    // web3.eth.getAccounts(function (error, accounts) {
    //   if (error) {
    //     console.log(error);
    //   }

    //   var account = accounts[0];

    //   App.contracts.EthFuture.deployed().then(function (instance) {
    //     ethFutureInstance = instance;

    //     return ethFutureInstance.transfer(toAddress, amount, { from: account, gas: 100000 });
    //   }).then(function (result) {
    //     alert('Transfer Successful!');
    //     return App.getBalances();
    //   }).catch(function (err) {
    //     console.log(err.message);
    //   });
    // });

    window.location.href = "main.html";
  },

  //点击事件--购买门票
  handleBuyTicket: function (event) {
    // event.preventDefault();
    
    // var ethnum = parseInt($('#ethnumberId').val());
    // console.log('Transfer ' + ethnum );

    // var ethFutureInstance;

    // web3.eth.getAccounts(function (error, accounts) {
    //   if (error) {
    //     console.log(error);
    //   }

    //   var account = accounts[0];
    //   var ethValue = web3.toWei(1, "ether");
      
    //   App.contracts.EthFuture.deployed().then(function(instance) {
    //     ethFutureInstance = instance;

    //     return ethFutureInstance.buyTToken({from: account, value: ethValue});
    //   }).then(function(result) {
    //     console.log("buyTToken result = " + result);
    //   }).catch(function(error) {
    //     console.error(error);
    //   });

    // });

    window.location.href = "buyTicket.html";
    
  },

  // 投注事件-- 暂时写的是获取合约账户eth余额的逻辑
  handlePlay: function(event) {
    event.preventDefault();

    var ethFutureInstance;

    App.contracts.EthFuture.deployed().then(function(instance) {
      ethFutureInstance = instance;

      return ethFutureInstance.getContractBalanceOfEth();
    }).then(function(result) {
      var result = result / 10 ** 18;
      console.log("balance =" + result);
    }).catch(function(error) {
      console.log(error.message);
    });
  },

  getBalances: function () {
    console.log('Getting balances...');

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
        balance = result.c[0];

        $('#TTBalance').text(balance);
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  }

};

$(function () {
  $(window).on("load", function () {
    App.init();

  });
});

