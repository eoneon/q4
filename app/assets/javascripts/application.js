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

  // $("body").on("click", ".slide-toggle", function(){
  //   var [action, parent, nav_target] = [iconToggleAction($(this), "fa-toggle-on"), $(this).attr("data-parent"), $(this).attr("data-target")];
  //   showAction(action, parent, $(parent).attr("data-target"), nav_target, $(this).attr("data-show-target"), ".slide-toggle");
  //   iconToggle($(this), "fa-toggle-on fa-toggle-off");
  //   toggleVisibility($(parent).find(nav_target));
  // });
  $("body").on("click", ".slide-toggle", function(){
    //var data = navbarDataTest($(this).closest(".navbar"), $(this));
    var data2 = navbarDataTestTwo($(this).closest(".navbar"), $(this), {})
    console.log(data2)
    slideToggle(data2, $(this), ".slide-toggle");
    //toggleSlide($(this), data2.btn.target);
  });


  // $("body").on("click", ".slide-toggle", function(){
  //   var [action, parent, nav_target] = [iconToggleAction($(this), "fa-toggle-on"), $(this).attr("data-parent"), $(this).attr("data-target")];
  //   var test = navbarDataTest($(this).closest(".navbar"), $(this));
  //   console.log(test);
  //   showAction(action, parent, $(parent).attr("data-target"), nav_target, $(this).attr("data-show-target"), ".slide-toggle");
  //   iconToggle($(this), "fa-toggle-on fa-toggle-off");
  //   toggleVisibility($(parent).find(nav_target));
  // });

  $("body").on("click", ".item-nav .nav-btn", function(){
    //var h = navbarData($(this).closest(".navbar"));
    var data = navbarDataTestTwo($(this).closest(".navbar"), $(this), {});
    console.log(data);
    //if (isVisible(h.parent) == isVisible($(this).attr("data-target"))) toggleVisibility(h.parent);
    if (isVisible(data.nav_toggle.parent) == isVisible(data.btn.target)) toggleVisibility(data.nav_toggle.parent);
    toggleActive($(this), navToggleSiblings($(this)));
  });

  $("body").on("click", "#invoice-nav .nav-link", function(){
    toggleActive($(this), $(this).closest(".navbar-nav").find("a.active"));
  });

  $("body").on("click", "#artist-nav .nav-btn", function(){
    var h = navbarData($(this).closest(".navbar"));
    toggleActive($(this), navToggleSiblings($(this)));
    if (showingStaticTarget($(this))){
      $(h.span).text(h.spanVal);
      deselectOpt($(h.input));
      setAttrAccess(h.nav_btns, true);
      emptyNavTargets(h.nav_btns, '.dynamic');
    }
  });

  $("body").on("change", "select.artist-search", function(){
    var [h, selected] = [navbarData($(this).closest(".navbar")), $(this).find(":selected").text()];
    var [span_val, disable] = selected.length ? [selected, false] : [h.spanVal, true]
    hideNavTargets(h.nav_btns,'.nav-btn');
    emptyNavTargets(h.nav_btns, '.dynamic');
    $(h.nav_btns).removeClass("active");
    $(h.span).text(span_val);
    setAttrAccess(h.nav_btns, disable);
    if (disable==false) thisForm($(this)).submit();
  });

  //forms
  $("body").on("keyup, focusin, focusout", ".required", function(){
    requiredFields($(this));
  });

  //edit-form submission: UPDATE select field and submit form
  $("body").on("change", "select.search-select, .field-param", function(){
    thisForm($(this)).submit();
  });

  $("body").on("focusout", ".input-field", function(){
    thisForm($(this)).submit();
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


  //item-field
  $("body").on("change", ".update-search", function(){
    setValByInputName(inputGroupData($(this), "data-input"), $(this).val());
    $(inputGroupData($(this), "data-form")).submit();
  });

  //items#search
  $("body").on("click", ".deselect", function(){
    setValByInputName(inputGroupData($(this), "data-input"), "");
    $(inputGroupData($(this), "data-form")).submit();
  });

  //items#search
  $("body").on("click", ".unselect", function(){
    $(this).closest(".input-group").find(":selected").attr('selected', false);
    $(inputGroupData($(this), "data-form")).submit();
  });

  $("body").on("click", ".list-group-item", function(e){
    var [new_id, form] = [$(this).attr("id"), $(this).attr("data-form")];
    var input = $(form).find($($(this).attr("data-field")));
    toggleSet(input, new_id, $(input).val());
    requiredFields(input);
    toggleTab(new_id, e);
  });

  $("#new-skus-toggle, #new-item-skus-toggle").on("hide.bs.collapse", function(){
    var a = $("[href='#"+$(this).attr("id")+"']");
    refreshCaretForm($(a).attr("data-form"), $($(a).attr("data-form")).find(".card"));
    clearInputsOpts("#title-select");
    refreshSearchForm($(a).attr("data-search"));
  });

  $("a.nav-link.disabled").on("click", function(e){
    e.stopPropagation();
    e.preventDefault();
  });

  //navbar
  function navToggleBtns(a) {
    return $(a).closest(".nav-toggle").find(".nav-btn");
  }
  function navToggleSiblings(a) {
    return $(navToggleBtns(a)).not(a);
  }

  function navbarData(navbar) {
    var data = $(navbar).data();
    data.nav_btns = $(navbar).find(".nav-btn");
    return data;
  }

  function emptyNavTargets(ref, scope){
    Array.from($(ref).filter(scope)).forEach(function (nav_btn) {
      $($(nav_btn).attr("data-target")).empty();
    });
  }
  function hideNavTargets(ref, scope){
    Array.from($(ref).filter(scope)).forEach(function (nav_btn) {
      hideTarget($($(nav_btn).attr("data-target")));
    });
  }

  function navTargetDataParentTag(nav_btns){
    return $($(nav_btns).attr("data-target")).attr("data-parent");
  }
  function dataParentTargets(parent) {
    return $(parent).find("[data-parent='"+parent+"']");
  }

  function showingStaticTarget(btn) {
    return $(btn).hasClass("static") && !isVisible($(btn).attr("data-target"))
  }
  function toggleActive(a, sibling) {
    var state = toggleIntraClass(a, "active");
    if (state==true)  $(sibling).removeClass("active");
  }

  function toggleIntraClass(target, klass) {
    $(target).hasClass(klass) ? $(target).removeClass(klass) : $(target).addClass(klass)
    return $(target).hasClass(klass) ? true : false
  }

  //aside/tabs
  function toggleTab(id, e) {
    if ($('#'+id).hasClass("active")) {
      e.stopPropagation();
      e.preventDefault();
      $('#'+id).removeClass("active");
    }
  }

  //navbar => new
  function slideToggle(h, btn, btn_tag) {
    toggleSlide(btn, h.btn.toggle_target);
    if (h.btn.vis_target==false){
      toggleOnSlide(h.card.id, h.card.submit, h.btn.active_sibling, h.btn.target, btn_tag);
    } else {
      //toggleOffSlide($(h.card.id).find(h.card.target), h.nav_toggle.btns);
      toggleOffSlide($(h.card.id).find(h.card.target), h.card.vis_target, h.nav_toggle.btns);
    }
  }

  // function slideToggle(data, btn, btn_tag) {
  //   toggleSlide(btn, data.toggle_target);
  //   if (data.vis_target==false){
  //     //console.log(data.active_card)
  //     toggleOnSlide(data.card, data.submit, data.active_card, data.target_tag, btn_tag);
  //   } else {
  //     toggleOffSlide(data.card_target, data.nav_btns);
  //   }
  // }

  function toggleSlide(btn, target) {
    iconToggle(btn, "fa-toggle-on fa-toggle-off");
    toggleVisibility($(target));
  }
  function toggleOnSlide(card, submit, active_card, target, btn) {
    $(card).find(submit).click();
    toggleOffSlideSibling(active_card, btn);
  }
  // function toggleOffSlideSibling(card, target, btn) {
  //   var active_card = $(card).siblings().has(target);
  //   if (active_card.length) $(active_card).find(btn).click();
  // }

  function toggleOffSlideSibling(active_card, btn) {
    if (active_card.length) $(active_card).find(btn).click();
  }
  function toggleOffSlide(card_target, vis_target, nav_btns) {
    $(nav_btns).attr('disabled', true);
    $(card_target).empty();
    if (vis_target==true) toggleVisibility($(card_target));
    //hideTarget($(card_target));
  }

  function navbarDataTest(navbar, this_element) {
    var data = $(navbar).data();
    data.nav_btns = $(navbar).find(".nav-btn");
    return navbarDataOpts(navbar, data, this_element);
  }

  function navbarDataOpts(navbar, data, this_element){
    if ($(this_element).has(".btn")){
      data.target_tag = $(this_element).attr("data-target");
      data.toggle_target = $(navbar).find(data.target_tag);
      data.vis_target = isVisible(data.toggle_target);
      //data.slide_target = $(data.card)find(data.target);
      if (data.vis_target==false) {
        data.active_card = siblingWithVisibleTarget(data.card, data.target_tag);
        //console.log(data.target_tag)
      } else {
        data.card_target = $(data.card).attr("data-target");
      }
    }
    return data;
  }

  function navbarDataTestTwo(navbar, this_element, data) {
    navCardData($(navbar).data(), data, {});
    //data.nav_btns = $(navbar).find(".nav-btn");
    navToggleData(navbar, data, {});
    return navTargetData(navbar, this_element, data, {});
  }

  function navCardData(navbar_data, data, card){
    if ('card' in navbar_data) {
      card = $(navbar_data.card).data();
      card.id = navbar_data.card;
      if ('target' in card) card.vis_target = isVisible($(card.id).find(card.target));
      data.card = card
    }
    return data;
  }

  function navToggleData(navbar, data, nav_toggle){
    nav_toggle.btns = $(navbar).find(".nav-btn");
    // console.log(navTargetDataParentTag(nav_toggle.btns));
    nav_toggle.parent = navTargetDataParentTag(nav_toggle.btns);
    data.nav_toggle = nav_toggle;
    return data;
  }

  function navTargetData(navbar, this_element, data, btn){
    if ($(this_element).data("target") && $(this_element).has(".btn")) {
      btn.target = $(this_element).attr("data-target");
      btn.toggle_target = $(navbar).find(btn.target);
      btn.vis_target = isVisible(btn.toggle_target);
      //btn.vis_target = isVisible($(navbar).find(btn.target));
      if (btn.vis_target==false) btn.active_sibling = siblingWithVisibleTarget(data.card.id, btn.target);
      data.btn = btn
    }
    return data;
  }
  //end navbar

  //show/collapse
  function siblingWithVisibleTarget(parent, target) {
    var active_sibling = $(parent).siblings().has(target+":visible");
    return active_sibling.length ? active_sibling : false;
  }
  function hideTarget(target) {
    if (isVisible($(target))) $(target).removeClass("show");
    //if (isVisible($(target))) $(target).toggleClass("show collapse");
  }
  function toggleVisibility(target) {
    $(target).toggleClass("show collapse");
  }
  function isVisible(target) {
    return $(target).is(":visible");
    //return $(target).is(":visible") ? target : false;
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
    toggleVisibility(target);
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

  function showAction(action, parent, parent_target, nav_target, btn_target, kill_btn) {
    if (action=='show'){
      $(parent).find(btn_target).click();
      killSibling(parent, nav_target+":visible", kill_btn)
    } else {
      $(nav_target).find("button").attr('disabled', true);
      $(parent_target).empty();
      if ($(parent_target).is(":visible")) toggleVisibility(parent_target);
    }
  }

  //forms
  function refreshSearchForm(target) {
    clearInputs(target);
    $(target).submit();
  }
  function thisFormItem(ref, target) {
    return $(thisForm(ref)).find(target);
  }
  function thisForm(ref) {
    return $(ref).closest("form");
  }

  //form inputs
  function setValByInputName(input_name, value) {
    $('input[name="'+input_name+'"]').val(value);
  }
  function clearInputs(target) {
    $(target + " :input").val("");
  }
  function clearInputsOpts(target) {
    $(target + " option:first").siblings().remove();
  }
  function requiredFields(input) {
    var emptyFields = $(thisFormItem($(input), ".required")).filter(function() {return $(this).val() == "";});
    var submit = thisFormItem($(input), ".submit-btn");
    if (emptyFields.length==0){
      $(submit).removeAttr('disabled');
    } else {
      $(submit).attr('disabled', 'disabled');
    }
  }
  function toggleInputVal(inputs, value) {
    var val = value.length ? value : ""
    $(inputs).val(value);
  }
  function toggleSet(input, new_id, old_id) {
    $(input).val(toggleVal(new_id, old_id));
  }
  function toggleVal(new_id, old_id) {
    return new_id == old_id ? "" : new_id
  }
  function setAttrAccess(elements, access) {
    $(elements).filter(".disable").attr("disabled", access);
  }
  function deselectOpt(select){
    $(select).attr('selected', false);
    $(select).val("");
  }
  function inputGroupData(ref, data) {
    return $(ref).closest(".input-group").attr(data);
  }
  //form #######################################################################
  function refreshCaretForm(form, card) {
    clearInputs(form);
    if ($($(card).attr("data-target")).is(":visible")) toggleCard($(card).find(".caret-toggle"), $(card).find($(card).attr("data-target")));
  }

  //utilities ##################################################################
  function sliceTag(attr, i) {
    return attr.split('-')[i]
  }
});
//end ########################################################################

  //what is this?
  // $("body").on("click", ".search-btn", function(){
  //   $('#new-skus').find(":selected").attr('selected', false);
  //   $('#new-skus').find(":input").val("");
  // });
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

// not using:

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

// old methods for reference

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
