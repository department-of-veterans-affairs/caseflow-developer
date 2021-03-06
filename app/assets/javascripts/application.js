// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree ./application

window.onload = function () {
  // We want to be able to turn jQuery off on react pages since it
  // interferes with our logic. We set jqueryOn to be false in BaseContainer.jsx
  if (typeof window.jqueryOn === 'undefined' || window.jqueryOn) {
    $(function() {
      window.Modal.bind();
      window.LoadingIndicator.bind();
    });

    /* Reusable 'refresh' pattern */
    $(function() {
      $('.cf-action-refresh').on('click', function() {
        location.reload(); return false;
      });
    });
  }

  // Leave the Dropdown jQuery on React pages since the header
  // is rendered from erb files.
  $(function() {
    window.Dropdown.bind();
  });
};