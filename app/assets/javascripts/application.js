// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
///= require jquery3
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require_tree .

$(document).ready(function(){
  //CRUD SHOW
  $("body").on("click", "#tab-index a.list-group-item", function(e){
    var item_id = '#'+$(this).attr("id");
    var item_card_id = item_id.replace("tab-item", "show");
    var show_card = $('#show-card > .card');
    if ($(show_card).length && '#'+$(show_card).attr('id') == item_card_id){
      e.stopPropagation();
      e.preventDefault();
      $(item_card_id).remove();
      $(item_id).removeClass("active");
    }
  });

});
