$(function(){ 
	//封装查询数据todo
    $("#target").val("www.baidu.com");
    copy()
}); 

function segmentButtonClick(obj) {
    $(obj).siblings().attr('class', 'unselected');
    
    $(obj).attr('class', 'selected');
}

function copy(){

    var clipboard = new ClipboardJS("#copyButton",{
        text : function(){
            
            return $("#myInviteUrl").val();
        }
    });

    clipboard.on('success',function(e){
        console.log(e);
    });

    clipboard.on('error',function(e){
        console.log(e);
    });

}   