
const Page = {
	web3Provider: null,
	contracts: {},

	init: function() {
		Page.web3Provider = App.web3Provider;
		Page.contracts = App.contracts;
	},

	// initWeb3: function() {
	// 	if (window.ethereum) {
	// 		App.web3Provider = window.ethereum;

	// 		try {
	// 			window.ethereum.enable();
	// 		} catch (error) {
	// 			console.error("user denied account access");
	// 		}
	// 	} else if (window.web3) {
	// 		App.web3Provider = window.web3.currentProvider;
	// 	} else {
	// 		App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:8545');
	// 	}

	// 	web3 = new Web3(App.web3Provider);

	// 	return App.initContract();
	// },
};






$(function() { 
	$(window).on("load", function() {
		Page.init();
	});
}); 





