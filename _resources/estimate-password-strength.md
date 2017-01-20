---
title: "estimate password strength."
layout: post
category: resources
author: leftymitt
format: text
type: article
tags: 
 - passwords

date: 2016-04-02
icon: dropbox-logo.svg

js: "
<script src='/assets/build/js/zxcvbn.min.js'></script>

<script>
/* check passwords as they're typed. */
$('#password_form').keyup( function() {
  var entered_password = $('#password_form').val();
  var results = zxcvbn(entered_password);
  
  $('#password').text(entered_password);
  $('#guesses_log10').text(results.guesses_log10);
  $('#score_bar').width(String(results.score * 25 + '%'));
  $('#score_bar').text(String(results.score * 25 + '%'));
  $('#100_hr').text(results.crack_times_display.online_throttling_100_per_hour);
  $('#10_s').text(results.crack_times_display.online_no_throttling_10_per_second);
  $('#10k_s').text(results.crack_times_display.offline_slow_hashing_1e4_per_second);
  $('#10B_s').text(results.crack_times_display.offline_fast_hashing_1e10_per_second);
  $('#warning').text(results.feedback.warning);
  $('#suggestions').text(results.feedback.suggestions);

  /* delete existing panels and generate new ones when input stops. */
  delay(function() {
    $('#sequence_grid').empty();
    if(results.sequence !== null) {
      for(var idx=0; idx<results.sequence.length; idx++) {
        createPanel(results.sequence[idx]);
      };
    };
  }, 350);
});

/* create a timer to delay execution of a function. */
var delay = (function() {
  var timer = 0;
  return function(callback, ms) {
    clearTimeout(timer);
    timer = setTimeout(callback, ms);
  };
})();

/* generate panels from zxcvbn() output. */
function createPanel(sequence) {
  var token = sequence['token'];
  if(token === ' ') { return };
  
  var html = '<li class=\"uk-animation-slide-bottom\">';
  html += '<div class=\"uk-panel uk-panel-box\">';
  html += '<div class=\"uk-panel-title uk-panel-header\">' + token + '</div>';

  /* fill a table with all pertinent variables in a sequence. */
  html += '<div class=\"uk-overflow-container\">';
  html += '<table class=\"uk-table uk-table-condensed\"><tbody>';
  if(sequence.hasOwnProperty('matched_word')) {
    html += '<tr><td class=\"uk-width-1-2\">matched word:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['matched_word'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('guesses_log10')) {
    html += '<tr><td class=\"uk-width-1-2\">guesses_log10:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['guesses_log10'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('pattern')) {
    html += '<tr><td class=\"uk-width-1-2\">pattern:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['pattern'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('dictionary_name')) {
    html += '<tr><td class=\"uk-width-1-2\">dictionary name:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['dictionary_name'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('repeat_count')) {
    html += '<tr><td class=\"uk-width-1-2\">repeat count:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['repeat_count'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('reversed')) {
    html += '<tr><td class=\"uk-width-1-2\">reversed:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['reversed'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('uppercase_variations')) {
    html += '<tr><td class=\"uk-width-1-2\">uppercase variations:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['uppercase_variations'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('rank')) {
    html += '<tr><td class=\"uk-width-1-2\">rank:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['rank'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('l33t')) {
    html += '<tr><td class=\"uk-width-1-2\">l33t:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['l33t'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('l33t_variations')) {
    html += '<tr><td class=\"uk-width-1-2\">l33t variations:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['l33t_variations'] + '</td></tr>';
  }
  if(sequence.hasOwnProperty('sub_display')) {
    html += '<tr><td class=\"uk-width-1-2\">substitutions:</td>';
    html += '<td class=\"uk-width-1-2\">' + sequence['sub_display'] + '</td></tr>';
  }
  html += '</tbody></table></div>';

  html += '</div>';
  html += '</li>';
  $('#sequence_grid').append(html);
};

/* disable ENTER for form. */
$(document).on('keypress', 'form', function (e) {
  var code = e.keyCode || e.which;
  if (code == 13) {
    e.preventDefault();
    return false;
  }
});
</script>
"
---

built with
[zxcvbn](https://blogs.dropbox.com/tech/2012/04/zxcvbn-realistic-password-strength-estimation/)
by dropbox. 

<form class="uk-form" id="">
  <fieldset data-uk-margin>
  <input type="text" id="password_form" placeholder="enter password." 
         class="uk-width-1-1">
  </fieldset>
</form>

<hr>

<div class="uk-panel uk-panel-box"><div class="uk-overflow-container">
  <table class="uk-table uk-table-condensed"><tbody>

    <tr>
      <td class="uk-width-1-6">password: </td>
      <td id="password" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6">guesses_log10: </td>
      <td id="guesses_log10" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6">score: </td>
      <td id="score" class="uk-width-5-6">
        <div class="uk-progress uk-progress-success">
          <div id="score_bar" class="uk-progress-bar" 
               style="width:0%"></div>
        </div>
      </td>
    </tr>

    <tr>
      <td>guess rate:</td>
      <td>time to break:</td>
    </tr>

    <tr>
      <td class="uk-width-1-6" style="text-indent:1em">100/hr: </td>
      <td id="100_hr" style="text-indent:1em" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6" style="text-indent:1em">10/s: </td>
      <td id="10_s" style="text-indent:1em" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6" style="text-indent:1em">10k/s: </td>
      <td id="10k_s" style="text-indent:1em" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6" style="text-indent:1em">10B/s: </td>
      <td id="10B_s" style="text-indent:1em" class="uk-width-5-6"></td>
    </tr>

    <tr><td></td></tr>

    <tr>
      <td class="uk-width-1-6">warning: </td>
      <td id="warning" class="uk-width-5-6"></td>
    </tr>

    <tr>
      <td class="uk-width-1-6">suggestions: </td>
      <td id="suggestions" class="uk-width-5-6"></td>
    </tr>

  </tbody></table>
</div></div>


## matched sequences:

<ul class="uk-grid uk-grid-width-1-1 uk-grid-width-medium-1-2 uk-grid-width-large-1-3" 
    data-uk-grid="{gutter:20, animation:false}" id="sequence_grid" 
    data-uk-observe data-uk-check-display>
</ul>
