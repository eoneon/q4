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
    var id = $(this).attr("id");
    $(this).find("i").toggleClass("fa-caret-right fa-caret-down");
    $(this).closest(".card").find(".card-body").toggleClass("show collapse");
    if ($(this).find("i").hasClass("fa-caret-down")){
      $("#caret-id").val(id);
      $(this).closest(".card").siblings().find("i.fa-caret-down").toggleClass("fa-caret-right fa-caret-down");
      $(this).closest(".card").siblings().find(".card-body.show").toggleClass("show collapse");
    } else{
      $("#caret-id").val("");
    }
  });

  //edit-form submission: UPDATE select field and submit form
  $("body").on("change", ".field-param", function(){
    var form = $(this).closest("form");
    $(form).submit();
  });

  $("body").on("change", "select.search-select", function(){
    var form = $(this).closest("form");
    $(form).submit();
  });

  $("body").on("focusout", ".input-field", function(){
    $(this).closest("form").submit();
  });

  // invoice#show.html #new-skus: collapse.show - caret-right/caret-down - clear fields
  $("body").on("click", "#invoice-nav .nav-link", function(){
    if ($("#new-skus-toggle").hasClass("show")){
      $("#new-skus-toggle .form :input").val("");
      $("#title-select").find("option:first").siblings().remove();
      $("#new-skus .default-caret-right i.fa-caret-down").toggleClass("fa-caret-right fa-caret-down");
      $("#new-skus .default-collapse.show").toggleClass("show collapse");
      $("#new-skus .default-show.collapse").toggleClass("show collapse");
    }
  });

  $("body").on("change", "#artist-search, #product-search", function(){
    var id = $(this).val();
    var input = "."+$(this).attr("id").split("-")[0]+"_id"
    toggleInputVal($("#new-skus, #new-title").find(input), id);
    $("#new-title").submit();
  });

  $("body").on("change", "#title-select", function(){
    var title = $(this).val();
    $("#title-text").val(title);
    $(".title-toggle").toggleClass("show collapse");
  });

  $("body").on("change", "#artist_id, #product_id", function(){
    var id = $(this).val();
    var input = "."+$(this).attr("id");
    toggleInputVal($("#new-title").find(input), id);
    $("#new-title").submit();
  });

  $("body").on("click", ".toggle-view", function(){
    var toggle_targets = "."+$(this).attr("id");
    $(toggle_targets).toggleClass("show collapse");
  });

  //what is this?
  $("body").on("click", ".search-btn", function(){
    $('#new-skus').find(":selected").attr('selected', false);
    $('#new-skus').find(":input").val("");
  });

  //item-field
  $("body").on("change", ".item-product-select", function(){
    setInput($(this).attr("data-target"), $(this).val());
    $("#edit-item").submit();
  });

  //items#search
  $("body").on("click", ".refresh", function(){
    setInput($(this).attr("data-target"), false);
    submitFormByContext($(this).closest("form").attr("id"));
  });

  //CRUD SHOW SEARCH: not sure if using these 3
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

  $(function(e) {
    var artist_id = $('#hidden_artist_id').val();
    if (artist_id != undefined && artist_id.length){
      $('.artist-add option[value="'+artist_id+'"]').attr('selected', true);
    }
  });

  //new
  function toggleInputVal(inputs, value) {
    var val = value.length ? value : ""
    $(inputs).val(value);
  }

  function setInput(input_name, value) {
    $('input[name="'+input_name+'"]').val(value);
  }

  function submitFormByContext(context) {
    if (context == "search-item-product"){
      $("#edit-item").submit();
    }
  }

  function toggleTab(id, e) {
    if ($('#'+id).hasClass("active")) {
      e.stopPropagation();
      e.preventDefault();
      $('#'+id).removeClass("active");
    }
  }

  function toggleAttr(new_id, old_id) {
    if (new_id == old_id){
      var id = "";
    } else {
      var id = new_id;
    }
    return id
  }

});

// not using:

// function toggleHttp(new_id, old_id) {
//   if (old_id.length == 0) {
//     var method = "post"; //id = new_id
//   } else if (new_id != old_id) {
//     var method = "patch"; //id = new_id
//   } else if (new_id == old_id){
//     var method = "delete"; //id = ""
//   }
//   return method
// }

// $("body").on("keyup", ".required-field", function(){
//   var val = $(this).val();
//   var submit = $(this).closest("form").find(".disabled-btn");
//   if (val.length){
//     $(submit).removeAttr('disabled');
//   } else {
//     $(submit).attr('disabled', 'disabled')
//   }
// });

