// Generated by CoffeeScript 1.7.1
var UberunsTimeline,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

UberunsTimeline = (function(_super) {
  __extends(UberunsTimeline, _super);

  function UberunsTimeline() {
    this.core = window.core;
  }

  UberunsTimeline.prototype.onLoad = function() {};

  UberunsTimeline.prototype.onUnloadChild = function() {};

  UberunsTimeline.prototype.notifyHashChange = function(newHash) {};

  return UberunsTimeline;

})(ChildPage);

window.core.insertChildPage(new UberunsTimeline());
