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

  $("body").on("click", ".form-toggle", function(){
    var target = $(this).attr("data-target");
    if (!$(target).hasClass("show")){
      $(this).addClass("active").siblings().removeClass("active");
      $(target).siblings().removeClass("show");
      $(target).addClass("show");
    }
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

  //CRUD SHOW SEARCH
  $("body").on("change", ".artist-search", function(){
    var v = $(this).val();
    if (v.length) {
      $(this).closest("form").submit();
    } else {
      $('#show-card > .card').remove();
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

  //CRUD ITEM-PRODUCT #update
  $("body").on("click", "#product-index button.list-group-item", function(e){
    var product_id = $('#hidden_product_id').val();
    var id = $(this).attr("id");
    toggleTab(id, e);
    if (product_id == id){
      id = "";
    } else {
      id
    }
    $('#hidden_product_id').val(id);
    $("#edit-item").submit();
  });

  //#SEARCH: handler for submitting search form: on dropdown selection
  // $("body").on("change", ".search-select", function(){
  //   var v = $(this).val();
  //   var form = $(this).closest("form");
  //   $('#'+$(this).attr("id").replace("product_search", "hidden")).val(v);
  //   $(form).submit();
  // });

  $("body").on("change", ".search-select", function(){
    var v = $(this).val();
    var form = $(this).closest("form");
    $('#'+$(this).attr("id").replace("items_search", "hidden_search")).val(v);
    $(form).submit();
  });

  //#SEARCH: handler for submitting search form: on dropdown selection
  $("body").on("click", ".reset-select", function(){
    var input_name = $(this).attr("data-target");
    //console.log("#item_search_"+input_name+"")
    var form = $(this).closest("form");
    $("#items_search_"+input_name+"").val("all"); //("option").attr('selected', true);
    $("#hidden_search_"+input_name+"").val("all");
    $(form).submit();
  });

  $(function(e) {
    //console.log("app.js")
    var id = $('#hidden_product_id').val();
    if (id.length){
      $('#'+id).addClass("active");
      var input_vals = $("#search-form").find("input:hidden");
      $(input_vals).each(function(i, input){
        var v = $(input).val();
        $('option[value="'+v+'"]').attr('selected', true);
      });
    }
  });

  function toggleTab(id, e) {
    if ($('#'+id).hasClass("active")) {
      e.stopPropagation();
      e.preventDefault();
      $('#'+id).removeClass("active");
    }
  }
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
