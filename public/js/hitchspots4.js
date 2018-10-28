/*
/ Trip: Places function
*/
function latestIndex() {
  var placesWrappers = $("[data-behaviour~='geocode']");
  return parseInt($(placesWrappers[placesWrappers.length - 1]).attr('data-place-index'));
}

function bindGeocoder(index) {
  $('#places-' + index).typeahead(null, {
    source: engine.ttAdapter(),
    displayKey: 'description'
  });

  // Required to bind addresspicker:selected
  engine.bindDefaultTypeaheadEvent($('#places-' + index))

  $(engine).bind('addresspicker:selected', function (event, selectedPlace) {
    if ($('#places-' + index).val() === selectedPlace.description) {
      $('#places-' + index + '-lon').val(selectedPlace.geometry.coordinates[0])
      $('#places-' + index + '-lat').val(selectedPlace.geometry.coordinates[1])
    }
  });
}

function updateWrapperToIntermediate(index) {
  updateWrapper(index, '<span class="glyphicon glyphicon-option-vertical" aria-hidden="true"></span>', "Via")
}

function updateWrapperToDestination(index) {
  updateWrapper(index, '<span class="glyphicon glyphicon-map-marker" aria-hidden="true"></span>', "Destination")
}

function updateWrapper(index, html, title) {
  var wrapper = $("[data-place-index~='"+ index +"']");
  if (wrapper.length > 0) {
    elem = wrapper.find("[data-target~='place-label']");
    if (elem.length > 0) {
      elem.html(html);
      elem.prop("title", title);
    }
  }
}

function removePlaceWrapper(index) {
  var wrapper = $("[data-place-index~='"+ index +"']");
  if (wrapper.length > 0) {
    indexIsLatest = index == latestIndex();
    wrapper.remove();
    if (indexIsLatest) {
      updateWrapperToDestination(latestIndex());
    }
  }
  toggleAddButton(parseInt(index) - 1)
}

function addPlaceWrapper(index) {
  var placeholderCity = ["Berlin", "Amsterdam", "Madrid", "Rome", "Paris", "Vienna", "Bratislava", "Prague", "Warsaw", "Ljubljana"][Math.floor(Math.random() * 10)];

  var placeFormHtml = '<div data-behaviour="geocode" data-place-index="' + index +'">' +
                      '  <div class="input-group margin-bottom-15">' +
                      '    <span class="input-group-addon inline-input-label" title="Destination" data-target="place-label">' +
                      '      <span class="glyphicon glyphicon-map-marker" aria-hidden="true"></span>' +
                      '    </span>' +
                      '    <input id="places-' + index +'" type="text" class="form-control" name="places[' + index +'][name]" placeholder="' + placeholderCity + '" required="true" autocomplete="off">' +
                      '    <span class="input-group-btn">' +
                      '      <button class="btn btn-default" type="button" onClick="removePlaceWrapper(' + index + ')">' +
                      '        <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>' +
                      '      </button>' +
                      '    </span>' +
                      '  </div>' +
                      '  <input id="places-' + index +'-lat" type="hidden" name="places[' + index +'][lat]">' +
                      '  <input id="places-' + index +'-lon" type="hidden" name="places[' + index +'][lon]">' +
                      '</div>'

  $("[data-target~='places-inputs']").append(placeFormHtml)
  bindGeocoder(index)
}

function addPlaceToTrip() {
  if ($("[data-target~='places-inputs']").length >= 0) {
    var memoLatestIndex = latestIndex();

    updateWrapperToIntermediate(memoLatestIndex);
    addPlaceWrapper(parseInt(memoLatestIndex) + 1);
    toggleAddButton(parseInt(memoLatestIndex) + 1);
  }
}

function toggleAddButton(index) {
  if (index >= 23) {
    var btn = $("[data-target~='add-trip-button']");
    if (index == 23) {
      btn.show();
    } else {
      btn.hide();
    }
  }
}

$(document).ready(function() {
  // Geocoding
  engine = new PhotonAddressEngine(); // global var, one engine per page

  $("[data-behaviour~='geocode']").each(function(_, el) {
    var index = $(el).attr('data-place-index');
    bindGeocoder(index);
  });

  // Bootstrap tabs
  $('#kind-tabs a').click(function (e) {
    e.preventDefault()
    $(this).tab('show')
  })

  if (window.location.search.substr(1).split("=")[0] === "iso_code"){
    $('#kind-tabs a[href="#country-tab"]').tab('show')
  }
});
