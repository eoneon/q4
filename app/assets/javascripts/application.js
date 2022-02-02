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

  //NAVBAR
  $("body").on("click", "#invoice-nav .nav-link", function(){
    toggleActive($(this), $(this).closest(".navbar-nav").find("a.active"));
  });

  $("body").on("click", ".slide-toggle", function(){
    //var data = navbarData($(this).closest(".navbar"), $(this), {});
    var data = slideToggleData($(this), {}, {}, {});
    console.log(data);
    slideToggle(data);
  });

  $("body").on("click", ".item-nav .nav-btn", function(){
    var data = navbarData($(this).closest(".navbar"), $(this), {});
    //var a = toggleBtnData($(this), {}, {});
    itemNavbarToggle(data, $(this));
  });

  $("body").on("click", "#artist-nav .nav-btn", function(){
    var d = navbarData($(this).closest(".navbar"), $(this), {});
    toggleActive($(this), navToggleSiblings($(this)));
    if (d.btn.context=='show') artistNavbarToggle($(this).closest(".navbar"), d);
  });

  $("body").on("change", "select.artist-search", function(){
    var d = navbarData($(this).closest(".navbar"), $(this), {});
    searchArtistNavbarToggle($(this).closest(".navbar"), d, $(this));
  });

  //FORMS-FIELDS
  $("body").on("keyup, focusin, focusout", ".required", function(){
    requiredFields($(this));
  });

  $("body").on("change", "#title-select", function(){
    var title = $(this).val();
    $("#title-text").val(title);
    $(".title-toggle").toggleClass("show collapse");
  });

  //FORMS-EVENT TRIGGERING SUBMIT
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

  $("body").on("change", "#artist_id, #product_id", function(){
    var id = $(this).val();
    var input = "."+$(this).attr("id");
    toggleInputVal($("#new-title").find(input), id);
    $("#new-title").submit();
  });

  //FORMS-UPDATE-SEARCH item-field
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

  $("#new-skus-toggle, #new-item-skus-toggle").on("hide.bs.collapse", function(){
    var a = $("[href='#"+$(this).attr("id")+"']");
    refreshCaretForm($(a).attr("data-form"), $($(a).attr("data-form")).find(".card"));
    clearInputsOpts("#title-select");
    refreshForm($(a).attr("data-search"));
  });

  //TARGET-TOGGLE
  $("body").on("click", ".list-group-item", function(e){
    var [new_id, form] = [$(this).attr("id"), $(this).attr("data-form")];
    var input = $(form).find($($(this).attr("data-field")));
    toggleSet(input, new_id, $(input).val());
    requiredFields(input);
    toggleTab(new_id, e);
  });

  $("body").on("click", ".toggle-view", function(){
    var toggle_targets = "."+$(this).attr("id");
    $(toggle_targets).toggleClass("show collapse");
  });

  $("a.nav-link.disabled").on("click", function(e){
    e.stopPropagation();
    e.preventDefault();
  });

  //NAVBAR

  //ARTIST-NAVBAR: ADD, EDIT & SEARCH
  function artistNavbarToggle(navbar, d) {
    setNavBrand(navbar, d.brand.span);
    deselectOpt($(d.forms.input));
    setAttrAccess(d.btn_grp.btns, true);
    emptyNavTargets(d.btn_grp.dyno_btns);
  }
  //ARTIST-NAVBAR: UPDATE NAVBAR FROM SEARCH FORM
  function searchArtistNavbarToggle(navbar, d, this_element) {
    var [brand, disable, form_ref] = searchArtistNavbarData(d, this_element);
    hideNavTargets(d.btn_grp.btns);
    emptyNavTargets(d.btn_grp.dyno_btns);
    setNavBrand(navbar, brand);
    setAttrAccess(d.btn_grp.btns, disable);
    if (disable==false) thisForm($(form_ref)).submit();
  }
  function searchArtistNavbarData(d, this_element) {
    var selected = $(this_element).find(":selected").text();
    return selected.length ? [selected, false, this_element] : [d.brand.span, true, false];
  }

  //ITEM-NAVBAR: TABLE-SKUS
  function itemNavbarToggle(data, btn) {
    if (data.card.vis_target == data.btn.vis_target) toggleVisibility(data.btn_grp.parent);
    toggleActive(btn, navToggleSiblings(btn));
  }
  //ITEM-NAVBAR: SLIDE-TOGGLE BTN - TABLE-SKUS
  // function slideToggle(d, btn) {
  //   toggleSlide(btn, d.btn.toggle_target);
  //   if (d.btn.vis_target==false){
  //     //toggleOnSlide(d.card.id, d.card.submit, d.btn.sibling_btn, d.btn.target);
  //     toggleOnSlide(d.card.id, d.card.submit, d.btn.sibling_btn);
  //   } else {
  //     toggleOffSlide($(d.card.id).find(d.card.target), d.card.vis_target, d.btn_grp.btns);
  //   }
  // }
  function slideToggle(d) {
    toggleSlide(d.btn_hsh.this_btn, d.btn_hsh.target);
    if (!d.btn_hsh.vis_target){
      toggleOnSlide(d.btn_hsh.submit, d.btn_hsh.sibling_btn);
    } else {
      toggleOffSlide(d.btn_grp.parent, d.btn_grp.btns);
    }
  }
  function slideToggleData(this_btn, data, btn_hsh, btn_grp) {
    toggleBtnData(this_btn, data, btn_hsh);
    navBtnGrpData(nav_btns(this_btn), data, btn_grp);
    return data;
  }

  function toggleSlide(btn, target) {
    iconToggle(btn, "fa-toggle-on fa-toggle-off");
    toggleVisibility($(target));
  }
  function toggleOnSlide(submit, sibling_btn) {
    $(submit).click();
    toggleOffSlideSibling(sibling_btn);
  }
  function toggleOffSlide(btn_grp_parent, nav_btns) {
    $(nav_btns).removeClass("active").attr('disabled', true);
    $(btn_grp_parent).empty();
    if (isVisible(btn_grp_parent)) toggleVisibility($(btn_grp_parent));
  }
  // function toggleOnSlide(card, submit, active_card, target) {
  //   $(card).find(submit).click();
  //   toggleOffSlideSibling(active_card);
  // }

  function toggleOffSlideSibling(sibling_btn) {
    if (sibling_btn) $(sibling_btn).click();
  }
  // function toggleOffSlide(card_target, vis_target, nav_btns) {
  //   $(nav_btns).removeClass("active").attr('disabled', true);
  //   $(card_target).empty();
  //   if (vis_target==true) toggleVisibility($(card_target));
  // }

  //NAVBAR UTILITY FUNCTIONS
  function emptyNavTargets(nav_btns){
    Array.from($(nav_btns)).forEach(function (nav_btn) {
      $($(nav_btn).attr("data-target")).empty();
    });
  }
  function hideNavTargets(nav_btns){
    Array.from($(nav_btns)).forEach(function (nav_btn) {
      $(nav_btn).removeClass("active");
      hideTarget($($(nav_btn).attr("data-target")));
    });
  }
  function setNavBrand(navbar, brand){
    $(navbar).find(".navbar-brand span").text(brand);
  }
  function formatToggleTarget(parent, target){
    return parent[0]=='#' ? $(target) : $(parent).find(target);
  }

  //NAVBAR-DATA: FOR navbarData
  function navbarData(navbar, this_element, data){
    var nav_data = navbar.data();
    formData(navbar, nav_data, data,{});
    navBrandData(navbar, nav_data, data,{});
    navBtnData(navbar, this_element, data, {});

    //console.log(data.btn_hsh);
    navCardData(nav_data, data, {});
    return navBtnGrpData(navbar, data, {});
  }

  function formData(navbar, nav_data, data, forms){
    if ('form' in nav_data) {
      forms.form = nav_data.form;
      forms.input = nav_data.input;
      data.forms = forms;
    }
    return data;
  }
  function navBrandData(navbar, nav_data, data, brand){
    if ('brand' in nav_data) {
      brand.span = nav_data.brand;
      data.brand = brand
    }
    return data;
  }
  //slideBtnData
  function navBtnData(navbar, this_element, data, btn) {
    if ($(this_element).data("target") && $(this_element).has(".btn")) {
      btn.target = $(this_element).attr("data-target");
      btn.toggle_target = $(navbar).find(btn.target);
      btn.vis_target = isVisible($(navbar).find(btn.target));
      visibleSibling(btn, btn.vis_target, this_element);
      //visibleSiblings(this_element);
      btn.sibling_btn = btn.active_sibling ? siblingToggle(btn.active_sibling) : false
      btn.context = $(this_element).hasClass("static") && !btn.vis_target ? 'show' : false;
      data.btn = btn
    }
    return data;
  }
  // function toggleBtnData(this_btn, data, btn_hsh) {
  //   btn_hsh.id = this_btn.attr("id");
  //   btn_hsh.target = attrVal(this_btn, 'target');
  //   btn_hsh.vis_target = isVisible(btn_hsh.target);
  //   visibleSibling(btn_hsh, btn_hsh.vis_target, this_btn);
  //   //visibleSiblings(this_element);
  //   btn_hsh.context = $(this_btn).hasClass("static") && !btn_hsh.vis_target ? 'show' : false;
  //   data.btn_hsh = $.extend(true, btn_hsh, this_btn.data());
  //   return data
  // }
  function navBtnGrpData(navbar, data, btn_grp){
    btn_grp.btns = $(navbar).find(".nav-btn");
    btn_grp.parent = dataParent(btn_grp.btns);
    btn_grp.dyno_btns = $(btn_grp.btns).filter(".dynamic");
    data.btn_grp = btn_grp;
    return data;
  }

  function navCardData(nav_data, data, card){
    if ('card' in nav_data) {
      card = $(nav_data.card).data();
      card.id = nav_data.card;
      visibleTarget(card, card.id, card.target);
      data.card = card
    }
    return data;
  }
  //new: replaces navBtnGrpData
  function navBtnsData(nav_btns, data, btn_grp){
    btn_grp.btns = nav_btns;
    btn_grp.parent = dataParent(nav_btns);
    btn_grp.dyno_btns = $(nav_btns).filter(".dynamic");
    data.btn_grp = btn_grp;
    return data;
  }
  function toggleBtnData(this_btn, data, btn_hsh) {
    toggleTargetData(this_btn, data, btn_hsh);
    siblingData(btn_hsh, btn_hsh.vis_target, visibleSiblings(this_btn));
    btn_hsh.this_btn = this_btn;
    data.btn_hsh = $.extend(true, btn_hsh, this_btn.data());
    return data
  }
  function toggleTargetData(this_btn, data, btn_hsh) {
    btn_hsh.target = attrVal(this_btn, 'target');
    btn_hsh.vis_target = isVisible(btn_hsh.target);
    return btn_hsh
  }
  function siblingData(obj, vis_target, vis_sibling) {
    if (!vis_target) {
      obj.vis_sibling = vis_sibling;
      obj.sibling_btn = vis_sibling && siblingToggle(vis_sibling);
    }
    return obj;
  }
  //kill
  function visibleTarget(obj, parent, target) {
    if ('target' in obj) obj.vis_target = isVisible($(parent).find(target));
    return obj;
  }
  // function visibleSibling(obj, vis_target, this_element) {
  //   if (vis_target==false) obj.active_sibling = visibleSiblingTarget(this_element);
  //   return obj;
  // }
  function visibleSibling(obj, vis_target, this_element) {
    if (!vis_target) {
      obj.active_sibling = visibleSiblingTarget(this_element);
      obj.sibling_btn = obj.active_sibling && siblingToggle(obj.active_sibling);
    }
    return obj;
  }
  //kill
  function visibleSiblings(btn) {
    var siblings = dataSiblingTargets(btn);
    return siblings ? valid($(siblings).filter(":visible")) : false;
  }
  //GET VISIBLE DATA-SIBLING TARGETS FROM TOGGLE-BTN
  // function visibleSiblingTarget(btn) {
  //   var active_sibling = dataSiblingTargets(btn).filter(":visible");
  //   return active_sibling.length ? active_sibling : false;
  // }

  //GET data-parent obj from given toggle-btn(s)
  function dataParent(toggle_btn){
    return attrVal(toggle_btn, 'target').attr("data-parent");
  }
  //GET all toggle-targets of a toggle-btn's data-parent
  function dataTargets(btn) {
    return dataAttrVal('parent', dataParent(btn));
  }
  //GET sibling targets from data-targets (exclude clicked toggle-btn) sibling-targets || false
  function dataSiblingTargets(toggle_btn) {
    var targets = valid(dataTargets(toggle_btn));
    return targets ? $(targets).not(attrVal(toggle_btn, 'target')) : false;
  }
  //GET visible sibling target
  function visibleSiblingTarget(toggle_btn) {
    var sibling_targets = dataSiblingTargets(toggle_btn);
    return sibling_targets ? valid($(sibling_targets).filter(":visible")) : false;
  }
  //GET sibling toggle btn from visible sibling target in order to toggle-off: `$(sibling_btn).click();`
  function siblingToggle(sibling_target) {
    return dataAttr('target', "#"+$(sibling_target).attr("id"));
  }

  //ATTR FUNCTIONS
  function dataAttrVal(attr, tag) {
    return $(dataAttr(attr, tag));
  }
  function dataAttr(attr, tag) {
    return "[data-"+attr+"='"+tag+"']";
  }
  function attrVal(ref, attr) {
    return $(attrTag(ref, attr));
  }
  function attrTag(ref, attr) {
    return $(ref).attr("data-"+attr);
  }

  //GET NAV-BTNS FROM MEMBER
  function navToggleBtns(a) {
    return $(a).closest(".nav-toggle").find(".nav-btn");
  }
  //GET SIBLING NAV-BTNS FROM MEMBER
  function navToggleSiblings(a) {
    return $(navToggleBtns(a)).not(a);
  }
  //TOGGLE-CLASSES

  //TOGGLE-CLASS - ACTIVE (BINARY)
  function toggleActive(a, sibling) {
    var state = toggleIntraClass(a, "active");
    if (state==true) $(sibling).removeClass("active");
  }
  //TOGGLE CLASS (BINARY)
  function toggleIntraClass(target, klass) {
    $(target).hasClass(klass) ? $(target).removeClass(klass) : $(target).addClass(klass)
    return $(target).hasClass(klass) ? true : false
  }
  //TOGGLE-TAB & SIBLINGS CLASS - ACTIVE
  function toggleTab(id, e) {
    if ($('#'+id).hasClass("active")) {
      e.stopPropagation();
      e.preventDefault();
      $('#'+id).removeClass("active");
    }
  }
  //TOGGLE-CLASSES - SHOW/COLLAPSE
  function toggleVisibility(target) {
    $(target).toggleClass("show collapse");
  }
  //TOGGLE-ICON CLASSES
  function iconToggle(icon_btn, classes) {
    $(icon_btn).find("i").toggleClass(classes);
  }

  //TOGGLE SHOW/COLLAPSE

  //DETECT & RETURN VISIBLE TOGGLE SIBLING
  function siblingWithVisibleTarget(parent, target) {
    var active_sibling = $(parent).siblings().has(target+":visible");
    return active_sibling.length ? active_sibling : false;
  }
  function hideTarget(target) {
    if (isVisible($(target))) $(target).removeClass("show");
  }
  function isVisible(target) {
    return $(target).is(":visible");
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
  function iconToggleAction(icon_btn, klass) {
    return $(icon_btn).find("i").hasClass(klass) ? 'collapse' : 'show'
  }

  //forms
  function refreshForm(target) {
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
  function nav_btns(this_btn) {
    return $(this_btn).closest(".navbar").find(".nav-btn");
  }
  function sliceTag(attr, i) {
    return attr.split('-')[i]
  }
  function valid(val) {
    return val != undefined && val.length ? val : false;
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
