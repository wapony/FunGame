

function segmentButtonClick(obj) {
    $(obj).siblings().attr('class', 'unselected');
    $(obj).attr('class', 'selected');

    var buttonId = $(obj).attr('id');
    
    if (buttonId == "imToken") {
        $('.content_imToken').css('display', 'inline');
        $('.content_trust').css('display', 'none');
    } else {
        $('.content_imToken').css('display', 'none');
        $('.content_trust').css('display', 'inline');
    }
}