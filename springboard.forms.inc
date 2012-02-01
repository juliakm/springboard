<?php


function springboard_task_salesforce($current) {
  // TODO: Add CSS and javascript to drive show/hide of additional config options

  $form = array();
  $form['sf_enable'] = array(
    '#title' => 'Enable Salesforce Integration?',
    '#type' => 'checkbox',
    '#description' => st('If your organization has a Salesforce org and plans on synching information between Drupal and Salesforce you should enable integration.'),
  );
  $form['sf'] = array(
    '#title' => st("Salesforce Integration Settings"),
    '#type' => 'fieldset',
  );
  $form['sf']['sf_user'] = array(
    '#title' => st('Enable Salesforce User Integration'),
    '#type' => 'checkbox',
  );
  $form['sf']['sf_donation'] = array(
    '#title' => st('Enable Salesforce Donation Integration'),
    '#type' => 'checkbox',
  );
  $form['sf']['sf_webform'] = array(
    '#title' => st('Enable Salesforce Webform Integration'),
    '#type' => 'checkbox',
  );
  $form['#validate'] = array('springboard_task_salesforce_validate');
  $form['#submit'] = array('springboard_task_salesforce_submit');
  return springboard_form($form);
}
 

function springboard_task_salesforce_validate(&$form, &$form_state) {

}

function springboard_task_salesforce_submit($form, &$form_state) {

  if ($form_state['values']['sf_enable']) {
  
    // Variable used to indicate the Salesforce configuration form should be displayed on the Dashboard.
    variable_set('springboard_salesforce_enabled', 1);

    //TODO: add conditional logic to enable Salesforce helper modules based on form selections.
    // Enable Salesforce module suite.
    
    $optional = array(
      'queue_api',
      'sb_npsp',
      'salesforce_management_api',
      'encrypt', // Dependency of salesforce_management_api
      'queue_processor',
      'sf_node',
    );

    foreach ($optional as $name) {
      $exists = db_result(db_query("SELECT name FROM {system} WHERE type='module' and name='%s'", $name));
      drupal_install_modules(array($name));
      springboard_map_salesforce_contacts();
    }

    if ($form_state['values']['sf_user']) {
      drupal_install_modules(array('sf_user'));
    }

    if ($form_state['values']['sf_donation']) {
      drupal_install_modules(array('sf_donation'));
    }

    if ($form_state['values']['sf_webform']) {
      drupal_install_modules(array('sf_webform'));
    }

    // Configure default donation backend
    variable_set('sf_donation_backend', 'npsp');
  }

}

function springboard_task_cart($form_state) {
  $form = array();
  drupal_set_message('file data:' . variable_get('springboard_file_date', ''));
  $form['sf_cart'] = array(
    '#title' => st('Configure UberCart'),
    '#type' => 'checkbox',
    '#description' => st('do stuff'),
  );

  return springboard_form($form);
}

function springboard_task_cart_submit($form, &$form_State) {
  variable_set('springboard_cart_enabled', $form_state['values']['sf_cart']);
}
