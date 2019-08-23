
$(window).ready(function() {
    $("img.lazy").lazyload( {container: $("#container")} );
});

/// 触发container div的滚动事件
function notifyScrollEvent(scrollOffset) {
    $("#container").css("top", scrollOffset);
    $("#container").trigger("scroll");
}
