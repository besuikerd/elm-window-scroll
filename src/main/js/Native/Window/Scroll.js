var _besuikerd$elm_window_scroll$Native_Window_Scroll = (function() {
  var offset = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
    callback(_elm_lang$core$Native_Scheduler.succeed({
      x: window.pageXOffset || document.documentElement.scrollLeft,
      y: window.pageYOffset || document.documentElement.scrollTop
    }))
  });

  return {
    offset: offset
  }
})();
