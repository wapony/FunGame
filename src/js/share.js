$(function(){ 
	//封装查询数据todo
	$("#target").val("www.baidu.com");
    copy();
}); 

function copy(){
	
		
		var clipboard = new ClipboardJS("#copyButton",{
        text : function(){
            //寻找被激活的那个div pre元素,同时获取它下面的内容
            return $("#target").val();
        }
    });

    clipboard.on('success',function(e){
        console.log(e);
    });

    clipboard.on('error',function(e){
        console.log(e);
    });
		
		
		
		

};