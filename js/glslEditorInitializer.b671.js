$(document).ready(function(){var a=$(".post .glsl-editor");a.each(function(a,b){b=$(b);var c=b[0].id,d=window.innerWidth>=992,e=b.innerWidth();d&&(e/=2);const f=new GlslEditor("#"+c,{canvas_size:e,canvas_follow:!1,canvas_float:"right",theme:"monokai",multipleBuffers:!0,watchHash:!0,fileDrops:!0,menu:!0,tooltips:!0});$("#"+c+" .ge_editor").css("height",(d?e:.8*e)+"px").css("overflow-y","auto");var g=b.data("fragment");$.ajax(g,{method:"GET",success:function(a){f.open(a)}}),$(window).resize(function(){var a=b.innerWidth(),d=window.innerWidth>=992;d&&(a/=2),$("#"+c+" .ge_editor").css("height",(d?a:.8*a)+"px"),$("#"+c+" .ge_canvas").css("width",a+"px").css("height",a+"px")})})});