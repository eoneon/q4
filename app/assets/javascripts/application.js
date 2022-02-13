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
    if ($(this).find("i").length) caretToggle(toggleBtnData($(this),{}));
  });

  //NAVBAR
  $("body").on("click", "#invoice-nav .nav-link", function(){
    toggleActive($(this), $(this).closest(".navbar-nav").find("a.active"));
  });

  $("body").on("click", ".slide-toggle", function(){
    slideToggle(slideToggleData($(this), {}));
  });

  $("body").on("click", ".item-nav .nav-btn", function(){
    itemNavbarToggle(toggleBtnData($(this), {}));
  });

  $("body").on("click", "#artist-nav .nav-btn", function(){
    var d = artistNavData($(this), {});
    toggleActive($(this), navToggleSiblings($(this)));
    if (d.btn.static && !d.btn.vis_target) refreshArtistNavbar(d);
  });

  $("body").on("change", "select.artist-search", function(){
    updateArtistNavbar(updateArtistNavbarData($(this), {}));
  });

  //FORMS-FIELDS
  $("body").on("keyup, focusin, focusout", ".required", function(){
    requiredFields($(this));
  });

  // [batch_items/form, items/title], [skus/form, items/title]
  $("body").on("change", "#title-select", function(){
    updateTitleInput(inputGroupData($(this)), $(this).val());
  });

  //FORMS-EVENT TRIGGERING SUBMIT
  $("body").on("change", "select.search-select", function(){
    thisForm($(this)).submit();
  });

  //FORMS-EVENT TRIGGERING SUBMIT
  $("body").on("change", ".field-param", function(){
    if (sliceTag(thisForm($(this)).attr("id"), 0) == 'edit') thisForm($(this)).submit();
  });

  $("body").on("focusout", ".input-field", function(){
    thisForm($(this)).submit();
  });

  // [skus/form, items/title], [batch_items/form, items/title],
  // $("body").on("change", ".artist-select, .product-select", function(){
  //   updateTitleForm(searchGroupData($(this)));
  // });
  $("body").on("change", ".new-item-select-artist", function(){
    newItemSelectArtist(searchData($(this))); //updateTitleForm(searchGroupData($(this)));
  });

  $("body").on("click", ".new-item-unselect-artist", function(){
    newItemUnselectArtist(searchData($(this)));
  });

  $("body").on("change", "#artist_id, #product_id", function(){
    var id = $(this).val();
    var input = "."+$(this).attr("id");
    toggleInputVal($("#new-title").find(input), id);
    $("#new-title").submit();
  });

  //FORMS-UPDATE-SEARCH
  //for table-skus items: based on changing product selection: item_products/forms/search
  $("body").on("change", ".update-search", function(){
    updateProductSearch(searchGroupData($(this)));
  });
  //for table-skus items: based on clicking reset_search: item_products/forms/search
  $("body").on("click", ".deselect", function(){
    updateProductSearch(searchGroupData($(this)));
  });

  //items#search
  $("body").on("click", ".unselect", function(){
    deselectSelectedOpt(inputGroup($(this)));
    thisForm($(this)).submit();
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

  $("a.nav-link.disabled, button.disabled").on("click", function(e){
    e.stopPropagation();
    e.preventDefault();
  });

  //NAVBAR

  //ITEM-NAVBAR: SLIDE-TOGGLE BTN - TABLE-SKUS
  function slideToggle(d) {
    toggleSlide(d.btn.this_btn, d.btn.target);
    if (!d.btn.vis_target){
      toggleOnSlide(d.btn.submit, d.btn.sibling.this_btn);
    } else {
      toggleOffSlide(d.nav_grp.parent, d.nav_grp.btns);
    }
  }
  function slideToggleData(this_btn, data) {
    toggleBtnData(this_btn, data);
    navBtnData(nav_btns(this_btn), data);
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
  function toggleOffSlideSibling(sibling_btn) {
    if (sibling_btn) $(sibling_btn).click();
  }

  //ITEM-NAVBAR: TABLE-SKUS
  function itemNavbarToggle(d) {
    if (!d.btn.vis_target && !isVisible(d.btn.parent) || d.btn.vis_target) toggleVisibility(d.btn.parent);
    toggleActive(d.btn.this_btn, navToggleSiblings(d.btn.this_btn));
  }

  //ARTIST-NAVBAR: from NAVBAR NAV-BTNS
  function refreshArtistNavbar(d) {
    setNavBrand(d.nav.navbar, d.nav.brand);
    deselectOpt($(d.nav.input));
    setAttrAccess(d.nav_grp.btns, true);
    emptyNavTargets(d.nav_grp.dyno_btns);
  }
  //ARTIST-NAVBAR: from NAVBAR ARTIST SEARCH
  function updateArtistNavbar(d) {
    hideNavTargets(d.nav_grp.btns);
    emptyNavTargets(d.nav_grp.dyno_btns);
    setNavBrand(d.nav.navbar, d.brand);
    setAttrAccess(d.nav_grp.btns, d.nav_grp.disable);
    if (!d.nav_grp.disable) thisForm($(d.nav.form)).submit();
  }

  //NAVBAR UTILITY FUNCTIONS
  function setNavBrand(navbar, brand){
    $(navbar).find(".navbar-brand span").text(brand);
  }
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

  //CONTEXT-SPECIFIC DATA FUNCTIONS

  //ARTIST-NAVBAR: from NAVBAR NAV-BTNS
  function artistNavData(this_btn, d) {
    navData(this_btn, d);
    toggleTargetData(this_btn, d);
    navBtnData(nav_btns(this_btn), d);
    return d;
  }
  //ARTIST-NAVBAR: from NAVBAR ARTIST SEARCH
  function artistSearchData(selected, d) {
    var [brand, disable] = selected.length ? [selected, false] : [d.nav.brand, true];
    d.brand = brand;
    d.nav_grp.disable = disable;
    return d;
  }
  function updateArtistNavbarData(search_field, d) {
    artistNavData(search_field, d);
    artistSearchData(selectedOpt(search_field).text(), d);
    return d;
  }

  //ELEMENT-SPECIFIC DATA FUNCTION
  function navData(this_btn, d) {
    d.nav = navbar(this_btn).data();
    d.nav.navbar = navbar(this_btn);
    return d;
  }
  function navBtnData(nav_btns, d){
    d.nav_grp = {btns: nav_btns, parent: dataParent(nav_btns), dyno_btns: $(nav_btns).filter(".dynamic")};
    return d;
  }
  //ELEMENT-SPECIFIC: TOGGLE-DATA: from SLIDE, NAV-BTN or CARET
  function toggleBtnData(this_btn, d) {
    toggleTargetData(this_btn, d);
    siblingData(d.btn.vis_target, valid(visibleDataSiblingTarget(this_btn)), d.btn);
    d.btn.this_btn = this_btn;
    d.btn = $.extend(true, d.btn, this_btn.data());
    return d
  }
  function toggleTargetData(this_btn, d) {
    d.btn = {parent: dataParent(this_btn), target: attrObj(this_btn, 'target'), static: $(this_btn).hasClass("static")};
    d.btn.vis_target = isVisible(d.btn.target);
    return d
  }
  function siblingData(vis_target, vis_sibling, btn) {
    btn.sibling = {vis_target: vis_sibling, this_btn: vis_sibling && siblingToggle(vis_sibling)};
    return btn;
  }

  //GET data-parent obj from given toggle-btn(s)
  function dataParent(toggle_btn){
    return attrObj(toggle_btn, 'target').attr("data-parent");
  }
  //GET all toggle-targets of a toggle-btn's data-parent
  function dataTargets(btn) {
    return dataObj('parent', dataParent(btn));
  }
  //GET sibling targets from data-targets (exclude clicked toggle-btn) sibling-targets || false
  function dataSiblingTargets(toggle_btn) {
    var targets = valid(dataTargets(toggle_btn));
    return targets ? $(targets).not(attrObj(toggle_btn, 'target')) : false;
  }
  //GET visible sibling target
  function visibleDataSiblingTarget(toggle_btn) {
    var sibling_targets = dataSiblingTargets(toggle_btn);
    return sibling_targets ? valid($(sibling_targets).filter(":visible")) : false;
  }
  //GET sibling toggle btn from visible sibling target in order to toggle-off: `$(sibling_btn).click();`
  function siblingToggle(sibling_target) {
    return dataAttr('target', "#"+$(sibling_target).attr("id"));
  }

  //ATTR FUNCTIONS
  function dataObj(attr, tag) {
    return $(dataAttr(attr, tag));
  }
  function dataAttr(attr, tag) {
    return "[data-"+attr+"='"+tag+"']";
  }
  function hrefObj(id) {
    return hrefAttr(id);
  }
  function hrefAttr(id) {
    return "[href='#"+id+"']";
  }
  function attrObj(ref, attr) {
    return $(attrTag(ref, attr));
  }
  function attrTag(ref, attr) {
    return $(ref).attr("data-"+attr);
  }

  //TOGGLE-CLASSES

  //TOGGLE-CLASS - ACTIVE (BINARY)
  function toggleActive(a, sibling) {
    var state = toggleIntraClass(a, "active");
    if (state==true) $(sibling).removeClass("active");
  }
  //TOGGLE CLASS (BINARY)
  function toggleIntraClass(target, klass) {
    $(target).hasClass(klass) ? $(target).removeClass(klass) : $(target).addClass(klass);
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
  function hideTarget(target) {
    if (isVisible($(target))) $(target).removeClass("show");
  }
  function isVisible(target) {
    return $(target).is(":visible");
  }

  //toggle current caret-icon & card-body ######################################
  function caretToggle(d) {
    toggleSet(d.btn.this_btn, $(d.btn.this_btn).attr("id"), $(d.btn.input).val());
    toggleCard(d.btn.this_btn, d.btn.target);
    if (d.btn.sibling.vis_target) toggleCard(d.btn.sibling.this_btn, d.btn.sibling.vis_target);
  }
  function toggleCard(caret_btn, target) {
    iconToggle(caret_btn,"fa-caret-right fa-caret-down")
    toggleVisibility(target);
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
  function toggleInputVal(input, value) {
    $(input).val(value.length ? value : "");
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

  //MANIPULATE SELECTED OPTION
  function setInputVals(input_sets){
    Array.from(input_sets).forEach(function (input_set) { $(input_set[0]).val(input_set[1]); });
  }
  function deselectSelected(inputs){
    Array.from($(inputs)).forEach(function (input) { if (valid(input)) deselect(input); });
  }
  function submitForms(forms){
    Array.from(forms).forEach(function (form) { $(form).submit(); });
  }
  function getSelectedInputs(input_parent, input_target){
    return $(input_parent).find(input_target).not(function() { return $(this).val() == ""; });
  }
  function deselect(input){
    $(input).is('select') ? deselectOpt(input) : deselectInput(input);
  }
  function deselectOpt(select){
    $(select).attr('selected', false);
    deselectInput(select);
  }
  function deselectInput(input) {
    $(input).val("");
  }

  //kill?
  function deselectSelectedOpt(ref){
    deselectOpt(selectedOpt(ref));
  }
  function selectedOpt(ref){
    return $(ref).find(":selected");
  }

  //form #######################################################################
  function newItemUnselectArtist(d){
    deselectSelected([$(d.searchForm).find(d.artistInput), $(d.titleForm).find(d.artistInput), $(d.itemForm).find(d.artistInput), $(d.itemForm).find(d.titleInput)].flat());
    submitForms([d.searchForm, d.titleForm]);
  }
  function refreshCaretForm(form, card) {
    clearInputs(form);
    if ($($(card).attr("data-target")).is(":visible")) toggleCard($(card).find(".caret-toggle"), $(card).find($(card).attr("data-target")));
  }
  function updateTitleForm(d) {
    toggleInputVal($(d.form).find(d.input), d.val); //title
    toggleInputVal($(d.context).find(d.input), d.val); //item-create
    toggleInputVal($(d.form).find(".context"), d.context); //title
    $(d.form).submit(); //title
  }
  function newItemSelectArtist(d){
    //toggleInputVals([[$(d.itemForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.artistInput)], [$(d.titleForm).find(d.context_input), d.itemForm]]);
    //$.each([[$(d.itemForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.context_input), d.itemForm]], function(i, set) { $(set[0]).val(set[1]) });
    setInputVals([[$(d.itemForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.context_input), d.itemForm]])
    // toggleInputVal($(d.itemForm).find(d.artistInput), d.selected);
    // toggleInputVal($(d.titleForm).find(d.artistInput), d.selected);
    // toggleInputVal($(d.titleForm).find(d.context_input), d.itemForm);
    submitForms([d.searchForm, d.titleForm]);
  }
  function updateTitleInput(d, val){
    $(d.input_grp).find(d.input).val(val);
    toggleVisibility($(d.input_grp).find(d.target));
  }
  //CONTEXT-SPECIFIC get DATA and DO ###########################################
  function updateProductSearch(d) {
    $(d.form).find(d.input).val(d.val);
    $(d.form).submit();
  }
  function searchGroupData(thisElement) {
    var d = inputGroupData(thisElement);
    d.val = $(thisElement).is("select") ? $(thisElement).val() : "";
    return d;
  }
  function searchData(thisElement) {
    var d = buildData(inputGroupData(thisElement).obj);
    d.selected = $(thisElement).val();
    return d;
  }
  //ELEMENT-SPECIFIC: get common elements by pattern utilities #################
  function inputGroupData(ref) {
    var d =  $(inputGroup(ref)).data();
    d.input_grp = inputGroup(ref);
    return d;
  }
  function inputGroup(ref) {
    return $(ref).closest(".input-group");
  }
  function navbar(this_btn) {
    return $(this_btn).closest(".navbar");
  }
  function nav_btns(this_btn) {
    return $(navbar(this_btn)).find(".nav-btn");
  }
  //GET NAV-BTNS FROM MEMBER
  function navToggleBtns(a) {
    return $(a).closest(".nav-toggle").find(".nav-btn");
  }
  //GET SIBLING NAV-BTNS FROM MEMBER
  function navToggleSiblings(a) {
    return $(navToggleBtns(a)).not(a);
  }

  //utilities ##################################################################
  function formatToggleTarget(parent, target){
    return parent[0]=='#' ? $(target) : $(parent).find(target);
  }
  function sliceTag(attr, i) {
    return attr.split('-')[i]
  }
  function valid(val) {
    return val != undefined && val.length ? val : false;
  }

  //test
  function buildData(obj) {
    var [keys, vals] = splitArray(obj.split(','));
    //console.log([keys, vals])
    return arrToObj(keys, vals);
  }

  function arrToObj(keys, vals, obj={}){
    Array.from(keys).forEach(function (k) {
      obj[k]= vals[keys.indexOf(k)];
    });
    return obj;
  }
  function splitArray(arr, even=[], odd=[]) {
    for(var i=0; i<arr.length; i++)
        (i % 2 == 0 ? even : odd).push(arr[i].trim());
    return [even, odd];
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
