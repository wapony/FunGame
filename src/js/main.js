$(function(){  
	//$('.numclass').click(function(){
	$(".numclass").each(function(){
		$(this).click(function(){
			//console.error("11111:"+$(this).attr("value"));
			$('#enterNumId').val($(this).attr('value'));
		});
		
	});
    
}); 

