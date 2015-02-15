// Generated by CoffeeScript 1.7.1
var Bilder,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Bilder = (function(_super) {
  __extends(Bilder, _super);

  function Bilder() {
    this.adjustPos = __bind(this.adjustPos, this);
    this.onLoad = __bind(this.onLoad, this);
    Bilder.__super__.constructor.call(this);
    this.catCount = 0;
    this.core = window.core;
    this.minImage = 0;
    this.maxImage = -1;
    this.currentLoadingIndex = 1;
    this.loadNumImageInBatch = 30;
    this.renderingAtCategory = {};
    this.renderingAtCategoryOffset = 0;
    this.core.requestFunction("ContentViewer.requestInstance", (function(_this) {
      return function(cView) {
        return _this.contentViewer = cView();
      };
    })(this));
    this.core.requestFunction("ImageViewer.requestInstance", (function(_this) {
      return function(imgView) {
        return _this.imageViewer = imgView();
      };
    })(this));
  }

  Bilder.prototype.notifyHashChange = function(newHash) {
    var cTitle, category, chapter, chapterID, counter, el, elem, id, image, inTitle, nextAttr, previousAttr, rightElem, rightPt, _i, _j, _len, _len1, _ref, _ref1;
    if (newHash.indexOf("/element/") === 0) {
      id = parseInt(newHash.substr(9, newHash.length));
      _ref = $("a");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        elem = _ref[_i];
        if (elem.getAttribute("href") === ("/#!/bilder" + newHash)) {
          el = $(elem);
          break;
        }
      }
      el.addClass("loading");
      this.core.ensureContentViewerClosed();
      if (window.ie) {
        this.imageViewer.open({
          imagesource: "/images/real/" + id,
          handleImageLoading: true,
          navigation: true,
          minImage: this.minImage,
          maxImage: this.maxImage,
          arrowKeys: true,
          getCurrentElement: function() {
            var h;
            h = location.hash;
            return parseInt(h.substr(h.lastIndexOf("/") + 1, h.length));
          },
          toLeftHash: function(currentEl) {
            return "#!/bilder/element/" + (currentEl - 1);
          },
          toRightHash: function(currentEl) {
            return "#!/bilder/element/" + (currentEl + 1);
          },
          escapeKey: true,
          lockScrolling: true,
          revertHash: "#!/bilder"
        });
      } else {
        image = $("<img>").attr("src", "/images/real/" + id).load((function(_this) {
          return function() {
            el.removeClass("loading");
            return _this.imageViewer.open({
              image: image,
              title: _this.id2title(id),
              positionInChapter: _this.posInChapter(id).toString(),
              chapterTotalLength: _this.chapterTotalLength(id).toString(),
              nextChapterScreen: true,
              chapterID: _this.id2chapID(id),
              chapterName: _this.chapterInfo(id),
              navigation: true,
              minImage: _this.minImage,
              maxImage: _this.maxImage,
              arrowKeys: true,
              getCurrentElement: function() {
                var h;
                h = location.hash;
                return parseInt(h.substr(h.lastIndexOf("/") + 1, h.length));
              },
              toLeftHash: function(currentEl) {
                return "#!/bilder/element/" + (currentEl - 1);
              },
              toRightHash: function(currentEl) {
                return "#!/bilder/element/" + (currentEl + 1);
              },
              escapeKey: true,
              lockScrolling: true,
              revertHash: "#!/bilder"
            });
          };
        })(this));
      }
      $("#arrow-container").removeClass("nodisplay");
      return;
    }
    if (newHash.indexOf("/kategorie/") === 0) {
      if (this.imageViewer.state === this.imageViewer.OPEN) {
        this.imageViewer.close();
      }
      rightElem = this.findRightMost();
      rightPt = rightElem.offset().left + rightElem.width();
      chapterID = newHash.substr(11, newHash.length);
      if (chapterID.indexOf("by-title/") === 0) {
        counter = 0;
        _ref1 = this.tree;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          category = _ref1[_j];
          cTitle = category.category.title.toLowerCase().replace(" ", "-");
          inTitle = chapterID.substr(9, chapterID.length).toLowerCase().replace(" ", "-");
          if (cTitle === inTitle) {
            break;
          }
          counter++;
        }
        chapterID = counter;
      }
      chapter = $(".img-chapter").eq(chapterID);
      if (chapterID !== 0) {
        $(".arrleft").removeClass("arrow-inactive");
        previousAttr = chapter.prev().attr("href");
        if (previousAttr) {
          $(".arrleft").attr("href", previousAttr.substring(1));
        }
      } else {
        $(".arrleft").addClass("arrow-inactive");
      }
      if (chapterID !== this.catCount) {
        $(".arrleft").removeClass("arrow-inactive");
        nextAttr = chapter.next().attr("href");
        if (nextAttr) {
          $(".arrright").attr("href", nextAttr.substring(1));
        }
      } else {
        $("arrleft").addClass("arrow-inactive");
      }
      this.contentViewer.open({
        left: function() {
          return chapter.offset().left;
        },
        top: function() {
          return chapter.offset().top;
        },
        width: function() {
          return chapter.width() * 2;
        },
        height: function() {
          return "100%";
        },
        bgColor: "#4B77BE",
        scrollTo: chapter,
        scrollToCallback: function() {
          return $("body").trigger("scroll");
        },
        title: this.tree[chapterID].category.title,
        caption: this.tree[chapterID].category.caption,
        revertHash: "#!/bilder",
        content: this.tree[chapterID].category.content,
        animate: false
      });
      return $("#arrow-container").removeClass("nodisplay");
    }
  };

  Bilder.prototype.id2title = function(id) {
    var category, imgpair, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.tree;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      _ref1 = category.category.childs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        imgpair = _ref1[_j];
        if (imgpair[0] === id) {
          return imgpair[1];
        }
      }
    }
  };

  Bilder.prototype.id2chapID = function(id) {
    var category, counter, imgpair, _i, _j, _len, _len1, _ref, _ref1;
    counter = 0;
    _ref = this.tree;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      _ref1 = category.category.childs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        imgpair = _ref1[_j];
        if (imgpair[0] === id) {
          return counter;
        }
      }
      counter++;
    }
  };

  Bilder.prototype.posInChapter = function(id) {
    var category, counter, imgpair, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.tree;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      counter = 0;
      _ref1 = category.category.childs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        imgpair = _ref1[_j];
        if (imgpair[0] === id) {
          return counter + 1;
        }
        counter++;
      }
    }
  };

  Bilder.prototype.chapterTotalLength = function(id) {
    var category, imgpair, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.tree;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      _ref1 = category.category.childs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        imgpair = _ref1[_j];
        if (imgpair[0] === id) {
          return category.category.childs.length;
        }
      }
    }
  };

  Bilder.prototype.chapterInfo = function(id) {
    var category, imgpair, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.tree;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      category = _ref[_i];
      _ref1 = category.category.childs;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        imgpair = _ref1[_j];
        if (imgpair[0] === id) {
          return [category.category.title, category.category.caption, category.category.content];
        }
      }
    }
  };

  Bilder.prototype.acquireLoadingLock = function() {
    return true;
  };

  Bilder.prototype.onLoad = function() {
    window.core.setMetaDesc("Bilder von Auftritten, Konzertreisen und mehr.", "Bilder");
    $(window).on("scroll", (function(_this) {
      return function() {
        var curMaxHeight, curScrPos, error, i, _i, _ref, _ref1, _results;
        try {
          curMaxHeight = $(".img-image").eq(_this.currentLoadingIndex * _this.loadNumImageInBatch).offset().top;
        } catch (_error) {
          error = _error;
          $(window).off("scroll");
          return;
        }
        curScrPos = $(window).scrollTop() + $(window).height() - 200;
        if (curScrPos / curMaxHeight >= 0.7) {
          _this.currentLoadingIndex++;
          _results = [];
          for (i = _i = _ref = (_this.currentLoadingIndex - 1) * _this.loadNumImageInBatch, _ref1 = _this.currentLoadingIndex * _this.loadNumImageInBatch; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
            _results.push($(".img-image").eq(i).children("img").attr("src", "/images/thumbs/" + i));
          }
          return _results;
        }
      };
    })(this));
    return $.ajax({
      url: "/data/json/bilder.json"
    }).done((function(_this) {
      return function(tree) {
        var c, imgptr, _i, _j, _len, _len1, _ref;
        _this.tree = tree;
        for (_i = 0, _len = tree.length; _i < _len; _i++) {
          c = tree[_i];
          _this.genCat(c.category.title, c.category.caption, c.category.content);
          _ref = c.category.childs;
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            imgptr = _ref[_j];
            _this.genImg(!(_this.renderingAtCategoryOffset >= _this.loadNumImageInBatch), imgptr[0], imgptr[1]);
            _this.maxImage++;
            _this.renderingAtCategoryOffset++;
          }
          _this.renderingAtCategory++;
        }
        return _this.c.release();
      };
    })(this));
  };

  Bilder.prototype.onDOMVisible = function() {
    this.adjustPos();
    $(window).on("resize", this.adjustPos);
    return $("body").on("keydown", (function(_this) {
      return function(ev) {
        if ($("#arrow-container").hasClass("nodisplay")) {
          return;
        }
        if (ev.keyCode === 37) {
          if (!$(".content-viewer").hasClass("nodisplay")) {
            _this.contentViewer.close(-1);
          }
          return location.hash = $(".arrleft").attr("href");
        } else if (ev.keyCode === 39) {
          if (!$(".content-viewer").hasClass("nodisplay")) {
            _this.contentViewer.close(-1);
          }
          return location.hash = $(".arrright").attr("href");
        }
      };
    })(this));
  };

  Bilder.prototype.onUnloadChild = function() {
    window.core.revMetaDesc();
    $(window).off("resize", this.adjustPos);
    $(".image-viewer").addClass("nodisplay");
    $("#image-viewer-exit-button").addClass("nodisplay");
    return $("body").off("keydown");
  };

  Bilder.prototype.adjustPos = function() {
    var distanceFromLeft, horizonalAxisElm, onHorizontalAxis, sels, totalWidth, vertAxis, width;
    width = $(window).width();
    sels = $(".image-container").children();
    vertAxis = width / 2;
    onHorizontalAxis = true;
    horizonalAxisElm = 1;
    while (onHorizontalAxis) {
      if (sels.eq(horizonalAxisElm - 1).offset().top === sels.eq(horizonalAxisElm).offset().top) {
        horizonalAxisElm++;
      } else {
        onHorizontalAxis = false;
      }
    }
    totalWidth = (sels.eq(0).width() * horizonalAxisElm) + (4 * horizonalAxisElm);
    distanceFromLeft = vertAxis - (totalWidth / 2);
    return $(".image-container").css({
      "padding-left": distanceFromLeft
    });
  };

  Bilder.prototype.findRightMost = function() {
    var error, firstOffset, leftIndex;
    try {
      firstOffset = $(".img-image").first().offset().top;
      leftIndex = -1;
      $(".img-image").each((function(_this) {
        return function(index, obj) {
          var $obj;
          $obj = $(obj);
          if ($obj.offset().top !== firstOffset) {
            leftIndex = index - 1;
            return false;
          }
        };
      })(this));
      if (leftIndex !== -1) {
        return $(".img-image").eq(leftIndex);
      }
      return false;
    } catch (_error) {
      error = _error;
      return false;
    }
  };

  Bilder.prototype.genCat = function(title, caption, content) {
    $(".image-container").append($("<a>").addClass("img-chapter").attr("href", "/#!/bilder/kategorie/" + this.catCount).append($("<h2>" + title + "</h2>").append($("<span>" + caption + "</span>"))));
    return this.catCount++;
  };

  Bilder.prototype.genImg = function(attachImg, filePtr, caption) {
    if (attachImg) {
      return $(".image-container").append($("<a>").addClass("img-image").attr("href", "/#!/bilder/element/" + filePtr).append($("<img>").attr("src", "/images/thumbs/" + filePtr)).append($("<span>" + caption + "</span>")));
    } else {
      return $(".image-container").append($("<a>").addClass("img-image").attr("href", "/#!/bilder/element/" + filePtr).append($("<img>")).append($("<span>" + caption + "</span>")));
    }
  };

  return Bilder;

})(ChildPage);

window.core.insertChildPage(new Bilder());
