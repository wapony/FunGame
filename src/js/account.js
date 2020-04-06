$(function(){  
$('.pop_main').hide();
    var param = { name: 'CodePlayer', age: 18 ,kk:'abc'};
	//getEthButtonClick(param);
}); 

function getEthButtonClick(param){
    $("#getEthButton").click( param,function(event){
        //以太坊逻辑
		var ethNumner = $("#ethnumberId").val();
		
		$('.pop_main').show()
            //设置animate动画初始值
            $('.pop_con').css({'top':0,'opacity':0})
            $('.pop_con').animate({'top':'50%','opacity':1})
		
    } );
}


function getOutEthButtonClick(param){
    $("#getEthButton").click( param,function(event){
        //以太坊逻辑
		var ethNumner = $("#ethnumberId").val();
		
		$('.pop_main').show()
            //设置animate动画初始值
            $('.pop_con').css({'top':0,'opacity':0})
            $('.pop_con').animate({'top':'50%','opacity':1})
		
    } );
}



function ShowDiv(show_div, bg_div) {
            document.getElementById(show_div).style.display = 'block';
            document.getElementById(bg_div).style.display = 'block';
            var bgdiv = document.getElementById(bg_div);
            bgdiv.style.width = document.body.scrollWidth;
            // bgdiv.style.height = $(document).height();
            $("#" + bg_div).height($(document).height());
        };
        //关闭弹出层
        function CloseDiv(show_div, bg_div) {
            document.getElementById(show_div).style.display = 'none';
            document.getElementById(bg_div).style.display = 'none';
        };
