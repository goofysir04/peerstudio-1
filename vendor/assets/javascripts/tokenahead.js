/* Thanks to https://gist.github.com/4354488 */

!function ($) {
 
  "use strict"; // jshint ;_;
 
 
 /* TOKENAHEAD PUBLIC CLASS DEFINITION
  * ================================== */
 
  var Tokenahead = function (element, options) {
    this.$wrapper = $(element)
    this.$measurer = $('.measurer', this.$wrapper)
    this.$tokens = $('.tokens', this.$wrapper)
    this.$originalInput = $('input', this.$wrapper)
    this.$clonedInput = $('input', this.$wrapper).clone().appendTo(this.$wrapper).attr('id','fake-input').attr('name','fake-input').val('')
    this.$originalInput.hide()
    $.fn.typeahead.Constructor.call(this, this.$clonedInput, options)
    var that = this;
    $(that.$originalInput.val().split(",")).each(function() {
      if (this.length > 0) {
        that.addToken(this);
      }
    });
    if(that.$tokens.children().length!=0){
      that.$element.attr("placeholder", "");
      that.$element.css("width","30")
    }
  }
 
  Tokenahead.prototype = $.extend({}, $.fn.typeahead.Constructor.prototype, {
 
    constructor: Tokenahead
 
  , updater: function (item) {
      this.addToken(item)
      return ''
    }
 
  , addToken: function (item) {
      var token = $(this.options.token)
        , text = $('<span></span>').text(item).appendTo(token)
      token.appendTo(this.$tokens)
      var tokenValue = $("span", this.$tokens).not(".close").map(function() {
    return $(this).text();
    }).get();
      this.$originalInput.val(tokenValue)
    }
 
  , listen: function () {
      var that = this
    if(that.$element.val() || that.$tokens.children().length!=0){
      that.$element.attr("placeholder", "");
      that.$element.css("width","30")
    }
      $.fn.typeahead.Constructor.prototype.listen.call(this)
 
      this.$wrapper
        .on('click', 'a', function (e) {
          e.stopPropagation()
        })
        .on('click', '.close', function (e) {
          $(this).parent().remove()
        var tokenValue = $("span", that.$tokens).not(".close").map(function() {
      return $(this).text();
      }).get();
      that.$originalInput.val(tokenValue)
          that.$element.focus()
        })
        .on('click', function () {
          that.$element.focus()
        })
 
      this.$element
        .on('focus', function (e) {
          that.$wrapper.addClass('focus');
          that.$element.attr("placeholder", "");
          if (!that.$element.val()) return that.isEmpty = true
        })
        .on('blur', function (e) {
          var value = that.$element.val();
          that.$wrapper.removeClass('focus')
          that.$element
              .val('')
              .change()
            
          if(value.charAt(value.length-1) === ","){
            that.addToken(value.substring(0, value.length-1))
          }else if (value.length > 0) {
            that.addToken(value)
          }
        })
        .on('keyup', function (e) {
          var tokens
            , value
 
          if ((e.keyCode == 188 || e.keyCode == 13 )&& that.$element.val() != ',' && !that.shown && (value = that.$element.val())) { //enter with no menu and val
            that.$element
              .val('')
              .change()
            
            if(value.charAt(value.length-1) === ","){
              that.addToken(value.substring(0, value.length-1))
            }else{
              that.addToken(value)
            }
            return that.$element.focus()
          }
 
          if (e.keyCode != 8 || that.$element.val()) return that.isEmpty = false//backspace
          if (!that.isEmpty) return that.isEmpty = true
          tokens = $('a', that.$tokens)
          if (!tokens.length) return
          tokens.last().remove()
          
          var tokenValue = $("span", that.$tokens).not(".close").map(function() {
      return $(this).text();
      }).get();
      that.$originalInput.val(tokenValue)
        })
        .on('keypress keydown paste', function (e) {
          if(e.keyCode == 13){
            e.preventDefault();
          }
          var value = that.$element.val()
          that.$measurer.text(value)
          that.$element.css('width', that.$measurer.width() + 30)
        })
    }
 
  })
 
 /* TOKENAHEAD PLUGIN DEFINITION
  * ============================ */
 
  $.fn.tokenahead = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tokenahead')
        , options = typeof option == 'object' && option
      if (!data) $this.data('tokenahead', (data = new Tokenahead(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }
 
  $.fn.tokenahead.Constructor = Tokenahead
 
  $.fn.tokenahead.defaults = $.extend($.fn.typeahead.defaults, {
    token: '<a class="tag"><span class="close">&times;</span></a>'
  })
 
}(window.jQuery)