$(function(){ 
	//封装查询数据todo
    $("#target").val("www.baidu.com");
    copy()
}); 

function segmentButtonClick(obj) {
    $(obj).siblings().attr('class', 'unselected');
    $(obj).attr('class', 'selected');

    var objId = $(obj).attr('id');

    if (objId == "urlShareButton") {
        $(".content_urlShare").css("display", "inline");
        $(".content_myShare").css("display", "none");
        $(".content_community").css("display", "none");
    } else if (objId == "myShareButton") {
        $(".content_urlShare").css("display", "none");
        $(".content_myShare").css("display", "inline");
        $(".content_community").css("display", "none");
    } else {
        $(".content_urlShare").css("display", "none");
        $(".content_myShare").css("display", "none");
        $(".content_community").css("display", "inline");
    }
}

function copy() {
    var clipboard = new ClipboardJS("#copyButton", {
        text : function() {
            return $("#myInviteUrl").val();
        }
    });

    clipboard.on('success',function(e){
        $('#show').slideDown().delay(1500).slideUp(300);
        console.log(e);
    });

    clipboard.on('error',function(e){
        $('#show').slideDown().delay(1500).slideUp(300);
        console.log(e);
    });

}   