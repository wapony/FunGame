
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
    },

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
};

$(function() { 
	$(window).on("load", function() {
		Page.init();
	});
}); 