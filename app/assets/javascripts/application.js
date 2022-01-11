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
    var [action, parent, input] = [iconToggleAction($(this), "fa-caret-down"), $(this).closest(".card"), $(this).attr("data-input")];
    toggleSet($("#caret-id"), $(this).attr("id"), $("#caret-id").val()); //toggleSet($(input), $(this).attr("id"), $(input).val());
    caretToggle($(this), parent, $(parent).attr("data-target"), action, ".caret-toggle");
  });

  $("body").on("click", ".slide-toggle", function(){
    var [action, parent, nav_target] = [iconToggleAction($(this), "fa-toggle-on"), $(this).attr("data-parent"), $(this).attr("data-target")];
    showAction(action, parent, $(parent).attr("data-target"), nav_target, $(this).attr("data-show-target"), ".slide-toggle");
    iconToggle($(this), "fa-toggle-on fa-toggle-off");
    toggleVisability($(parent).find(nav_target));
  });

  $("body").on("click", ".toggle-nav button", function(){
    var parent_target = $(this).parent().attr("data-parent");
    if ($(parent_target).is(":visible") == $($(this).attr("data-target")).is(":visible")) toggleVisability(parent_target);
    toggleActive($(this), $(this).siblings().filter(".active"));
  });

  $("body").on("click", "#invoice-nav .nav-link", function(){
    toggleActive($(this), $(this).closest(".navbar-nav").find("a.active"));
  });

  //fields
  $("body").on("keyup", ".required-field", function(){
    var val = $(this).val();
    var submit = $(this).closest("form").find(".submit-btn");
    if (val.length){
      $(submit).removeAttr('disabled');
    } else {
      $(submit).attr('disabled', 'disabled');
    }
  });

  // COLLAPSE/SHOW TOGGLE fn: FIX SINCE WE REFACTORED METHOD
  $("body").on("click", ".form-toggle a, .toggle-target button", function(){
    toggleActive($(this), ".form-toggle");
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

  //invoice#show.html #new-skus: collapse.show - caret-right/caret-down - clear fields
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
    var input = "."+sliceTag($(this).attr("id"), 0)+"_id"
    toggleInputVal($(this).closest("form").parent().find(input), $(this).val());
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
  $("body").on("change", ".update-search", function(){
    setInputVal(inputGroupData($(this), "data-input"), $(this).val());
    $(inputGroupData($(this), "data-form")).submit();
  });

  //items#search
  $("body").on("click", ".deselect", function(){
    setInputVal(inputGroupData($(this), "data-input"), "");
    $(inputGroupData($(this), "data-form")).submit();
  });

  //items#search
  $("body").on("click", ".unselect", function(){
    $(this).closest(".input-group").find(":selected").attr('selected', false);
    $(inputGroupData($(this), "data-form")).submit();
  });

  $("body").on("click", ".list-group-item", function(e){
    var new_id = $(this).attr("id");
    var input = $($(this).attr("data-form")).find($($(this).attr("data-field")));
    toggleSet(input, new_id, $(input).val());
    toggleTab(new_id, e);
  });

  // click/change -> set target field
  function toggleInputVal(inputs, value) {
    var val = value.length ? value : ""
    $(inputs).val(value);
  }
  function setInputVal(input_name, value) {
    $('input[name="'+input_name+'"]').val(value);
  }
  function inputGroupData(ref, data) {
    return $(ref).closest(".input-group").attr(data);
  }


  function toggleSet(input, new_id, old_id) {
    $(input).val(toggleVal(new_id, old_id));
  }

  function toggleVal(new_id, old_id) {
    return new_id == old_id ? "" : new_id
  }

  // aside/tabs
  function toggleTab(id, e) {
    if ($('#'+id).hasClass("active")) {
      e.stopPropagation();
      e.preventDefault();
      $('#'+id).removeClass("active");
    }
  }

  //toggle current caret-icon & card-body ######################################
  function caretToggle(caret_btn, parent, target, action, kill_btn) {
    toggleCard(caret_btn, $(parent).find(target));
    var active_sibling = $(parent).siblings().has(target+":visible");
    if (action=='show' && active_sibling.length) {
      toggleCard($(active_sibling).find(kill_btn), $(active_sibling).find(target));
    }
  }
  function toggleCard(caret_btn, target) {
    iconToggle(caret_btn,"fa-caret-right fa-caret-down")
    toggleVisability(target);
  }
  function killSibling(parent, target, kill_btn) {
    var active_sibling = $(parent).siblings().has(target);
    if (active_sibling.length) $(active_sibling).find(kill_btn).click();
  }
  function iconToggleAction(icon_btn, klass) {
    return $(icon_btn).find("i").hasClass(klass) ? 'collapse' : 'show'
  }
  function iconToggle(icon_btn, classes) {
    $(icon_btn).find("i").toggleClass(classes);
  }
  function toggleVisability(target) {
    $(target).toggleClass("show collapse");
  }
  function showAction(action, parent, parent_target, nav_target, btn_target, kill_btn) {
    if (action=='show'){
      $(parent).find(btn_target).click();
      killSibling(parent, nav_target+":visible", kill_btn)
    } else {
      $(nav_target).find("button").attr('disabled', true);
      $(parent_target).empty();
      if ($(parent_target).is(":visible")) toggleVisability(parent_target);
    }
  }

  function toggleActive(a, active_sibling) {
    if (a.hasClass("active")){
      $(a).removeClass("active");
    } else {
      $(a).addClass("active");
      if (active_sibling.length) $(active_sibling).removeClass("active");
    }
  }

  //utilities ##################################################################
  function sliceTag(attr, i) {
    return attr.split('-')[i]
  }
});
//end ########################################################################

  // $(function(e) {
  //   var content = $(".card-body.item-content > row").html();
  //   if (content != undefined && content.length){
  //     console.log("test");
  //   }
  // });
  //
  // $(function(e) {
  //   var artist_id = $('#hidden_artist_id').val();
  //   if (artist_id != undefined && artist_id.length){
  //     $('.artist-add option[value="'+artist_id+'"]').attr('selected', true);
  //   }
  // });

  // function removeCardSiblings(card) {
  //   $(card).siblings().find(".card-body").empty();
  // }

// not using:

// $("#edit-item-toggle").on("hide.bs.collapse", function(){
//   $("a[href='#edit-item-toggle']").removeClass("active");
// });

// CRUD SHOW: used with aside tabs, see: suppliers/index
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
//
// CRUD SHOW SEARCH: not sure if using these 3
// $("body").on("change", ".artist-search", function(){
//   var v = $(this).val();
//   if (v.length) {
//     $(this).closest("form").submit();
//   } else {
//     $('#show-card > .card').remove();
//   }
// });

// $("body").on("click", ".dropdown a.field-toggle", function(){
//   var target = $(this).attr("href");
//   if ($(target).hasClass("show")){
//     $(target).toggleClass("show collapse");
//   } else {
//     $(target).closest(".toggle-field-group").find(".toggle-field.show").toggleClass("show collapse");
//     $(target).toggleClass("show collapse");
//   }
// });
//
// $("body").on("click", ".collapse-field-btn", function(){
//   $(this).closest(".toggle-field").toggleClass("show collapse");
// });

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
// $("body").on("click", ".unselect-select", function(){
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
