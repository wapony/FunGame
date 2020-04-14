$(function(){ 
	//封装查询数据todo
    var mydata={basenum1:"123",basenum2:236,basenum3:236,basenum4:236,basenum5:236,basenum6:236,basenum7:236,basenum8:236,basenum9:236,basenum10:236,basenum11:236,basenum12:236,basenum13:236};
	showData(mydata);
	getoutETH();
}); 

function showData(mydata){
	$("#id1").val(mydata.basenum1);
    $("#id2").val(mydata.basenum2);
	$("#id3").val(mydata.basenum3);
    $("#id4").val(mydata.basenum4);
	$("#id5").val(mydata.basenum5);
    $("#id6").val(mydata.basenum6);
	$("#id7").val(mydata.basenum7);
    $("#id8").val(mydata.basenum8);
	$("#id9").val(mydata.basenum9);
    $("#id10").val(mydata.basenum10);
	$("#id11").val(mydata.basenum11);
    $("#id12").val(mydata.basenum12);
	$("#id13").val(mydata.basenum13);
    
}
function getoutETH(){
	//数量
	var num=$("#id13").val();
	//密码
	
	//按钮点击事件
	$("#getethButton").click(function(){
		//调用接口todo
		var pwd =$("#pwdId").val();
		alert(pwd);
	});
	
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
