App = {
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
      var EthFutureControlArtifact = data;
      App.contracts.EthFutureControl = TruffleContract(EthFutureControlArtifact);

      // Set the provider for our contract.
      App.contracts.EthFutureControl.setProvider(App.web3Provider);

      // Use our contract to retieve and mark the adopted pets.
      return App.getBalances();
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '#transferButton', App.handleTransfer);
  },

  bindEvents: function () {
    $(document).on('click', '#tiketButton', App.handleBuyTicket);
  },

  handleTransfer: function (event) {
    event.preventDefault();
    
    var amount = parseInt($('#TTTransferAmount').val());
    var toAddress = $('#TTTransferAddress').val();

    console.log('Transfer ' + amount + ' TT to ' + toAddress);

    var ethFutureControlInstance;

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.EthFutureControl.deployed().then(function (instance) {
        ethFutureControlInstance = instance;

        return ethFutureControlInstance.transfer(toAddress, amount, { from: account, gas: 100000 });
      }).then(function (result) {
        alert('Transfer Successful!');
        return App.getBalances();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },

//点击事件--购买门票
  handleBuyTicket: function (event) {
    event.preventDefault();
    
    var ethnum = parseInt($('#ethnumberId').val());

    console.log('Transfer ' + ethnum );
    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      console.log(account);
    });
    var abi = [{"constant":false,"inputs":[{"name":"receiver","type":"address"},{"name":"amount","type":"uint256"}],"name":"sendCoin","outputs":[{"name":"sufficient","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"addr","type":"address"}],"name":"getBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"}];
// 合约地址
var address = "0x73191C282Ae3D6D545A230D1B0232448e821DcBA";
// 通过ABI和地址获取已部署的合约对象
var myContact = web3.eth.contract(abi).at(address);
console.info("合约"+myContact);
var names="";       
        for(var name in myContact){       
           names+=name+": "+myContact[name]+", ";  
        }  
        alert(names);
//myContact.buyTToken();
  },

  getBalances: function () {
    console.log('Getting balances...');

    var ethFutureControlInstance;

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.EthFutureControl.deployed().then(function (instance) {
        ethFutureControlInstance = instance;

        return ethFutureControlInstance.balanceOf(account);
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
