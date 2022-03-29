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
    toggleActive($(this), $(this).closest(".navbar-nav").find("a.active")); //navbar($(this))
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

  //FORMS-SUBMIT: GET search-product
  // $("body").on("change", ".new-item-select-product", function(){
  //   newItemSelectProduct(searchData($(this)));
  // });
  //FORMS-SUBMIT: GET search-artist
  $("body").on("change", ".search.new.item.artist", function(){
    newItemSelectArtist(searchData($(this)));
  });
  $("body").on("click", ".new-item-unselect-artist", function(){
    newItemUnselectArtist(searchData($(this)));
  });
  $("body").on("change", "select.artist-search", function(){
    updateArtistNavbar(updateArtistNavbarData($(this), {}));
  });

  $("body").on("click", ".new-item-unselect-product", function(){
    newItemUnselectProduct(searchData($(this)));
  });

  //FORMS-SUBMIT: GET @titles
  $("body").on("change", "#title-select", function(){
    updateTitleInput(inputGroupData($(this)), $(this).val());
  });

  //FORMS-SUBMIT: GET search-hattrs
  // $("body").on("change", "table-product-select", function(){
  //   thisForm($(this)).submit();
  // });

  // $("body").on("change", "select.search-select", function(){
  //   if ($(this).val().length && ['category_search', 'medium_search', 'material_search'].includes($(this).attr("id"))) {
  //     var form = thisForm($(this));
  //     var product_select = $(form).find(".product");
  //     if ($(form).attr("id") == "search-skus") {
  //       newItemUnselectProduct(searchData(product_select));
  //     } else if ($(form).attr("id") == "search-item-skus") {
  //       deselectSelectedOpt(inputGroup(product_select));
  //       $(form).submit();
  //     } else {
  //       editItemUnselectProduct(searchData($(form).find(".edit-item-select-product")));
  //     }
  //   } else {
  //     thisForm($(this)).submit();
  //   }
  // });

  $("body").on("change", ".hattrs .category, .hattrs .medium, .hattrs .material", function() {
    var product = thisForm($(this)).find(".product");
    if ( $(this).val().length && valid($(product).val()) ) clearProductSearchInputs($(this), product, $(searchData(product).itemForm).find(".product"));
    thisForm($(this)).submit();
  });

  // function clearProductSearchInputs(this_input, product, new_product) {
  //   var inputs = $(this_input).has(".category") ? thisForm(this_input).find(".product, .medium, .material").concat(new_product) : product.concat(new_product);
  //   deselectSelected(inputs)
  // }

  //HERE: REMOVE MERGE: ONLY clear product_ids
  function clearProductSearchInputs(this_input, product, new_product) {
    //deselectSelected($(this_input).hasClass("category") ? $.merge(thisForm(this_input).find(".medium, .material"), product) : product)
    deselect(product);
    deselect(new_product);
  }

  // $("body").on("change", ".table.hattrs .category, .table.hattrs .medium, .table.hattrs .material", function() {
  // 	var product_select = thisForm($(this)).find(".product");
  // 	if ( $(this).val().length && valid($(product_select).val()) ) {
  //     var d = searchData($(thisForm($(this))).find(".table-product"));
  //     if ($(this).hasClass("category")) deselectSelected(thisForm($(this)).find(".medium, .material"))
  //     deselectSelected([product_select,$(d.itemForm).find(d.productInput)])
  // 	}
  //   thisForm($(this)).submit();
  // });

  $("body").on("change", ".new-item-select-product, .table-product", function(){
    var d = searchData($(this));
    $(d.itemForm).find(d.productInput).val(d.selected);
    thisForm($(this)).submit();
  });

  // $("body").on("change", "select.search-select", function(){
  //   var form = thisForm($(this));
  //   var product_select = $(form).find(".product");
  //   if ( $(this).val().length && ['category_search', 'medium_search', 'material_search'].includes($(this).attr("id")) && valid($(product_select).val()) ) {
  //     if ($(form).attr("id") == "search-skus") {
  //       newItemUnselectProduct(searchData(product_select));
  //     } else if ($(form).attr("id") == "search-item-skus") {
  // 	    deselectSelectedOpt(inputGroup(product_select));
  // 	    $(form).submit();
  //     } //else {
  //       // deselect(product_select)
  //       // $(form).submit();
  // 	    //editItemUnselectProduct(searchData($(form).find(".edit-item-select-product")));
  //     //}
  //   } else {
  //     $(form).submit();
  //   }
  // });
  //
  // $("body").on("change", "select.search-select", function(){
  //   if ($(this).val().length && ['category_search', 'medium_search', 'material_search'].includes($(this).attr("id"))) {
  //     //var ref = thisForm($(this)).find(".new-item-select-product");
  //     var form = thisForm($(this));
  //     var product_select = $(form).find(".product");
  //     if ($(form).attr("id") == "search-skus") {
  //       newItemUnselectProduct(searchData(product_select));
  //     } else {
  //       deselectSelectedOpt(inputGroup(product_select));
  //       $(form).submit();
  //     }
  //   } else {
  //     thisForm($(this)).submit();
  //   }
  // });

  $("body").on("click", ".unselect", function(){
    deselectSelectedOpt(inputGroup($(this)));
    thisForm($(this)).submit();
  });
  //FORMS-SUBMIT: POST deselect($(d.itemForm).find(d.productInput))
  // $("body").on("change", ".edit-item-select-product", function(){
  //   editItemSelectProduct(searchData($(this)));
  // });
  $("body").on("click", ".unselect-table-product", function(){
    editItemUnselectProduct(searchData($(this)));
  });
  $("body").on("change", ".field-param", function(){
    if (sliceTag(thisForm($(this)).attr("id"), 0) == 'edit') thisForm($(this)).submit();
  });

  $("body").on("focusout, keyup", ".input-field", function(){
    thisForm($(this)).submit();
  });

  //FORMS-FIELD VALIDATION: keyup, focusin,
  $("body").on("focusout", ".required", function(){
    requiredFields($(this));
  });

  $("#new-skus-toggle, #new-item-skus-toggle").on("hide.bs.collapse", function(){
    newSkuToggleForms(buildData($(hrefObj($(this).attr("id"))).data().obj));
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
      $.each($("#invoice-nav .nav-link"), function(i, btn){ if (isVisible($(btn).attr("href"))) $(btn).click();});
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

  //TRANVERSAL SHORTCUTS
  function thisFormItem(ref, target) {
    return $(thisForm(ref)).find(target);
  }
  function thisForm(ref) {
    return $(ref).closest("form");
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
  function navToggleBtns(a) {
    return $(a).closest(".nav-toggle").find(".nav-btn");
  }
  function navToggleSiblings(a) {
    return $(navToggleBtns(a)).not(a);
  }

  //BATCH METHODS
  function submitForms(forms){
    Array.from(forms).forEach(function (form) { $(form).submit(); });
  }
  function setInputVals(input_sets){
    Array.from(input_sets).forEach(function (input_set) { $(input_set[0]).val(input_set[1]); });
  }
  function deselectSelected(inputs){
    Array.from($(inputs)).forEach(function (input) { if (valid(input)) deselect(input); });
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

  //SET FORM INPUTS
  function setValByInputName(input_name, value) {
    $('input[name="'+input_name+'"]').val(value);
  }
  function toggleInputVal(input, value) {
    $(input).val(value.length ? value : "");
  }
  //GET FORM INPUTS
  function getSelectedInputs(input_parent, input_target){
    return $(input_parent).find(input_target).not(function() { return $(this).val() == ""; });
  }
  function selectedOpt(ref){
    return $(ref).find(":selected");
  }
  //DESELECT FORM INPUTS
  function refreshForm(target) {
    clearInputs(target);
    $(target).submit();
  }
  function clearInputs(target) {
    $(target + " :input").val("");
  }
  function clearInputsOpts(target) {
    $(target + " option:first").siblings().remove();
  }
  function deselectDynamicOpts(input){
    $(input).find("option:first").siblings().remove();
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
  function deselectSelectedOpt(ref){
    deselectOpt(selectedOpt(ref));
  }

  //TOGGLE VALUES
  function toggleSet(input, new_id, old_id) {
    $(input).val(toggleVal(new_id, old_id));
  }
  function toggleVal(new_id, old_id) {
    return new_id == old_id ? "" : new_id
  }

  //FORM ACCESS
  function requiredFields(input) {
    var emptyFields = $(thisFormItem($(input), ".required")).filter(function() {return $(this).val() == "";});
    var submit = thisFormItem($(input), ".submit-btn");
    if (emptyFields.length==0){
      $(submit).removeAttr('disabled');
    } else {
      $(submit).attr('disabled', 'disabled');
    }
  }
  // function nullRequiredFields(form) {
  //   return $((form, ".required")).filter(function() {return $(this).val() == "";});
  // }
  function setAttrAccess(elements, access) {
    $(elements).filter(".disable").attr("disabled", access);
  }

  //FORM #######################################################################

  function newItemSelectProduct(d) {
    var targetForm = sliceTag(d.form_id, 0)=='search' ? d.itemForm : d.searchForm;
    $(targetForm).find(d.productInput).val(d.selected);
    $(d.searchForm).submit();
  }
  function newItemSelectArtist(d){
    var targetForm = sliceTag(d.form_id, 0)=='search' ? d.itemForm : d.searchForm;
    deselect($(d.itemForm).find(d.titleInput));
    setInputVals([[$(targetForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.artistInput), d.selected], [$(d.titleForm).find(d.context_input), d.itemForm]])
    submitForms([d.searchForm, d.titleForm]);
  }
  function newItemUnselectArtist(d){
    deselectSelected([$(d.searchForm).find(d.artistInput), $(d.titleForm).find(d.artistInput), $(d.itemForm).find(d.artistInput), $(d.itemForm).find(d.titleInput)].flat());
    submitForms([d.searchForm, d.titleForm]);
  }
  function newItemUnselectProduct(d){
    deselectSelected([$(d.searchForm).find(d.productInput), $(d.itemForm).find(d.productInput)]);
    $(d.searchForm).submit();
  }
  function newSkuToggleForms(d){
    var caretBtn = $(d.itemForm).find(d.caret);
    var target = attrObj(caretBtn, 'target');
    deselectDynamicOpts($(d.itemForm).find(d.titleSelect));
    $.each([d.itemForm, d.searchForm, d.titleForm], function(i, form) { deselect($(form).find(":input")) });
    if (isVisible(target)) $(caretBtn).click();
  }

  function editItemSelectProduct(d) {
    $(d.itemForm).find(d.productInput).val(d.selected);
    $(d.itemForm).submit();
  }
  function editItemUnselectProduct(d) {
    deselect($(d.itemForm).find(d.productInput));
    $(d.itemForm).submit();
  }

  function updateTitleInput(d, val){
    $(d.input_grp).find(d.input).val(val);
    toggleVisibility($(d.input_grp).find(d.target));
  }
  //CONTEXT-SPECIFIC get DATA and DO ###########################################
  function searchData(thisElement) {
    var d = buildData(inputGroupData(thisElement).obj);
    d.thisElement = thisElement;
    d.selected = $(thisElement).val();
    d.form_id = thisForm(thisElement).attr("id");
    return d;
  }
  //ELEMENT-SPECIFIC: get common elements by pattern utilities #################
  function inputGroupData(ref) {
    var d = $(inputGroup(ref)).data();
    d.input_grp = inputGroup(ref);
    return d;
  }

  //utilities ##################################################################
  function sliceTag(attr, i) {
    return attr.split('-')[i]
  }
  function valid(val) {
    return val != undefined && val.length ? val : false;
  }

  function buildData(strArr) {
    var arr = strArr.replace(/\s+/g, '').split(',');
    var data = arr.reduce(function(a, k, i) {
      if (i % 2 ==0) a[k] = arr[i+1];
        return a;
      }, {});
    return data;
  }
});
//end ########################################################################

// function formatToggleTarget(parent, target){
//   return parent[0]=='#' ? $(target) : $(parent).find(target);
// }

// function buildData(strArr) {
//   var data = strArr.split(',').reduce(function(a, k, i) {
//     if (i % 2 ==0) a[k.trim()] = obj.split(',')[i+1].trim();
//       return a;
//     }, {});
//   return data;
// }
//test
// function buildData(obj) {
//   var [keys, vals] = splitArray(obj.split(','));
//   return arrToObj(keys, vals);
// }

// function arrToObj(keys, vals, obj={}){
//   Array.from(keys).forEach(function (k) {
//     obj[k]= vals[keys.indexOf(k)];
//   });
//   return obj;
// }
// function splitArray(arr, even=[], odd=[]) {
//   for(var i=0; i<arr.length; i++)
//       (i % 2 == 0 ? even : odd).push(arr[i].trim());
//   return [even, odd];
// }

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