//CRUD ITEM-ARTIST #update
// $("body").on("change", ".artist-update", function(e){
//   $("#patch-item-artist").submit();
// });

//CRUD ITEM-PRODUCT #update -> REFACTOR: not sure if using
// $("body").on("click", "#item-products-index button.list-group-item", function(e){
//   var new_id = $(this).attr("id");
//   var old_id = $(this).attr("data-selected");
//   var method = toggleHttp(new_id, old_id);
//   $("input[name='product_id']").val(toggleAttr(new_id, old_id));
//   $('#'+method+'-item-product').submit();
// });
//
// //CRUD ITEM-SEARCH INDEX #update
// $("body").on("click", "#item-index button.list-group-item", function(e){
//   var item_id = $('#hidden_item_id').val();
//   var id = $(this).attr("id");
//   toggleTab(id, e);
//   $('#hidden_item_id').val(toggleAttr(item_id, id));
// });

//CRUD SHOW: used with aside
// $("body").on("click", "#tab-index a.list-group-item", function(e){
//   var item_id = '#'+$(this).attr("id");
//   var item_card_id = item_id.replace("tab-item", "show");
//   var show_card = $('#show-card > .card');
//   if ($(show_card).length && '#'+$(show_card).attr('id') == item_card_id){
//     e.stopPropagation();
//     e.preventDefault();
//     $(item_card_id).remove();
//     $(item_id).removeClass("active");
//   }
// });

// RADIO BUTTON fn
// $("body").on("change", ":radio.search-select", function(){
//   var form = $(this).closest("form");
//   $(form).find(":selected").attr('selected', false);
//   $(form).submit();
// });

// COLLAPSE/SHOW TOGGLE fn
// $("body").on("click", ".form-toggle", function(){
//   var target = $(this).attr("data-target");
//   if (!$(target).hasClass("show")){
//     $(this).addClass("active").siblings().removeClass("active");
//     $(target).siblings().removeClass("show");
//     $(target).addClass("show");
//   }
// });

// old methods for reference

// $("body").on("click", ".caret-toggle", function(){
//   if ($(this).find("i").hasClass("fa-caret-right")){
//     $(this).find("i").toggleClass("fa-caret-right fa-caret-down");
//     $(this).closest(".card").find(".card-body").toggleClass("show collapse");
//
//     $(this).closest(".card").siblings().find("i.fa-caret-down").toggleClass("fa-caret-right");
//     $(this).closest(".card").siblings().find(".card-body.show").toggleClass("show collapse");
//   } else {
//     $(this).find("i").toggleClass("fa-caret-right fa-caret-down");
//     $(this).closest(".card").find(".card-body.show").toggleClass("show collapse");
//   }
// });

// $("body").on("change", "select.artist-select", function(){
//   var artist = $(this).val();
//   if (artist.length){
//     $('#new-skus option[value="'+artist+'"]').attr('selected', true);
//   } else {
//     $('#new-skus').find(":selected").attr('selected', false);
//   }
// });

//#SEARCH: handler for submitting search form: on dropdown selection
// $("body").on("click", ".reset-select", function(){
//   var input_name = $(this).attr("data-target");
//   var form = $(this).closest("form");
//   $("#items_search_"+input_name+"").val("all");
//   $("#hidden_search_"+input_name+"").val("all");
//   //$("#hidden_previous"+input_name+"").val("all");
//   $(form).submit();
// });

//page load
// $(function(e) {
//   var type = $('#hidden_search_type').val();
//   $("input[name='items[search][type]']").prop('checked', false)
//   $("input[name='items[search][type]'][value='"+type+"']").prop('checked', true);
//   var product_id = $('#hidden_product_id').val();
//   if (product_id != undefined && product_id.length){
//     $('#'+product_id).addClass("active");
//
//     var input_vals = $("#search-form").find("input:hidden");
//     $(input_vals).each(function(i, input){
//       var v = $(input).val();
//       $('option[value="'+v+'"]').attr('selected', true);
//     });
//   }
// });

//#SEARCH: handler for submitting search form: on dropdown selection
// $("body").on("change", ".search-select", function(){
//   var v = $(this).val();
//   var form = $(this).closest("form");
//   $('#'+$(this).attr("id").replace("product_search", "hidden")).val(v);
//   $(form).submit();
// });

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

// $("body").on("change", "select.title-select", function(){
//   var product = $(this).val();
//   toggleInputVal($("#new-skus #title_id"), product);
//   // if (product.length){
//   //   $("#new-skus #title_id").val(product);
//   // } else {
//   //   $("#new-skus #title_id").val(false);
//   // }
// });
