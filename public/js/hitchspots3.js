$(document).ready(function() {
  //////////////
  // Geocoding
  //////////////
  var engine = new PhotonAddressEngine();

  $("[data-behaviour~='geocode']").each(function(_, el) {
    var index = $(el).attr('data-place-index');

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
  });

  ///////////////////
  // Bootstrap tabs
  ///////////////////
  $('#kind-tabs a').click(function (e) {
    e.preventDefault()
    $(this).tab('show')
  })

  if (window.location.search.substr(1).split("=")[0] === "iso_code"){
    $('#kind-tabs a[href="#country-tab"]').tab('show')
  }
});
