$(function(){ 
	//封装查询数据todo
    $("#target").val("www.baidu.com");
}); 

function segmentButtonClick(obj) {
    $(obj).siblings().attr('class', 'unselected');
    
    $(obj).attr('class', 'selected');
}