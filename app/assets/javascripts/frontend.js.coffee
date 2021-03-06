# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#dt_frontend_pl').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 7 ] }
    ],
    "aoColumns": [
      null,
      null,
      null,
      { "sType": "data-speed" },
      { "sType": "data-speed" },
      { "sType": "data-speed" },
      null,
      null
    ]
  })
  $('#dt_frontend_lg').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 5 ] }
    ]
    "aoColumns": [
      null,
      { "sType": "data-speed" },
      { "sType": "data-speed" },
      { "sType": "data-speed" },
      null,
      null
    ]
  })

