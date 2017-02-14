"undefined"==typeof jQuery.migrateMute&&(jQuery.migrateMute=!0);
(function(a,p,h){function f(c){var b=p.console;r[c]||(r[c]=!0,a.migrateWarnings.push(c),b&&b.warn&&!a.migrateMute&&(b.warn("JQMIGRATE: "+c),a.migrateTrace&&b.trace&&b.trace()))}function m(c,b,d,g){if(Object.defineProperty)try{return void Object.defineProperty(c,b,{configurable:!0,enumerable:!0,get:function(){return f(g),d},set:function(a){f(g);d=a}})}catch(e){}a._definePropertyBroken=!0;c[b]=d}a.migrateVersion="1.3.0";var r={};a.migrateWarnings=[];!a.migrateMute&&p.console&&p.console.log&&p.console.log("JQMIGRATE: Logging is active");
a.migrateTrace===h&&(a.migrateTrace=!0);a.migrateReset=function(){r={};a.migrateWarnings.length=0};"BackCompat"===document.compatMode&&f("jQuery is not compatible with Quirks Mode");var t=a("\x3cinput/\x3e",{size:1}).attr("size")&&a.attrFn,v=a.attr,C=a.attrHooks.value&&a.attrHooks.value.get||function(){return null},D=a.attrHooks.value&&a.attrHooks.value.set||function(){return h},E=/^(?:input|button)$/i,F=/^[238]$/,G=/^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i,
H=/^(?:checked|selected)$/i;m(a,"attrFn",t||{},"jQuery.attrFn is deprecated");a.attr=function(c,b,d,g){var e=b.toLowerCase(),k=c&&c.nodeType;return g&&(4>v.length&&f("jQuery.fn.attr( props, pass ) is deprecated"),c&&!F.test(k)&&(t?b in t:a.isFunction(a.fn[b])))?a(c)[b](d):("type"===b&&d!==h&&E.test(c.nodeName)&&c.parentNode&&f("Can't change the 'type' of an input or button in IE 6/7/8"),!a.attrHooks[e]&&G.test(e)&&(a.attrHooks[e]={get:function(c,b){var d,e=a.prop(c,b);return!0===e||"boolean"!=typeof e&&
(d=c.getAttributeNode(b))&&!1!==d.nodeValue?b.toLowerCase():h},set:function(c,b,d){var e;return!1===b?a.removeAttr(c,d):(e=a.propFix[d]||d,e in c&&(c[e]=!0),c.setAttribute(d,d.toLowerCase())),d}},H.test(e)&&f("jQuery.fn.attr('"+e+"') might use property instead of attribute")),v.call(a,c,b,d))};a.attrHooks.value={get:function(a,b){var d=(a.nodeName||"").toLowerCase();return"button"===d?C.apply(this,arguments):("input"!==d&&"option"!==d&&f("jQuery.fn.attr('value') no longer gets properties"),b in a?
a.value:null)},set:function(a,b){var d=(a.nodeName||"").toLowerCase();return"button"===d?D.apply(this,arguments):("input"!==d&&"option"!==d&&f("jQuery.fn.attr('value', val) no longer sets properties"),void(a.value=b))}};var q,l,w=a.fn.init,I=a.parseJSON,J=/^\s*</,K=/^([^<]*)(<[\w\W]+>)([^>]*)$/;a.fn.init=function(c,b,d){var g,e;return c&&"string"==typeof c&&!a.isPlainObject(b)&&(g=K.exec(a.trim(c)))&&g[0]&&(J.test(c)||f("$(html) HTML strings must start with '\x3c' character"),g[3]&&f("$(html) HTML text after last tag is ignored"),
"#"===g[0].charAt(0)&&(f("HTML string cannot start with a '#' character"),a.error("JQMIGRATE: Invalid selector string (XSS)")),b&&b.context&&(b=b.context),a.parseHTML)?w.call(this,a.parseHTML(g[2],b&&b.ownerDocument||b||document,!0),b,d):("#"===c&&(f("jQuery( '#' ) is not a valid selector"),c=[]),e=w.apply(this,arguments),c&&c.selector!==h?(e.selector=c.selector,e.context=c.context):(e.selector="string"==typeof c?c:"",c&&(e.context=c.nodeType?c:b||document)),e)};a.fn.init.prototype=a.fn;a.parseJSON=
function(a){return a?I.apply(this,arguments):(f("jQuery.parseJSON requires a valid JSON string"),null)};a.uaMatch=function(a){a=a.toLowerCase();a=/(chrome)[ \/]([\w.]+)/.exec(a)||/(webkit)[ \/]([\w.]+)/.exec(a)||/(opera)(?:.*version|)[ \/]([\w.]+)/.exec(a)||/(msie) ([\w.]+)/.exec(a)||0>a.indexOf("compatible")&&/(mozilla)(?:.*? rv:([\w.]+)|)/.exec(a)||[];return{browser:a[1]||"",version:a[2]||"0"}};a.browser||(q=a.uaMatch(navigator.userAgent),l={},q.browser&&(l[q.browser]=!0,l.version=q.version),l.chrome?
l.webkit=!0:l.webkit&&(l.safari=!0),a.browser=l);m(a,"browser",a.browser,"jQuery.browser is deprecated");a.boxModel=a.support.boxModel="CSS1Compat"===document.compatMode;m(a,"boxModel",a.boxModel,"jQuery.boxModel is deprecated");m(a.support,"boxModel",a.support.boxModel,"jQuery.support.boxModel is deprecated");a.sub=function(){function c(a,b){return new c.fn.init(a,b)}a.extend(!0,c,this);c.superclass=this;c.fn=c.prototype=this();c.fn.constructor=c;c.sub=this.sub;c.fn.init=function(d,g){var e=a.fn.init.call(this,
d,g,b);return e instanceof c?e:c(e)};c.fn.init.prototype=c.fn;var b=c(document);return f("jQuery.sub() is deprecated"),c};a.fn.size=function(){return f("jQuery.fn.size() is deprecated; use the .length property"),this.length};var u=!1;a.swap&&a.each(["height","width","reliableMarginRight"],function(c,b){var d=a.cssHooks[b]&&a.cssHooks[b].get;d&&(a.cssHooks[b].get=function(){var a;return u=!0,a=d.apply(this,arguments),u=!1,a})});a.swap=function(a,b,d,g){var e,k={};u||f("jQuery.swap() is undocumented and deprecated");
for(e in b)k[e]=a.style[e],a.style[e]=b[e];d=d.apply(a,g||[]);for(e in b)a.style[e]=k[e];return d};a.ajaxSetup({converters:{"text json":a.parseJSON}});var L=a.fn.data;a.fn.data=function(c){var b,d,g=this[0];return!g||"events"!==c||1!==arguments.length||(b=a.data(g,c),d=a._data(g,c),b!==h&&b!==d||d===h)?L.apply(this,arguments):(f("Use of jQuery.fn.data('events') is deprecated"),d)};var M=/\/(java|ecma)script/i;a.clean||(a.clean=function(c,b,d,g){b=b||document;b=!b.nodeType&&b[0]||b;b=b.ownerDocument||
b;f("jQuery.clean() is deprecated");var e,k,n=[];if(a.merge(n,a.buildFragment(c,b).childNodes),d)for(e=function(a){return!a.type||M.test(a.type)?g?g.push(a.parentNode?a.parentNode.removeChild(a):a):d.appendChild(a):void 0},c=0;null!=(b=n[c]);c++)a.nodeName(b,"script")&&e(b)||(d.appendChild(b),"undefined"!=typeof b.getElementsByTagName&&(k=a.grep(a.merge([],b.getElementsByTagName("script")),e),n.splice.apply(n,[c+1,0].concat(k)),c+=k.length));return n});var N=a.event.add,O=a.event.remove,P=a.event.trigger,
Q=a.fn.toggle,x=a.fn.live,y=a.fn.die,R=a.fn.load,z=/\b(?:ajaxStart|ajaxStop|ajaxSend|ajaxComplete|ajaxError|ajaxSuccess)\b/,A=/(?:^|\s)hover(\.\S+|)\b/,B=function(c){return"string"!=typeof c||a.event.special.hover?c:(A.test(c)&&f("'hover' pseudo-event is deprecated, use 'mouseenter mouseleave'"),c&&c.replace(A,"mouseenter$1 mouseleave$1"))};a.event.props&&"attrChange"!==a.event.props[0]&&a.event.props.unshift("attrChange","attrName","relatedNode","srcElement");a.event.dispatch&&m(a.event,"handle",
a.event.dispatch,"jQuery.event.handle is undocumented and deprecated");a.event.add=function(a,b,d,g,e){a!==document&&z.test(b)&&f("AJAX events should be attached to document: "+b);N.call(this,a,B(b||""),d,g,e)};a.event.remove=function(a,b,d,g,e){O.call(this,a,B(b)||"",d,g,e)};a.each(["load","unload","error"],function(c,b){a.fn[b]=function(){var a=Array.prototype.slice.call(arguments,0);return f("jQuery.fn."+b+"() is deprecated"),"load"===b&&"string"==typeof arguments[0]?R.apply(this,arguments):(a.splice(0,
0,b),arguments.length?this.bind.apply(this,a):(this.triggerHandler.apply(this,a),this))}});a.fn.toggle=function(c,b){if(!a.isFunction(c)||!a.isFunction(b))return Q.apply(this,arguments);f("jQuery.fn.toggle(handler, handler...) is deprecated");var d=arguments,g=c.guid||a.guid++,e=0,k=function(b){var g=(a._data(this,"lastToggle"+c.guid)||0)%e;return a._data(this,"lastToggle"+c.guid,g+1),b.preventDefault(),d[g].apply(this,arguments)||!1};for(k.guid=g;e<d.length;)d[e++].guid=g;return this.click(k)};a.fn.live=
function(c,b,d){return f("jQuery.fn.live() is deprecated"),x?x.apply(this,arguments):(a(this.context).on(c,this.selector,b,d),this)};a.fn.die=function(c,b){return f("jQuery.fn.die() is deprecated"),y?y.apply(this,arguments):(a(this.context).off(c,this.selector||"**",b),this)};a.event.trigger=function(a,b,d,g){return d||z.test(a)||f("Global events are undocumented and deprecated"),P.call(this,a,b,d||document,g)};a.each("ajaxStart ajaxStop ajaxSend ajaxComplete ajaxError ajaxSuccess".split(" "),function(c,
b){a.event.special[b]={setup:function(){var c=this;return c!==document&&(a.event.add(document,b+"."+a.guid,function(){a.event.trigger(b,Array.prototype.slice.call(arguments,1),c,!0)}),a._data(this,b,a.guid++)),!1},teardown:function(){return this!==document&&a.event.remove(document,b+"."+a._data(this,b)),!1}}});a.event.special.ready={setup:function(){f("'ready' event is deprecated")}};var S=a.fn.andSelf||a.fn.addBack,T=a.fn.find;if(a.fn.andSelf=function(){return f("jQuery.fn.andSelf() replaced by jQuery.fn.addBack()"),
S.apply(this,arguments)},a.fn.find=function(a){var b=T.apply(this,arguments);return b.context=this.context,b.selector=this.selector?this.selector+" "+a:a,b},a.Callbacks){var U=a.Deferred,V=[["resolve","done",a.Callbacks("once memory"),a.Callbacks("once memory"),"resolved"],["reject","fail",a.Callbacks("once memory"),a.Callbacks("once memory"),"rejected"],["notify","progress",a.Callbacks("memory"),a.Callbacks("memory")]];a.Deferred=function(c){var b=U(),d=b.promise();return b.pipe=d.pipe=function(){var c=
arguments;return f("deferred.pipe() is deprecated"),a.Deferred(function(e){a.each(V,function(f,l){var h=a.isFunction(c[f])&&c[f];b[l[1]](function(){var b=h&&h.apply(this,arguments);b&&a.isFunction(b.promise)?b.promise().done(e.resolve).fail(e.reject).progress(e.notify):e[l[0]+"With"](this===d?e.promise():this,h?[b]:arguments)})});c=null}).promise()},b.isResolved=function(){return f("deferred.isResolved is deprecated"),"resolved"===b.state()},b.isRejected=function(){return f("deferred.isRejected is deprecated"),
"rejected"===b.state()},c&&c.call(b,b),b}}})(jQuery,window);
var lp=function(a,c){var b=a.utils=a.utils||{};b.isOnlineMode=function(){return window.self===window.top};b.addJsClass=function(){c("html").addClass("lp-js")};return a}(lp||{},jQuery);
(function(a,c){a.fn.googleTranslate=function(b){var e,d;c.isOnlineMode()&&(a("body").append('\x3cdiv id\x3d"google-translate-modal" class\x3d"lp-hide-on-print"\x3e\x3cdiv id\x3d"google-translate-modal-close"\x3e\x3ca href\x3d"#"\x3eClose\x3c/a\x3e\x3c/div\x3e\x3cdiv id\x3d"google_translate_element"\x3e\x3c/div\x3e\x3cp\x3eUse Google to translate the web site. We take no responsibility for the accuracy of the translation.\x3c/p\x3e\x3c/div\x3e'),a.getScript("//translate.google.com/translate_a/element.js?cb\x3dgoogleTranslateElementInit"),
a(this).click(function(b){b.preventDefault();a(".goog-te-banner-frame").is(":visible")||(e=a(this).parent(),d=a("#google-translate-modal"),d.css("top",e.offset().top+e.outerHeight()),d.css("left",e.offset().left),a("body").append(d),d.show());a("iframe.goog-te-menu-frame").contents().find("a").click(function(b){a("#google-translate-modal").hide()})}),a("#google-translate-modal-close").click(function(){a("#google-translate-modal").hide()}))};window.googleTranslateElementInit=function(){new google.translate.TranslateElement({pageLanguage:"sv",
autoDisplay:!1,layout:google.translate.TranslateElement.InlineLayout.SIMPLE},"google_translate_element")}})(jQuery,lp.utils);
(function(a,c){a.fn.svtabs=function(b){b=a.extend({headingPrefix:"Flik",headingSelector:"h2, h3, .heading"},b);c.isOnlineMode()&&a(this).each(function(){var c,d,f,h,k,g,l;c=a(this);d=a("\x3e div \x3e div",this);0<d.length&&(f=1,k=a('\x3cul class\x3d"lp-tabs"\x3e'),d.each(function(n,m){g=a(b.headingSelector,m).first();l=b.headingPrefix+" "+f++;1==g.length&&(l=g.text(),g.remove());h=a('\x3cli class\x3d"lp-tab"\x3e'+l+"\x3c/li\x3e");h.click(function(b){c.find(".lp-tab").removeClass("lp-current");d.hide();
a(m).show();a(this).addClass("lp-current")});k.append(h)}),c.prepend(k),a(d).wrapAll('\x3cdiv class\x3d"lp-panes"\x3e'),c.find(".lp-tab").first().click())})}})(jQuery,lp.utils);
(function(a,c){c.isOnlineMode()&&(a("html").delegate(".lp-clickable-area","click",function(b){b.target.tagName.match(/^a$/i)||a("a:first",this)[0].click()}),a("head").append('\x3cstyle type\x3d"text/css"\x3e.lp-clickable-area { cursor: pointer; }\x3c/style\x3e'));a.fn.clickableArea=function(){this.addClass("lp-clickable-area")}})(jQuery,lp.utils);
lp=function(a,c){(a.mobileNavigation=a.mobileNavigation||{}).initialize=function(a,e,d){e=e||"#leftmenu";d=d||".lp-mobile-navigation";var f=c(a||".lp-topmenu");c(d).click(function(){f.slideToggle("fast",function(){"none"==f.css("display")&&f.css("display","")})});c('a[href\x3d"'+e+'"]').click(function(){c("html, body").animate({scrollTop:c(e).offset().top},600);return!1})};return a}(lp||{},jQuery);
(function(a){var c={sv:"Skriv ut",en:"Print",de:"Drucken"};a.printLink=function(b){b=b||{};var e=a("html").attr("lang")||"sv";b=a('\x3ca href\x3d"#"'+(b.htmlClass?' class\x3d"'+b.htmlClass+'"':"")+"\x3e"+(c[e]||c.sv)+"\x3c/a\x3e");b.click(function(a){a.preventDefault();window.print()});return b}})(jQuery);
(function(a,b){b.utils.addJsClass();a(function(){a.printLink({htmlClass:"litenxtext"}).appendTo(".lp-printlink-placeholder");a('a[href^\x3d"http://translate.google"]').googleTranslate();a(".lp-css-tabs").svtabs();a(".sv-archive-portlet li").clickableArea();b.mobileNavigation.initialize(".lp-topmenu","#submenu",".lp-mobile-navigation")})})(jQuery,lp);
(function(d){d.flexslider=function(h,m){var a=d(h),c=d.extend({},d.flexslider.defaults,m),e=c.namespace,r="ontouchstart"in window||window.DocumentTouch&&document instanceof DocumentTouch,w=r?"touchend":"click",n="vertical"===c.direction,p=c.reverse,k=0<c.itemWidth,u="fade"===c.animation,v=""!==c.asNavFor,f={};d.data(h,"flexslider",a);f={init:function(){a.animating=!1;a.currentSlide=c.startAt;a.animatingTo=a.currentSlide;a.atEnd=0===a.currentSlide||a.currentSlide===a.last;a.containerSelector=c.selector.substr(0,
c.selector.search(" "));a.slides=d(c.selector,a);a.container=d(a.containerSelector,a);a.count=a.slides.length;a.syncExists=0<d(c.sync).length;"slide"===c.animation&&(c.animation="swing");a.prop=n?"top":"marginLeft";a.args={};a.manualPause=!1;var b;if(b=!c.video)if(b=!u)if(b=c.useCSS)a:{b=document.createElement("div");var g=["perspectiveProperty","WebkitPerspective","MozPerspective","OPerspective","msPerspective"],q;for(q in g)if(void 0!==b.style[g[q]]){a.pfx=g[q].replace("Perspective","").toLowerCase();
a.prop="-"+a.pfx+"-transform";b=!0;break a}b=!1}a.transitions=b;""!==c.controlsContainer&&(a.controlsContainer=0<d(c.controlsContainer).length&&d(c.controlsContainer));""!==c.manualControls&&(a.manualControls=0<d(c.manualControls).length&&d(c.manualControls));c.randomize&&(a.slides.sort(function(){return Math.round(Math.random())-.5}),a.container.empty().append(a.slides));a.doMath();v&&f.asNav.setup();a.setup("init");c.controlNav&&f.controlNav.setup();c.directionNav&&f.directionNav.setup();c.keyboard&&
(1===d(a.containerSelector).length||c.multipleKeyboard)&&d(document).bind("keyup",function(b){b=b.keyCode;a.animating||39!==b&&37!==b||(b=39===b?a.getTarget("next"):37===b?a.getTarget("prev"):!1,a.flexAnimate(b,c.pauseOnAction))});c.mousewheel&&a.bind("mousewheel",function(b,g){b.preventDefault();var d=0>g?a.getTarget("next"):a.getTarget("prev");a.flexAnimate(d,c.pauseOnAction)});c.pausePlay&&f.pausePlay.setup();c.slideshow&&(c.pauseOnHover&&a.hover(function(){a.manualPlay||a.manualPause||a.pause()},
function(){a.manualPause||a.manualPlay||a.play()}),0<c.initDelay?setTimeout(a.play,c.initDelay):a.play());r&&c.touch&&f.touch();(!u||u&&c.smoothHeight)&&d(window).bind("resize focus",f.resize);setTimeout(function(){c.start(a)},200)},asNav:{setup:function(){a.asNav=!0;a.animatingTo=Math.floor(a.currentSlide/a.move);a.currentItem=a.currentSlide;a.slides.removeClass(e+"active-slide").eq(a.currentItem).addClass(e+"active-slide");a.slides.click(function(b){b.preventDefault();b=d(this);var g=b.index();
d(c.asNavFor).data("flexslider").animating||b.hasClass("active")||(a.direction=a.currentItem<g?"next":"prev",a.flexAnimate(g,c.pauseOnAction,!1,!0,!0))})}},controlNav:{setup:function(){a.manualControls?f.controlNav.setupManual():f.controlNav.setupPaging()},setupPaging:function(){var b=1,g;a.controlNavScaffold=d('\x3col class\x3d"'+e+"control-nav "+e+("thumbnails"===c.controlNav?"control-thumbs":"control-paging")+'"\x3e\x3c/ol\x3e');if(1<a.pagingCount)for(var q=0;q<a.pagingCount;q++)g="thumbnails"===
c.controlNav?'\x3cimg src\x3d"'+a.slides.eq(q).attr("data-thumb")+'"/\x3e':"\x3ca\x3e"+b+"\x3c/a\x3e",a.controlNavScaffold.append("\x3cli\x3e"+g+"\x3c/li\x3e"),b++;a.controlsContainer?d(a.controlsContainer).append(a.controlNavScaffold):a.append(a.controlNavScaffold);f.controlNav.set();f.controlNav.active();a.controlNavScaffold.delegate("a, img",w,function(b){b.preventDefault();b=d(this);var g=a.controlNav.index(b);b.hasClass(e+"active")||(a.direction=g>a.currentSlide?"next":"prev",a.flexAnimate(g,
c.pauseOnAction))});r&&a.controlNavScaffold.delegate("a","click touchstart",function(a){a.preventDefault()})},setupManual:function(){a.controlNav=a.manualControls;f.controlNav.active();a.controlNav.live(w,function(b){b.preventDefault();b=d(this);var g=a.controlNav.index(b);b.hasClass(e+"active")||(g>a.currentSlide?a.direction="next":a.direction="prev",a.flexAnimate(g,c.pauseOnAction))});r&&a.controlNav.live("click touchstart",function(a){a.preventDefault()})},set:function(){a.controlNav=d("."+e+"control-nav li "+
("thumbnails"===c.controlNav?"img":"a"),a.controlsContainer?a.controlsContainer:a)},active:function(){a.controlNav.removeClass(e+"active").eq(a.animatingTo).addClass(e+"active")},update:function(b,c){1<a.pagingCount&&"add"===b?a.controlNavScaffold.append(d("\x3cli\x3e\x3ca\x3e"+a.count+"\x3c/a\x3e\x3c/li\x3e")):1===a.pagingCount?a.controlNavScaffold.find("li").remove():a.controlNav.eq(c).closest("li").remove();f.controlNav.set();1<a.pagingCount&&a.pagingCount!==a.controlNav.length?a.update(c,b):f.controlNav.active()}},
directionNav:{setup:function(){var b=d('\x3cul class\x3d"'+e+'direction-nav"\x3e\x3cli\x3e\x3ca class\x3d"'+e+'prev" href\x3d"#"\x3e'+c.prevText+'\x3c/a\x3e\x3c/li\x3e\x3cli\x3e\x3ca class\x3d"'+e+'next" href\x3d"#"\x3e'+c.nextText+"\x3c/a\x3e\x3c/li\x3e\x3c/ul\x3e");a.controlsContainer?(d(a.controlsContainer).append(b),a.directionNav=d("."+e+"direction-nav li a",a.controlsContainer)):(a.append(b),a.directionNav=d("."+e+"direction-nav li a",a));f.directionNav.update();a.directionNav.bind(w,function(b){b.preventDefault();
b=d(this).hasClass(e+"next")?a.getTarget("next"):a.getTarget("prev");a.flexAnimate(b,c.pauseOnAction)});r&&a.directionNav.bind("click touchstart",function(a){a.preventDefault()})},update:function(){var b=e+"disabled";1===a.pagingCount?a.directionNav.addClass(b):c.animationLoop?a.directionNav.removeClass(b):0===a.animatingTo?a.directionNav.removeClass(b).filter("."+e+"prev").addClass(b):a.animatingTo===a.last?a.directionNav.removeClass(b).filter("."+e+"next").addClass(b):a.directionNav.removeClass(b)}},
pausePlay:{setup:function(){var b=d('\x3cdiv class\x3d"'+e+'pauseplay"\x3e\x3ca\x3e\x3c/a\x3e\x3c/div\x3e');a.controlsContainer?(a.controlsContainer.append(b),a.pausePlay=d("."+e+"pauseplay a",a.controlsContainer)):(a.append(b),a.pausePlay=d("."+e+"pauseplay a",a));f.pausePlay.update(c.slideshow?e+"pause":e+"play");a.pausePlay.bind(w,function(b){b.preventDefault();d(this).hasClass(e+"pause")?(a.manualPause=!0,a.manualPlay=!1,a.pause()):(a.manualPause=!1,a.manualPlay=!0,a.play())});r&&a.pausePlay.bind("click touchstart",
function(a){a.preventDefault()})},update:function(b){"play"===b?a.pausePlay.removeClass(e+"pause").addClass(e+"play").text(c.playText):a.pausePlay.removeClass(e+"play").addClass(e+"pause").text(c.pauseText)}},touch:function(){function b(b){l=n?d-b.touches[0].pageY:d-b.touches[0].pageX;r=n?Math.abs(l)<Math.abs(b.touches[0].pageX-e):Math.abs(l)<Math.abs(b.touches[0].pageY-e);if(!r||500<Number(new Date)-m)b.preventDefault(),!u&&a.transitions&&(c.animationLoop||(l/=0===a.currentSlide&&0>l||a.currentSlide===
a.last&&0<l?Math.abs(l)/t+2:1),a.setProps(f+l,"setTouch"))}function g(){h.removeEventListener("touchmove",b,!1);if(a.animatingTo===a.currentSlide&&!r&&null!==l){var k=p?-l:l,n=0<k?a.getTarget("next"):a.getTarget("prev");a.canAdvance(n)&&(550>Number(new Date)-m&&50<Math.abs(k)||Math.abs(k)>t/2)?a.flexAnimate(n,c.pauseOnAction):u||a.flexAnimate(a.currentSlide,c.pauseOnAction,!0)}h.removeEventListener("touchend",g,!1);f=l=e=d=null}var d,e,f,t,l,m,r=!1;h.addEventListener("touchstart",function(l){a.animating?
l.preventDefault():1===l.touches.length&&(a.pause(),t=n?a.h:a.w,m=Number(new Date),f=k&&p&&a.animatingTo===a.last?0:k&&p?a.limit-(a.itemW+c.itemMargin)*a.move*a.animatingTo:k&&a.currentSlide===a.last?a.limit:k?(a.itemW+c.itemMargin)*a.move*a.currentSlide:p?(a.last-a.currentSlide+a.cloneOffset)*t:(a.currentSlide+a.cloneOffset)*t,d=n?l.touches[0].pageY:l.touches[0].pageX,e=n?l.touches[0].pageX:l.touches[0].pageY,h.addEventListener("touchmove",b,!1),h.addEventListener("touchend",g,!1))},!1)},resize:function(){!a.animating&&
a.is(":visible")&&(k||a.doMath(),u?f.smoothHeight():k?(a.slides.width(a.computedW),a.update(a.pagingCount),a.setProps()):n?(a.viewport.height(a.h),a.setProps(a.h,"setTotal")):(c.smoothHeight&&f.smoothHeight(),a.newSlides.width(a.computedW),a.setProps(a.computedW,"setTotal")))},smoothHeight:function(b){if(!n||u){var c=u?a:a.viewport;b?c.animate({height:a.slides.eq(a.animatingTo).height()},b):c.height(a.slides.eq(a.animatingTo).height())}},sync:function(b){var g=d(c.sync).data("flexslider"),e=a.animatingTo;
switch(b){case "animate":g.flexAnimate(e,c.pauseOnAction,!1,!0);break;case "play":g.playing||g.asNav||g.play();break;case "pause":g.pause()}}};a.flexAnimate=function(b,g,q,h,m){v&&1===a.pagingCount&&(a.direction=a.currentItem<b?"next":"prev");if(!a.animating&&(a.canAdvance(b,m)||q)&&a.is(":visible")){if(v&&h)if(q=d(c.asNavFor).data("flexslider"),a.atEnd=0===b||b===a.count-1,q.flexAnimate(b,!0,!1,!0,m),a.direction=a.currentItem<b?"next":"prev",q.direction=a.direction,Math.ceil((b+1)/a.visible)-1!==
a.currentSlide&&0!==b)a.currentItem=b,a.slides.removeClass(e+"active-slide").eq(b).addClass(e+"active-slide"),b=Math.floor(b/a.visible);else return a.currentItem=b,a.slides.removeClass(e+"active-slide").eq(b).addClass(e+"active-slide"),!1;a.animating=!0;a.animatingTo=b;c.before(a);g&&a.pause();a.syncExists&&!m&&f.sync("animate");c.controlNav&&f.controlNav.active();k||a.slides.removeClass(e+"active-slide").eq(b).addClass(e+"active-slide");a.atEnd=0===b||b===a.last;c.directionNav&&f.directionNav.update();
b===a.last&&(c.end(a),c.animationLoop||a.pause());if(u)r?(a.slides.eq(a.currentSlide).css({opacity:0,zIndex:1}),a.slides.eq(b).css({opacity:1,zIndex:2}),a.slides.unbind("webkitTransitionEnd transitionend"),a.slides.eq(a.currentSlide).bind("webkitTransitionEnd transitionend",function(){c.after(a)}),a.animating=!1,a.currentSlide=a.animatingTo):(a.slides.eq(a.currentSlide).fadeOut(c.animationSpeed,c.easing),a.slides.eq(b).fadeIn(c.animationSpeed,c.easing,a.wrapup));else{var t=n?a.slides.filter(":first").height():
a.computedW;k?(b=c.itemWidth>a.w?2*c.itemMargin:c.itemMargin,b=(a.itemW+b)*a.move*a.animatingTo,b=b>a.limit&&1!==a.visible?a.limit:b):b=0===a.currentSlide&&b===a.count-1&&c.animationLoop&&"next"!==a.direction?p?(a.count+a.cloneOffset)*t:0:a.currentSlide===a.last&&0===b&&c.animationLoop&&"prev"!==a.direction?p?0:(a.count+1)*t:p?(a.count-1-b+a.cloneOffset)*t:(b+a.cloneOffset)*t;a.setProps(b,"",c.animationSpeed);a.transitions?(c.animationLoop&&a.atEnd||(a.animating=!1,a.currentSlide=a.animatingTo),a.container.unbind("webkitTransitionEnd transitionend"),
a.container.bind("webkitTransitionEnd transitionend",function(){a.wrapup(t)})):a.container.animate(a.args,c.animationSpeed,c.easing,function(){a.wrapup(t)})}c.smoothHeight&&f.smoothHeight(c.animationSpeed)}};a.wrapup=function(b){!u&&!k&&(0===a.currentSlide&&a.animatingTo===a.last&&c.animationLoop?a.setProps(b,"jumpEnd"):a.currentSlide===a.last&&0===a.animatingTo&&c.animationLoop&&a.setProps(b,"jumpStart"));a.animating=!1;a.currentSlide=a.animatingTo;c.after(a)};a.animateSlides=function(){a.animating||
a.flexAnimate(a.getTarget("next"))};a.pause=function(){clearInterval(a.animatedSlides);a.playing=!1;c.pausePlay&&f.pausePlay.update("play");a.syncExists&&f.sync("pause")};a.play=function(){a.animatedSlides=setInterval(a.animateSlides,c.slideshowSpeed);a.playing=!0;c.pausePlay&&f.pausePlay.update("pause");a.syncExists&&f.sync("play")};a.canAdvance=function(b,g){var d=v?a.pagingCount-1:a.last;return g?!0:v&&a.currentItem===a.count-1&&0===b&&"prev"===a.direction?!0:v&&0===a.currentItem&&b===a.pagingCount-
1&&"next"!==a.direction?!1:b!==a.currentSlide||v?c.animationLoop?!0:a.atEnd&&0===a.currentSlide&&b===d&&"next"!==a.direction?!1:a.atEnd&&a.currentSlide===d&&0===b&&"next"===a.direction?!1:!0:!1};a.getTarget=function(b){a.direction=b;return"next"===b?a.currentSlide===a.last?0:a.currentSlide+1:0===a.currentSlide?a.last:a.currentSlide-1};a.setProps=function(b,d,e){var f,h=b?b:(a.itemW+c.itemMargin)*a.move*a.animatingTo;f=-1*function(){if(k)return"setTouch"===d?b:p&&a.animatingTo===a.last?0:p?a.limit-
(a.itemW+c.itemMargin)*a.move*a.animatingTo:a.animatingTo===a.last?a.limit:h;switch(d){case "setTotal":return p?(a.count-1-a.currentSlide+a.cloneOffset)*b:(a.currentSlide+a.cloneOffset)*b;case "setTouch":return b;case "jumpEnd":return p?b:a.count*b;case "jumpStart":return p?a.count*b:b;default:return b}}()+"px";a.transitions&&(f=n?"translate3d(0,"+f+",0)":"translate3d("+f+",0,0)",e=void 0!==e?e/1E3+"s":"0s",a.container.css("-"+a.pfx+"-transition-duration",e));a.args[a.prop]=f;(a.transitions||void 0===
e)&&a.container.css(a.args)};a.setup=function(b){if(u)a.slides.css({width:"100%","float":"left",marginRight:"-100%",position:"relative"}),"init"===b&&(r?a.slides.css({opacity:0,display:"block",webkitTransition:"opacity "+c.animationSpeed/1E3+"s ease",zIndex:1}).eq(a.currentSlide).css({opacity:1,zIndex:2}):a.slides.eq(a.currentSlide).fadeIn(c.animationSpeed,c.easing)),c.smoothHeight&&f.smoothHeight();else{var g,q;"init"===b&&(a.viewport=d('\x3cdiv class\x3d"'+e+'viewport"\x3e\x3c/div\x3e').css({overflow:"hidden",
position:"relative"}).appendTo(a).append(a.container),a.cloneCount=0,a.cloneOffset=0,p&&(q=d.makeArray(a.slides).reverse(),a.slides=d(q),a.container.empty().append(a.slides)));c.animationLoop&&!k&&(a.cloneCount=2,a.cloneOffset=1,"init"!==b&&a.container.find(".clone").remove(),a.container.append(a.slides.first().clone().addClass("clone")).prepend(a.slides.last().clone().addClass("clone")));a.newSlides=d(c.selector,a);g=p?a.count-1-a.currentSlide+a.cloneOffset:a.currentSlide+a.cloneOffset;n&&!k?(a.container.height(200*
(a.count+a.cloneCount)+"%").css("position","absolute").width("100%"),setTimeout(function(){a.newSlides.css({display:"block"});a.doMath();a.viewport.height(a.h);a.setProps(g*a.h,"init")},"init"===b?100:0)):(a.container.width(200*(a.count+a.cloneCount)+"%"),a.setProps(g*a.computedW,"init"),setTimeout(function(){a.doMath();a.newSlides.css({width:a.computedW,"float":"left",display:"block"});c.smoothHeight&&f.smoothHeight()},"init"===b?100:0))}k||a.slides.removeClass(e+"active-slide").eq(a.currentSlide).addClass(e+
"active-slide")};a.doMath=function(){var b=a.slides.first(),d=c.itemMargin,e=c.minItems,f=c.maxItems;a.w=a.width();a.h=b.height();a.boxPadding=b.outerWidth()-b.width();k?(a.itemT=c.itemWidth+d,a.minW=e?e*a.itemT:a.w,a.maxW=f?f*a.itemT:a.w,a.itemW=a.minW>a.w?(a.w-d*e)/e:a.maxW<a.w?(a.w-d*f)/f:c.itemWidth>a.w?a.w:c.itemWidth,a.visible=Math.floor(a.w/(a.itemW+d)),a.move=0<c.move&&c.move<a.visible?c.move:a.visible,a.pagingCount=Math.ceil((a.count-a.visible)/a.move+1),a.last=a.pagingCount-1,a.limit=1===
a.pagingCount?0:c.itemWidth>a.w?(a.itemW+2*d)*a.count-a.w-d:(a.itemW+d)*a.count-a.w-d):(a.itemW=a.w,a.pagingCount=a.count,a.last=a.count-1);a.computedW=a.itemW-a.boxPadding};a.update=function(b,d){a.doMath();k||(b<a.currentSlide?a.currentSlide+=1:b<=a.currentSlide&&0!==b&&--a.currentSlide,a.animatingTo=a.currentSlide);if(c.controlNav&&!a.manualControls)if("add"===d&&!k||a.pagingCount>a.controlNav.length)f.controlNav.update("add");else if("remove"===d&&!k||a.pagingCount<a.controlNav.length)k&&a.currentSlide>
a.last&&(--a.currentSlide,--a.animatingTo),f.controlNav.update("remove",a.last);c.directionNav&&f.directionNav.update()};a.addSlide=function(b,e){var f=d(b);a.count+=1;a.last=a.count-1;n&&p?void 0!==e?a.slides.eq(a.count-e).after(f):a.container.prepend(f):void 0!==e?a.slides.eq(e).before(f):a.container.append(f);a.update(e,"add");a.slides=d(c.selector+":not(.clone)",a);a.setup();c.added(a)};a.removeSlide=function(b){var e=isNaN(b)?a.slides.index(d(b)):b;--a.count;a.last=a.count-1;isNaN(b)?d(b,a.slides).remove():
n&&p?a.slides.eq(a.last).remove():a.slides.eq(b).remove();a.doMath();a.update(e,"remove");a.slides=d(c.selector+":not(.clone)",a);a.setup();c.removed(a)};f.init()};d.flexslider.defaults={namespace:"flex-",selector:".slides \x3e li",animation:"fade",easing:"swing",direction:"horizontal",reverse:!1,animationLoop:!0,smoothHeight:!1,startAt:0,slideshow:!0,slideshowSpeed:7E3,animationSpeed:600,initDelay:0,randomize:!1,pauseOnAction:!0,pauseOnHover:!1,useCSS:!0,touch:!0,video:!1,controlNav:!0,directionNav:!0,
prevText:"Previous",nextText:"Next",keyboard:!0,multipleKeyboard:!1,mousewheel:!1,pausePlay:!1,pauseText:"Pause",playText:"Play",controlsContainer:"",manualControls:"",sync:"",asNavFor:"",itemWidth:0,itemMargin:0,minItems:0,maxItems:0,move:0,start:function(){},before:function(){},after:function(){},end:function(){},added:function(){},removed:function(){}};d.fn.flexslider=function(h){void 0===h&&(h={});if("object"===typeof h)return this.each(function(){var a=d(this),c=a.find(h.selector?h.selector:
".slides \x3e li");1===c.length?(c.fadeIn(400),h.start&&h.start(a)):void 0==a.data("flexslider")&&new d.flexslider(this,h)});var m=d(this).data("flexslider");switch(h){case "play":m.play();break;case "pause":m.pause();break;case "next":m.flexAnimate(m.getTarget("next"),!0);break;case "prev":case "previous":m.flexAnimate(m.getTarget("prev"),!0);break;default:"number"===typeof h&&m.flexAnimate(h,!0)}}})(jQuery);
(function(d){d.fn.extend({autocomplete:function(a,c){var u="string"==typeof a;c=d.extend({},d.Autocompleter.defaults,{url:u?a:null,data:u?null:a,delay:u?d.Autocompleter.defaults.delay:10,max:c&&!c.scroll?10:150},c);c.highlight=c.highlight||function(a){return a};c.formatMatch=c.formatMatch||c.formatItem;return this.each(function(){new d.Autocompleter(this,c)})},result:function(a){return this.bind("result",a)},search:function(a){return this.trigger("search",[a])},flushCache:function(){return this.trigger("flushCache")},
setOptions:function(a){return this.trigger("setOptions",[a])},unautocomplete:function(){return this.trigger("unautocomplete")}});d.Autocompleter=function(a,c){function u(){var a=l.selected();if(!a)return!1;var b=a.result;t=b;if(c.multiple){var d=v(g.val());1<d.length&&(b=d.slice(0,d.length-1).join(c.multipleSeparator)+c.multipleSeparator+b);b+=c.multipleSeparator}g.val(b);p();g.trigger("result",[a.data,a.value]);return!0}function k(a,d){if(q==b.DEL)l.hide();else{var e=g.val();if(d||e!=t)t=e,e=m(e),
e.length>=c.minChars?(g.addClass(c.loadingClass),c.matchCase||(e=e.toLowerCase()),f(e,h,p)):(g.removeClass(c.loadingClass),l.hide())}}function v(a){if(!a)return[""];a=a.split(c.multipleSeparator);var b=[];d.each(a,function(a,c){d.trim(c)&&(b[a]=d.trim(c))});return b}function m(a){if(!c.multiple)return a;a=v(a);return a[a.length-1]}function p(){var b=l.visible();l.hide();clearTimeout(n);g.removeClass(c.loadingClass);c.mustMatch&&g.search(function(a){a||(c.multiple?(a=v(g.val()).slice(0,-1),g.val(a.join(c.multipleSeparator)+
(a.length?c.multipleSeparator:""))):g.val(""))});b&&d.Autocompleter.Selection(a,a.value.length,a.value.length)}function h(f,h){if(h&&h.length&&e){g.removeClass(c.loadingClass);l.display(h,f);var n=h[0].value;c.autoFill&&m(g.val()).toLowerCase()==f.toLowerCase()&&q!=b.BACKSPACE&&(g.val(g.val()+n.substring(m(t).length)),d.Autocompleter.Selection(a,t.length,t.length+n.length));l.show()}else p()}function f(b,f,h){c.matchCase||(b=b.toLowerCase());var q=r.load(b);if(q&&q.length)f(b,q);else if("string"==
typeof c.url&&0<c.url.length){var e={timestamp:+new Date};d.each(c.extraParams,function(a,b){e[a]="function"==typeof b?b():b});d.ajax({mode:"abort",port:"autocomplete"+a.name,dataType:c.dataType,url:c.url,data:d.extend({q:m(b),limit:c.max},e),success:function(a){var q;if(!(q=c.parse&&c.parse(a))){q=[];a=a.split("\n");for(var h=0;h<a.length;h++){var e=d.trim(a[h]);e&&(e=e.split("|"),q[q.length]={data:e,value:e[0],result:c.formatResult&&c.formatResult(e,e[0])||e[0]})}}r.add(b,q);f(b,q)}})}else l.emptyList(),
h(b)}var b={UP:38,DOWN:40,DEL:46,TAB:9,RETURN:13,ESC:27,COMMA:188,PAGEUP:33,PAGEDOWN:34,BACKSPACE:8},g=d(a).attr("autocomplete","off").addClass(c.inputClass),n,t="",r=d.Autocompleter.Cache(c),e=0,q,x={mouseDownOnSelect:!1},l=d.Autocompleter.Select(c,a,u,x),w;d.browser.opera&&d(a.form).bind("submit.autocomplete",function(){if(w)return w=!1});g.bind((d.browser.opera?"keypress":"keydown")+".autocomplete",function(a){q=a.keyCode;switch(a.keyCode){case b.UP:a.preventDefault();l.visible()?l.prev():k(0,
!0);break;case b.DOWN:a.preventDefault();l.visible()?l.next():k(0,!0);break;case b.PAGEUP:a.preventDefault();l.visible()?l.pageUp():k(0,!0);break;case b.PAGEDOWN:a.preventDefault();l.visible()?l.pageDown():k(0,!0);break;case c.multiple&&","==d.trim(c.multipleSeparator)&&b.COMMA:case b.TAB:case b.RETURN:if(u())return a.preventDefault(),w=!0,!1;break;case b.ESC:l.hide();break;default:clearTimeout(n),n=setTimeout(k,c.delay)}}).focus(function(){e++}).blur(function(){e=0;x.mouseDownOnSelect||(clearTimeout(n),
n=setTimeout(p,200))}).click(function(){1<e++&&!l.visible()&&k(0,!0)}).bind("search",function(){function a(c,d){var q;if(d&&d.length)for(var e=0;e<d.length;e++)if(d[e].result.toLowerCase()==c.toLowerCase()){q=d[e];break}"function"==typeof b?b(q):g.trigger("result",q&&[q.data,q.value])}var b=1<arguments.length?arguments[1]:null;d.each(v(g.val()),function(b,c){f(c,a,a)})}).bind("flushCache",function(){r.flush()}).bind("setOptions",function(a,b){d.extend(c,b);"data"in b&&r.populate()}).bind("unautocomplete",
function(){l.unbind();g.unbind();d(a.form).unbind(".autocomplete")})};d.Autocompleter.defaults={inputClass:"ac_input",resultsClass:"ac_results",loadingClass:"ac_loading",minChars:1,delay:400,matchCase:!1,matchSubset:!0,matchContains:!1,cacheLength:10,max:100,mustMatch:!1,extraParams:{},selectFirst:!0,formatItem:function(a){return a[0]},formatMatch:null,autoFill:!1,width:0,multiple:!1,multipleSeparator:", ",highlight:function(a,c){return a.replace(new RegExp("(?![^\x26;]+;)(?!\x3c[^\x3c\x3e]*)("+c.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi,
"\\$1")+")(?![^\x3c\x3e]*\x3e)(?![^\x26;]+;)","gi"),"\x3cstrong\x3e$1\x3c/strong\x3e")},scroll:!0,scrollHeight:180};d.Autocompleter.Cache=function(a){function c(c,d){a.matchCase||(c=c.toLowerCase());var b=c.indexOf(d);"word"==a.matchContains&&(b=c.toLowerCase().search("\\b"+d.toLowerCase()));return-1==b?!1:0==b||a.matchContains}function u(c,d){p>a.cacheLength&&v();m[c]||p++;m[c]=d}function k(){if(!a.data)return!1;var c={},f=0;a.url||(a.cacheLength=1);c[""]=[];for(var b=0,g=a.data.length;b<g;b++){var n=
a.data[b],n="string"==typeof n?[n]:n,t=a.formatMatch(n,b+1,a.data.length);if(!1!==t){var m=t.charAt(0).toLowerCase();c[m]||(c[m]=[]);n={value:t,data:n,result:a.formatResult&&a.formatResult(n)||t};c[m].push(n);f++<a.max&&c[""].push(n)}}d.each(c,function(c,b){a.cacheLength++;u(c,b)})}function v(){m={};p=0}var m={},p=0;setTimeout(k,25);return{flush:v,add:u,populate:k,load:function(h){if(!a.cacheLength||!p)return null;if(!a.url&&a.matchContains){var f=[],b;for(b in m)if(0<b.length){var g=m[b];d.each(g,
function(a,b){c(b.value,h)&&f.push(b)})}return f}if(m[h])return m[h];if(a.matchSubset)for(b=h.length-1;b>=a.minChars;b--)if(g=m[h.substr(0,b)])return f=[],d.each(g,function(a,b){c(b.value,h)&&(f[f.length]=b)}),f;return null}}};d.Autocompleter.Select=function(a,c,u,k){function v(){t&&(r=d("\x3cdiv/\x3e").hide().addClass(a.resultsClass).css("position","absolute").appendTo(document.body),e=d("\x3cul/\x3e").appendTo(r).mouseover(function(a){m(a).nodeName&&"LI"==m(a).nodeName.toUpperCase()&&(b=d("li",
e).removeClass(h.ACTIVE).index(m(a)),d(m(a)).addClass(h.ACTIVE))}).click(function(a){d(m(a)).addClass(h.ACTIVE);u();c.focus();return!1}).mousedown(function(){k.mouseDownOnSelect=!0}).mouseup(function(){k.mouseDownOnSelect=!1}),0<a.width&&r.css("width",a.width),t=!1)}function m(a){for(a=a.target;a&&"LI"!=a.tagName;)a=a.parentNode;return a?a:[]}function p(c){f.slice(b,b+1).removeClass(h.ACTIVE);b+=c;0>b?b=f.size()-1:b>=f.size()&&(b=0);c=f.slice(b,b+1).addClass(h.ACTIVE);if(a.scroll){var d=0;f.slice(0,
b).each(function(){d+=this.offsetHeight});d+c[0].offsetHeight-e.scrollTop()>e[0].clientHeight?e.scrollTop(d+c[0].offsetHeight-e.innerHeight()):d<e.scrollTop()&&e.scrollTop(d)}}var h={ACTIVE:"ac_over"},f,b=-1,g,n="",t=!0,r,e;return{display:function(c,m){v();g=c;n=m;e.empty();var l;l=g.length;l=a.max&&a.max<l?a.max:l;for(var k=0;k<l;k++)if(g[k]){var p=a.formatItem(g[k].data,k+1,l,g[k].value,n);!1!==p&&(p=d("\x3cli/\x3e").html(a.highlight(p,n)).addClass(0==k%2?"ac_even":"ac_odd").appendTo(e)[0],d.data(p,
"ac_data",g[k]))}f=e.find("li");a.selectFirst&&(f.slice(0,1).addClass(h.ACTIVE),b=0);d.fn.bgiframe&&e.bgiframe()},next:function(){p(1)},prev:function(){p(-1)},pageUp:function(){0!=b&&0>b-8?p(-b):p(-8)},pageDown:function(){b!=f.size()-1&&b+8>f.size()?p(f.size()-1-b):p(8)},hide:function(){r&&r.hide();f&&f.removeClass(h.ACTIVE);b=-1},visible:function(){return r&&r.is(":visible")},current:function(){return this.visible()&&(f.filter("."+h.ACTIVE)[0]||a.selectFirst&&f[0])},show:function(){var b=d(c).offset();
r.css({width:"string"==typeof a.width||0<a.width?a.width:d(c).width(),top:b.top+c.offsetHeight,left:b.left}).show();if(a.scroll&&(e.scrollTop(0),e.css({maxHeight:a.scrollHeight,overflow:"auto"}),d.browser.msie&&"undefined"===typeof document.body.style.maxHeight)){var g=0;f.each(function(){g+=this.offsetHeight});b=g>a.scrollHeight;e.css("height",b?a.scrollHeight:g);b||f.width(e.width()-parseInt(f.css("padding-left"))-parseInt(f.css("padding-right")))}},selected:function(){var a=f&&f.filter("."+h.ACTIVE).removeClass(h.ACTIVE);
return a&&a.length&&d.data(a[0],"ac_data")},emptyList:function(){e&&e.empty()},unbind:function(){r&&r.remove()}}};d.Autocompleter.Selection=function(a,c,d){if(a.createTextRange){var k=a.createTextRange();k.collapse(!0);k.moveStart("character",c);k.moveEnd("character",d);k.select()}else a.setSelectionRange?a.setSelectionRange(c,d):a.selectionStart&&(a.selectionStart=c,a.selectionEnd=d);a.focus()}})(jQuery);