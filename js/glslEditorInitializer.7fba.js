$(document).ready(function(){var a=$(".post .glsl-editor");a.each(function(a,b){b=$(b);var c=b[0].id,d=b.innerWidth()/2;const e=new GlslEditor("#"+c,{canvas_size:d,canvas_follow:!1,canvas_float:"right",theme:"monokai",multipleBuffers:!0,watchHash:!0,fileDrops:!0,menu:!0,tooltips:!0});$("#"+c+" .ge_editor").css("height",d+"px").css("overflow-y","auto");var f=b.data("fragment");$.ajax(f,{method:"GET",success:function(a){e.open(a)}})})});