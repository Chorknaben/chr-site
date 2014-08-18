// Overflow Text in other container when there's not enough space in this one.
(function($){
	$.fn.overflowTo = function(target){
		var childHeight = this.children("p").height();
		var childWidth  = this.children("p").width();
		var cntHeight = this.height();
		var cntWidth = this.width();
		if (childHeight > cntHeight){
			var mainText = this.children("p").html();
			var lastIndex = mainText.lastIndexOf(" ");
			var newMainText = mainText.substring(0,lastIndex);
			var lastWord = mainText.substring(lastIndex, mainText.length);

			this.children("p").html(
					newMainText
				)
			$(target).children("p").html(
				lastWord + " " + $(target).children("p").html()
				);
			this.overflowTo(target);
		}
		if ($(target).children("p").height() > $(target).height()){
			return false;
		}
		return true;
	}

})(jQuery);