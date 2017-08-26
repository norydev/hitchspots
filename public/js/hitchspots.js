$(document).ready(function() {
  var engine = new PhotonAddressEngine();

  $('#from').typeahead(null, {
    source: engine.ttAdapter(),
    displayKey: 'description'
  });

  $('#to').typeahead(null, {
    source: engine.ttAdapter(),
    displayKey: 'description'
  });

  // Those 2 are required to bind addresspicker:selected
  engine.bindDefaultTypeaheadEvent($('#from'))
  engine.bindDefaultTypeaheadEvent($('#to'))

  $(engine).bind('addresspicker:selected', function (event, selectedPlace) {
    if ($('#from').val() === selectedPlace.description) {
      $('#from_lon').val(selectedPlace.geometry.coordinates[0])
      $('#from_lat').val(selectedPlace.geometry.coordinates[1])
    }

    // No else if because both input could have the same value. That would
    // make no sense product wise, but it's a technical possibility.
    if ($('#to').val() === selectedPlace.description) {
      $('#to_lon').val(selectedPlace.geometry.coordinates[0])
      $('#to_lat').val(selectedPlace.geometry.coordinates[1])
    }
  });
});
