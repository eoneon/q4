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
  $("body").on("click", ".caret-toggle", function(){
    $(this).find("i").toggleClass("fa-caret-right fa-caret-down");
    $(this).closest(".card").siblings().find("i.fa-caret-down").toggleClass("fa-caret-right fa-caret-down");
    $(this).closest(".card").siblings().find(".card-body.show").toggleClass("show hide");
  });

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

  $("body").on("click", ".dropdown a.field-toggle", function(){
    var target = $(this).attr("href");
    if ($(target).hasClass("show")){
      $(target).toggleClass("show collapse");
    } else {
      $(target).closest(".toggle-field-group").find(".toggle-field.show").toggleClass("show collapse");
      $(target).toggleClass("show collapse");
    }
  });

  $("body").on("click", ".collapse-field-btn", function(){
    $(this).closest(".toggle-field").toggleClass("show collapse");
  });

  //#SEARCH: handler for submitting search form: on dropdown selection
  $("body").on("change", ".search-select", function(){
    var v = $(this).val();
    var form = $(this).closest("form");
    $('#'+$(this).attr("id").replace("product_search", "hidden")).val(v);
    $(form).submit();
  });

  //#SEARCH: handler for submitting search form: on dropdown selection
  $("body").on("click", ".reset-select", function(){
    var id = $(this).attr("data-target");
    var form = $(this).closest("form");
    $("#product_search_"+id+"").val("all"); //("option").attr('selected', true);
    $("#hidden_"+id+"").val("all");
    $(form).submit();
  });

  //#SEARCH: (draft) handler for submitting search form: on dropdown selection
  // $("body").on("change", ".search-select", function(){
  //   var idx = $(this).prop("selectedIndex");
  //   var form = $(this).closest("form");
  //   $('#'+$(this).attr("id").replace("product_search", "hidden")).val(idx);
  //   $(form).submit();
  // });

  //#SEARCH: handler for submitting search form: on dropdown selection
  //$("input:hidden[name='product_id']").val(id);
  // $("body").on("change", ".search-select", function(){
  //   var idx = $(this).prop("selectedIndex");
  //   var form = $(this).closest("form");
  //   var input = $(this).closest("input:select[name=]");
  //   $(form).submit();
  //   $(form).find(".form").attr("data-search", idx); //.form
  //   //$(form_row).attr("data-search", idx); //.form
  //   $(form).find('select :nth-child('+idx+')').attr('selected', true);
  //   //$(form_row).find('select :nth-child('+idx+')').attr('selected', true);
  //   console.log(input)
  // });

  //#SEARCH: handler for submitting search form: on dropdown selection
  // $("body").on("change", ".product-select", function(){
  //   var form = $(this).closest("form");
  //   $(form).submit();
  // });

  // function afterSearch(target, tags) {
  //   var card_obj = objRef(target, tags);
  //   var search_ids = $("#search-form").find('select option').eq(idx).val();
  //   var id = card_obj.obj_id.split("-").pop();
  //   if (!card_obj['edit-form'].find('input.category').prop("checked") && !search_ids[id]) {
  //     card_obj['show'].remove();
  //   } else {
  //     card_obj['tab-item'].filter("a").addClass("active");
  //   }
  // }

});
