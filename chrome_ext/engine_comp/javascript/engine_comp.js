// Copyright (c) 2014 

/**
 * This extension allows to submit a Jenkins Job for comparing 2 Polaris Engines.
 * Author: Sam Varghese
 * Date: June 24, 2014
*/

(function(jQuery) {
  var engineComp = {
    _submitJob: function() {
    },
    initListener: function() {
      var that = this;
      $('form.engine-comp button.btn').on('click', function(e) {
        e.preventDefault();
        if (that._validateInputs(e.target.form)) {
          var data = {
            user: $(e.target.form).find('input#user').val(),
            engine_1: $(e.target.form).find('input#engine_1').val(),
            engine_2: $(e.target.form).find('input#engine_2').val()};
          jQuery.ajax(
            'http://cad-api.sv.walmartlabs.com:4000/engine_stats/post_request',
            {data: data,
             dataType: 'json',
             success: function(data, status) {
               var results = data;
               if (results && results.job_id) {
                that._show_job_id(results.job_id);
               }
             },
             error: function(jqXhr, status) {
               that._show_job_error(status);
             }
            });
        }
      });
      $('div.form-submission-results div.another-job a').on(
          'click', function(e) {
        e.preventDefault();
        $('form.engine-comp').find('input[type="text"]').each(function(index) {
          $(this).val('');
        });
        $('div.form-submission-results span.job-id').text('');
        $('div.form-submission-results').hide();
        $('div.form-engine-comp').show();
      });
    },
    _validateInputs: function(form) {
      var flag = true;
      var that = this;
      $(form).find('input[type="text"]').each(function(index) {
        if ($(this).val() == '') {
          flag = false;
          that._paintError(this);
        }
      });
      return flag;
    },
    _paintError: function(element) {
      $(element).parents('div.form-group').toggleClass('has-error');
    },
    _show_job_id: function(job_id) {
      $('div.form-engine-comp').hide();
      $('div.form-submission-results div.error').hide();
      $('div.form-submission-results span.job-id').text(job_id);
      $('div.form-submission-results div.success').show();
      $('div.form-submission-results').show();
    },
    _show_job_error: function(error) {
     $('div.form-submission-results div.success').hide();
     $('div.form-submission-results div.error').text(error);
     $('div.form-submission-results div.error').show();
     $('div.form-submission-results').show();
    }
  }
  $(function() {
    engineComp.initListener();
  });
})(jQuery);


