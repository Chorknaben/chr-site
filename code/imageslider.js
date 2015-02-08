function ImageSlider(el, options){
	// TODO multiple input possibilities here
	// querySelector, byID, jQuery(), etc.
	this.el = el;
	this.viewingIndex = 0;
	this.direction = "left"
	if (options){
		this.opt = options;
	} else {
		this.opt = {
			src: [],	
			interval: 3000
			// src: document.querySelector("#ul-images"),	
		};
	}

	el.style.overflow = "hidden"
}

ImageSlider.rebuild = function(el,src,callback){
	var imgNode = document.createElement("img");
	imgNode.onload = function(){
		if (el.childNodes.length > 1){
			el.firstChild.style.left = "-" + el.offsetWidth + "px";
			el.firstChild.classList.remove("active");
			el.firstChild.addEventListener("transitionend", function(){
				this.parentNode.removeChild(this);
			},false)
		}
		callback();
	}
	imgNode.setAttribute("class", "imageslider-img active");
	imgNode.style.left = el.offsetWidth + "px"
	imgNode.setAttribute("src", src);
	el.appendChild(imgNode);
}

// Setter for this.opt.src
ImageSlider.prototype.addImage = function(imgSrc){
	this.opt.src.push(imgSrc);
}

// Getter for Options
ImageSlider.prototype.getOptions = function(){
	return this.opt;
}

// Setter for Options
ImageSlider.prototype.setOptions = function(optDict){
	this.opt = optDict;
}

ImageSlider.prototype.start = function(){
	this.loadNext();
	this.interval = setInterval((function(_this){
		return function(){
			_this.loadNext();
		}
	})(this), this.opt.interval);
}

ImageSlider.prototype.stop = function(){
	window.clearInterval(this.interval);
}

ImageSlider.prototype.loadNext = function(fileName){
	// fileName is a optional argument, use src if not supplied
	if (fileName === undefined){
		nextElement = this.opt.src[this.viewingIndex];
		ImageSlider.rebuild(this.el, nextElement, (function(_el){
			return function(){
				// Fade Image in
				document.querySelectorAll(".active")[0].style.left = "0px";
			}
		})(this.el));
		this.viewingIndex++;
		if (this.viewingIndex > this.opt.src.length - 1){
			this.viewingIndex = 0;
		}
	} else {
	}
}

ImageSlider.prototype.chooseNewDirection = function(){
	// TODO
}