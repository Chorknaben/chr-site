// Generated by CoffeeScript 1.7.1
var Stiftung,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Stiftung = (function(_super) {
  __extends(Stiftung, _super);

  function Stiftung() {
    Stiftung.__super__.constructor.call(this);
    this.buttonStiftung = $("#btn-stiftung");
    this.buttonForderverein = $("#btn-forderverein");
    this.contents = [$("#ziele-und-zweck"), $("#missa-1962"), $("#zustiften"), $("#kontaktieren")];
    this.contentsf = [$("#fziele"), $("#mitgliedsein"), $("#spenden"), $("#fkontaktieren")];
    this.nav = $(".stiftung-subnav").children();
  }

  Stiftung.prototype.onLoad = function() {
    return window.core.setMetaDesc("Die Stiftung St.-Martins-Chorknaben Biberach wurde im April 2010 gegr&uuml;ndet und hat das Ziel, die Finanzierung von Chorleitung und Stimmbildung nachhaltig zu sichern.", "Stiftung");
  };

  Stiftung.prototype.nodisplay = function() {
    var i, _i, _len, _ref, _results;
    _ref = this.contents;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.addClass("nodisplay"));
    }
    return _results;
  };

  Stiftung.prototype.fnodisplay = function() {
    var i, _i, _len, _ref, _results;
    _ref = this.contentsf;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.addClass("nodisplay"));
    }
    return _results;
  };

  Stiftung.prototype.setAreaCol = function(col) {
    var stiftungMainArea;
    stiftungMainArea = $("#cnt-stiftung");
    stiftungMainArea.removeClass().addClass("stiftung-main-area");
    return stiftungMainArea.addClass(col);
  };

  Stiftung.prototype.fSetAreaCol = function(col) {
    var fordervereinMainArea;
    fordervereinMainArea = $("#cnt-forderverein");
    fordervereinMainArea.removeClass().addClass("stiftung-main-area");
    return fordervereinMainArea.addClass(col);
  };

  Stiftung.prototype.onUnloadChild = function() {
    return window.core.revMetaDesc();
  };

  Stiftung.prototype.notifyHashChange = function(newHash) {
    if (newHash === "/" || newHash === "") {
      this.buttonStiftung.addClass("active");
      this.buttonForderverein.removeClass("activef");
      $(".stiftung-main-area").eq(1).addClass("nodisplay");
      $(".stiftung-main-area").eq(0).removeClass("nodisplay");
    }
    if (newHash === "/ziele") {
      this.nodisplay();
      this.setAreaCol("li-1");
      this.contents[0].removeClass("nodisplay");
    }
    if (newHash === "/missa") {
      this.nodisplay();
      this.setAreaCol("li-2");
      this.contents[1].removeClass("nodisplay");
    }
    if (newHash === "/zustiften") {
      this.nodisplay();
      this.setAreaCol("li-3");
      this.contents[2].removeClass("nodisplay");
    }
    if (newHash === "/kontaktieren") {
      this.nodisplay();
      this.setAreaCol("li-4");
      this.contents[3].removeClass("nodisplay");
    }
    if (newHash.indexOf("/forderverein") === 0) {
      this.buttonStiftung.removeClass("active");
      this.buttonForderverein.addClass("activef");
      $("#cnt-stiftung").addClass("nodisplay");
      $("#cnt-forderverein").removeClass("nodisplay");
      this.fnodisplay();
      this.fSetAreaCol("fi-1");
      this.contentsf[0].removeClass("nodisplay");
    }
    if (newHash === "/forderverein/ziele") {
      this.fnodisplay();
      this.fSetAreaCol("fi-1");
      this.contentsf[0].removeClass("nodisplay");
    }
    if (newHash === "/forderverein/mitglied-sein") {
      this.fnodisplay();
      this.fSetAreaCol("fi-2");
      this.contentsf[1].removeClass("nodisplay");
    }
    if (newHash === "/forderverein/spenden") {
      this.fnodisplay();
      this.fSetAreaCol("fi-3");
      this.contentsf[2].removeClass("nodisplay");
    }
    if (newHash === "/forderverein/kontaktieren") {
      this.fnodisplay();
      this.fSetAreaCol("fi-4");
      return this.contentsf[3].removeClass("nodisplay");
    }
  };

  return Stiftung;

})(ChildPage);

window.core.insertChildPage(new Stiftung());
