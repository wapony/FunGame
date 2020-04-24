$(function(){ 
	//封装查询数据todo
    $("#target").val("www.baidu.com");
    copy();
    showShareInfo();
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

function showShareInfo() {
    var tab = document.getElementById('table_shareInfo');
    var tradd = tab.insertRow(1);
    tradd.innerHTML='<td>1</td><td>sdng06</td><td>11.000</td>'; 
    
    tradd = tab.insertRow(2);
    tradd.innerHTML = '<td>2</td><td>sdng07</td><td>12.000</td>';

    tradd = tab.insertRow(3);
    tradd.innerHTML = '<td>3</td><td>sdng08</td><td>13.000</td>';

}