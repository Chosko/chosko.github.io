$(document).ready(function(){$(".hover-target").mouseenter(function(){var a=$(this),b=a.attr("data-hover-target");b&&$("#"+b).mouseenter()}),$(".hover-target").mouseleave(function(){var a=$(this),b=a.attr("data-hover-target");b&&$("#"+b).mouseleave()}),$(".show-on-scroll").css({opacity:0}),$(window).scroll(function(){var a=$(this).scrollTop();$.each($(".show-on-scroll"),function(b,c){var d=$(c).offset().top;d<a+$(window).height()-$(c).height()&&$(c).animate({opacity:100},1e4)})}),$(".featurette-image").mouseenter(function(a){$(this).stop().animate({borderRadius:"150px"}),a.stopPropagation()}),$(".featurette-image").mouseleave(function(a){$(this).stop().animate({borderRadius:"8px"}),a.stopPropagation()}),$(".filter-category").click(function(){var a=$(this).attr("data-category"),b=0;$.each($(".category:visible"),function(c,d){var e=$(d);e.hasClass(a)||(setTimeout(function(){e.hide(500)},b),b+=300)}),$.each($(".category:hidden"),function(c,d){var e=$(d);e.hasClass(a)&&(setTimeout(function(){e.show(500)},b),b+=300)}),$("#show-all-posts:hidden").show(500)}),$("#show-all-posts").click(function(){var a=0;$.each($(".category.col-md-6:hidden"),function(b,c){setTimeout(function(){$(c).show(500)},a),a+=300}),$.each($(".category.category-text:visible"),function(b,c){setTimeout(function(){$(c).hide(500)},a),a+=300}),$(this).hide(500)}),$("#contact-form-submit").click(function(){$(this).button("loading"),$("#contact-form-message").hide(500),$("#contact-form-errors").hide(500),$("#new_contact .form-group").removeClass("has-error")}),$("#new_contact").bind("ajax:complete",function(a,b,c,d){$("#contact-form-submit").button("reset"),Recaptcha.reload()}),$("#new_contact").bind("ajax:success",function(a,b,c,d){$("#contact-form-message").show(500).html(b.message)}),$("#new_contact").bind("ajax:error",function(a,b,c,d){if(b.responseJSON&&b.responseJSON.message){$("#contact-form-errors").show(500).html(b.responseJSON.message);var e=b.responseJSON.errors;if(e){var f=$("#new_contact div").map(function(a,b){return $(b).attr("data-for")});$.each(e,function(a,b){$.inArray(a,f)>-1&&$("#new_contact .form-group[data-for="+a+"]").addClass("has-error")}),$.inArray("base",f)>-1&&$("#recaptcha_response_field").css("border-color: red")}}else $("#contact-form-errors").show(500).html("There was an unknown error or the request timed out. Please try again later.")})});