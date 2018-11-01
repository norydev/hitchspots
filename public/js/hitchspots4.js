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

function drawMarkers(spots) {
  var colors = {
    "1": "#449d44",
    "2": "#449d44",
    "3": "#f9e31d",
    "4": "#ec971f",
  }
  var red = "#c9302c";

  markers = spots.map(function(marker) {
    var el = document.createElement('div');

    // create a HTML element for each feature
    svg = '<svg height="12" width="12" viewBox="0 0 48 48">' +
          '  <circle fill="#ffffff" cx="24" cy="24" r="20"/>' +
          '  <path fill="' + (colors[marker.rating] || red) + '" d="M23.99 4c-11.05 0-19.99 8.95-19.99 20s8.94 20 19.99 20c11.05 0 20.01-8.95 20.01-20s-8.96-20-20.01-20zm8.47 32l-8.46-5.1-8.46 5.1 2.24-9.62-7.46-6.47 9.84-.84 3.84-9.07 3.84 9.07 9.84.84-7.46 6.47 2.24 9.62z"/>' +
          '</svg>'

    $(el).html(svg)

    // make a marker for each feature and add to the map
    return new mapboxgl.Marker(el).setLngLat([marker.lon, marker.lat]).addTo(map);
  });
}

function drawLine(route) {
  map.addLayer({
    "id": "route",
    "type": "line",
    "source": {
      "type": "geojson",
      "data": {
        "type": "Feature",
        "properties": {},
        "geometry": {
          "type": "LineString",
          "coordinates": route
        }
      }
    },
    "layout": {
      "line-join": "round",
      "line-cap": "round"
    },
    "paint": {
      "line-color": "#000000",
      "line-width": 3
    }
  });
}

function centerMap(coords) {
  var lons = coords.map(function(lon_lat) { return lon_lat[0] });
  var lats = coords.map(function(lon_lat) { return lon_lat[1] });

  var minLon = Math.min.apply(Math, lons);
  var maxLon = Math.max.apply(Math, lons);
  var minLat = Math.min.apply(Math, lats);
  var maxLat = Math.max.apply(Math, lats);

  // fit to coords window +- 10%
  map.fitBounds([[
    minLon - (maxLon - minLon)/10,
    minLat - (maxLat - minLat)/10
  ], [
    maxLon + (maxLon - minLon)/10,
    maxLat + (maxLat - minLat)/10
  ]]);
}

function mapOverlayWaiting() {
  $("[data-target~='map-preview-action']").html('<span class="text-white">Preview generation...<span>')
}

function mapOverlayRemove() {
  $("[data-target~='map-preview-overlay']").hide();
}

function mapOverlayReset() {
  var action = $("[data-target~='map-preview-action']");

  if (action.find("button").length == 0) {
    $("[data-target~='map-preview-action']").html('<button type="button" class="btn btn-primary" onClick="drawTripOnMap()">Preview</button>')
    $("[data-target~='map-preview-overlay']").show();
  }
}

function drawTripOnMap() {
  var form = $("[data-target~='trip-form']")
  var formValid = form.find("input").toArray().every(function(input) {
    return input.checkValidity();
  })

  if (formValid) {
    // TODO: reset map here
    mapOverlayWaiting();
    var formValues = form.serializeArray()
    var queryParams = formValues.map(function(formObj) {
      return formObj.name + '=' + formObj.value
    });

    var url = "/v2/trip?" + queryParams.join("&");

    $.getJSON(url, function(trip) {
      mapOverlayRemove();
      drawMarkers(trip.spots);
      drawLine(trip.route);
      centerMap(trip.route);
    });
  }
}

function setMap() {
  mapboxgl.accessToken = $("#map").attr('data-map-token');

  map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/light-v9',
    center: [8,47],
    zoom: 3
  });
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
    e.preventDefault();
    $(this).tab('show');
  })

  if (window.location.search.substr(1).split("=")[0] === "iso_code"){
    $('#kind-tabs a[href="#country-tab"]').tab('show');
  }

  setMap();
});
