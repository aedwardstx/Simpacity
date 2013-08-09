// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require highcharts
//= require highcharts/highcharts-more
//= require twitter/bootstrap
//= require dataTables/jquery.dataTables
//= require dataTables/extras/TableTools
//= require dataTables/jquery.dataTables.bootstrap
//= require_tree .
$(function() {
    $("#interface_device_tokens").tokenInput("/devices.json", {
        tokenLimit: 1,
        crossDomain: false,
        prePopulate: $("#interface_device_tokens").data("pre"),
        theme: "facebook"
        });
    $("#interface_group_interface_tokens").tokenInput("/interfaces.json", {
        crossDomain: false,
        prePopulate: $("#interface_group_interface_tokens").data("pre"),
        theme: "facebook"
        });
    $( "#hd_from" ).datepicker({
      changeMonth: true,
      numberOfMonths: 1,
      maxDate: "-1d",
      minDate: "-90d",
      onClose: function() {
        var date = $(this).datepicker('getDate');
        if (date){
          date.setDate(date.getDate() + 1);
          $( "#hd_to" ).datepicker( "option", "minDate", date );
        }
      }
    });
    $( "#hd_to" ).datepicker({
      changeMonth: true,
      numberOfMonths: 1,
      maxDate: "-1d",
      minDate: "-90d",
      onClose: function() {
        var date = $(this).datepicker('getDate');
        if (date) {
          date.setDate(date.getDate() - 1);
          $( "#hd_from" ).datepicker( "option", "maxDate", date );
        }
      }
    });

});


