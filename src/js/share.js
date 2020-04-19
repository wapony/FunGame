$(function(){ 
	//封装查询数据todo
	$("#target").val("www.baidu.com");
    copy();
}); 

function copy(){
	
		
		var clipboard = new ClipboardJS("#copyButton",{
        text : function(){
            
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