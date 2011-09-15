<?php


/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 * An array with keys 'name' and 'description' describing this profile.
 */ 
function springboard_profile_details() {
  return array(
    'name' => 'Springboard',
    'description' => 'Non-profit campaign site in a can!',
  );
}


/**
 * Return an array of modules to be enabled when this profile is installed.
 *
 * @return
 * An array of modules to be enabled.
 */ 
function springboard_profile_modules() {
  $modules = array(
    // Core optional
    'dblog',
    'help',
    'menu',
    'profile',
    'path',
    'statistics',
    'trigger',

    // CCK
    'content',
    'optionwidgets',
    'text',
    'number',
    'email',
 
    // Features
    'features',

    // Misc
    'token',
    'webform',
    'pathauto',
    'ctools',
    'securepages',
    'admin_menu',

    // Ubercart
    'uc_cart',
    'ca',
    'uc_order',
    'uc_product',
    'uc_store',
    'uc_payment',
    'uc_credit',
    'gm_authorizenet',
    'test_gateway',

    // Views
    'views',
    'views_ui', 

    // Springboard custom
    'fundraiser',
    'email_confirmation',
    'market_source',
    'webform_user',
  );

  return $modules;
}

/**
 * Task list
 */

function springboard_profile_task_list() {

  $tasks = array();
  $tasks['salesforce'] = st('Configure Salesforce');
  return $tasks;
} 



/**
 * Finalise installation
 */
function springboard_profile_tasks(&$task, $url) {
  include_once('springboard.forms.inc');
  define("SPRINGBOARD_FORM_REDIRECT", $url);
  if ($task == 'profile') {
    variable_set('install_profile', 'springboard');
    drupal_install_modules(array('springboard'));
    springboard_configure_profile();
    springboard_configure_ubercart();
    springboard_donation_form_add();
    $task = 'salesforce';
    
  }

  $task = springboard_get_task($task, variable_get('springboard_wizard_delta', 0));
  variable_del('springboard_wizard_delta');
  define("SPRINGBOARD_CURRENT_TASK", $task);
  
  $func = sprintf("springboard_task_%s", $task);

  if (function_exists($func)) {
    return drupal_get_form($func);
  }
  

  return $task;


}


function springboard_get_task($task, $delta = 0) {
  static $tasks;
  static $keys;
  if (!$tasks) {
    $tasks = springboard_profile_task_list();
    $keys = array_keys($tasks);
  }
  
    if (($task == $keys[sizeof($keys) - 1]) && ($delta > 0)) {
    return 'profile-finished';
  }

  // finish if the task is the last one and the offset is positive
  if (($tid = array_search($task, $keys)) === FALSE ) {
    // at beginning
    $tid = 0;
  }

  $tid = $tid + $delta;

  // reset to beginning if it tries to go back too far
  if ($tid < 0) {
    $tid = 0;
  }


  return $keys[$tid];
}

function springboard_form_previous($form, $form_state) {
  variable_set('springboard_wizard_delta', -1);
}

function springboard_form_next($form, $form_state) {
  variable_set('springboard_wizard_delta', 1);
}

function springboard_form($form) {
  global $task;

  $form['#redirect'] = SPRINGBOARD_FORM_REDIRECT;


  $form['wizard_form'] = array(
    '#prefix' => '<div id="hosting-wizard-form-buttons">',
    '#suffix' => '</div>',
    '#weight' => 100
  );

  if ($task != 'salesforce') {
    // add a back button
    $button = array(
      '#type' => 'submit',
      '#value' =>  '<- Previous',
    );
    $button['#submit'][] = 'springboard_form_previous';

    $form['wizard_form']['back'] = $button;
  }

  // add a next button
  $button = array(
    '#type' => 'submit',
    '#value' =>  'Next ->',
  );

  // only validate when next is pressed
  // also inherit the whole form's validate callback
  $button['#validate'] = $form['#validate'];
  $button['#validate'][] = 'springboard_form_validate';
  unset($form['#validate']);

  $button['#submit'] = array();

  // hook the regular form submit hooks on the wizard submit hook
  if ($form['#submit']) {
    $button['#submit'] = array_merge($button['#submit'], $form['#submit']);
  }
  $button['#submit'][] = 'springboard_form_next';

  $form['wizard_form']['submit'] = $button;
  return $form;
}

function springboard_form_validate() {

}


/**
 * Configure Drupal <-> Salesforce contact mapping.
 */
function springboard_map_salesforce_contacts() {
  // default values
  $business = 'a:15:{s:2:"Id";s:5:"never";s:9:"AccountId";s:5:"never";s:8:"LastName";s:6:"always";s:9:"FirstName";s:6:"always";s:13:"MailingStreet";s:6:"always";s:11:"MailingCity";s:6:"always";s:12:"MailingState";s:6:"always";s:17:"MailingPostalCode";s:6:"always";s:14:"MailingCountry";s:6:"always";s:5:"Email";s:6:"always";s:17:"Drupal_User_ID__c";s:6:"always";s:19:"Initial_Referrer__c";s:6:"always";s:28:"Initial_Registration_Date__c";s:6:"always";s:16:"Market_Source__c";s:6:"always";s:11:"Referrer__c";s:6:"always";}';
  $fields = 'a:15:{s:2:"Id";s:29:"profile_salesforce_contact_id";s:9:"AccountId";s:29:"profile_salesforce_account_id";s:8:"LastName";s:17:"profile_last_name";s:9:"FirstName";s:18:"profile_first_name";s:13:"MailingStreet";s:15:"profile_address";s:11:"MailingCity";s:12:"profile_city";s:12:"MailingState";s:13:"profile_state";s:17:"MailingPostalCode";s:11:"profile_zip";s:14:"MailingCountry";s:15:"profile_country";s:5:"Email";s:4:"mail";s:17:"Drupal_User_ID__c";s:3:"uid";s:19:"Initial_Referrer__c";s:24:"profile_initial_referrer";s:28:"Initial_Registration_Date__c";s:7:"created";s:16:"Market_Source__c";s:10:"profile_ms";s:11:"Referrer__c";s:16:"profile_referrer";}';
  $business_sd = 'a:15:{s:2:"Id";s:6:"always";s:9:"AccountId";s:6:"always";s:8:"LastName";s:6:"always";s:9:"FirstName";s:6:"always";s:13:"MailingStreet";s:6:"always";s:11:"MailingCity";s:6:"always";s:12:"MailingState";s:6:"always";s:17:"MailingPostalCode";s:6:"always";s:14:"MailingCountry";s:6:"always";s:5:"Email";s:5:"never";s:17:"Drupal_User_ID__c";s:5:"never";s:19:"Initial_Referrer__c";s:5:"never";s:28:"Initial_Registration_Date__c";s:5:"never";s:16:"Market_Source__c";s:5:"never";s:11:"Referrer__c";s:5:"never";}';
  $validation = 'a:15:{s:2:"Id";a:3:{s:10:"field_type";s:2:"id";s:8:"nillable";b:0;s:6:"length";i:18;}s:9:"AccountId";a:3:{s:10:"field_type";s:9:"reference";s:8:"nillable";b:1;s:6:"length";i:18;}s:8:"LastName";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:0;s:6:"length";i:80;}s:9:"FirstName";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:40;}s:13:"MailingStreet";a:3:{s:10:"field_type";s:8:"textarea";s:8:"nillable";b:1;s:6:"length";i:255;}s:11:"MailingCity";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:40;}s:12:"MailingState";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:20;}s:17:"MailingPostalCode";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:20;}s:14:"MailingCountry";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:40;}s:5:"Email";a:3:{s:10:"field_type";s:5:"email";s:8:"nillable";b:1;s:6:"length";i:80;}s:17:"Drupal_User_ID__c";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:50;}s:19:"Initial_Referrer__c";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:255;}s:28:"Initial_Registration_Date__c";a:3:{s:10:"field_type";s:4:"date";s:8:"nillable";b:1;s:6:"length";i:0;}s:16:"Market_Source__c";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:250;}s:11:"Referrer__c";a:3:{s:10:"field_type";s:6:"string";s:8:"nillable";b:1;s:6:"length";i:255;}}';

  // build a query to insert the default fieldmap
  $sql = "INSERT INTO {salesforce_management_field_map}
    VALUES (1, 'General user fieldmap', 'user', 'Contact', '', 0, '%s', '%s', '%s', 'Email', 2, '0', '%s')";
  
  // run it   
  db_query($sql, $fields, $business, $business_sd, $validation);
}

/**
 * 
 */
 function springboard_donation_form_add() {
    $settings = array(
     'type' => 'donation_form',
     'language' => '',
     'uid' => '1',
     'status' => '1',
     'promote' => '1',
     'moderate' => '0',
     'sticky' => '0',
     'tnid' => '0',
     'translate' => '0',
     'title' => 'Test Donation Form',
     'body' => 'Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla. Nunc est ipsum, pretium quis, dapibus sed, varius non, lectus. Proin a quam. Praesent lacinia, eros quis aliquam porttitor, urna lacus volutpat urna, ut fermentum neque mi egestas dolor.',
     'teaser' => 'Donec placerat. Nullam nibh dolor, blandit sed, fermentum id, imperdiet sit amet, neque. Nam mollis ultrices justo. Sed tempor. Sed vitae tellus. Etiam sem arcu, eleifend sit amet, gravida eget, porta at, wisi. Nam non lacus vitae ipsum viverra pretium. Phasellus massa. Fusce magna sem, gravida in, feugiat ac, molestie eget, wisi. Fusce consectetuer luctus ipsum. Vestibulum nunc. Suspendisse dignissim adipiscing libero. Integer leo. Sed pharetra ligula a dui. Quisque ipsum nibh, ullamcorper eget, pulvinar sed, posuere vitae, nulla. Sed varius nibh ut lacus. Curabitur fringilla.',
     'log' => '',
     'format' => '1',
     'is_donation_form' => '1',
     'gateway' => 'test_gateway',
     'receipt_email_from' => 'Test',
     'receipt_email_address' => 'test@jacksonriver.com',
     'receipt_email_subject' => 'Thanks',
     'receipt_email_message' => 'Thanks',
     'amount_delta' => 4,
     'amount_0' => 10,
     'label_0' => '$10',
     'amount_1' => 20,
     'label_1' => '$20',
     'amount_2' => 50,
     'label_2' => '$50',
     'amount_3' => 100,
     'label_3' => '$100',
     'show_other_amount' => '1',
     'minimum_donation_amount' => '10',
     'internal_name' => 'Test Donation Form',
     'is_being_cloned' => '0',
     'webform' => array(
        'confirmation' => 'Thanks!',
        'confirmation_format' => FILTER_FORMAT_DEFAULT,
        'redirect_url' => '<confirmation>',
        'teaser' => '0',
        'allow_draft' => '1',
        'submit_text' => '',
        'submit_limit' => '-1',
        'submit_interval' => '-1',
        'submit_notice' => '1',
        'roles' => array('1', '2'),
        'components' => array(),
        'emails' => array(),
      ),
    );
    
    $node = (object) $settings;
    node_save($node);
    
    // Fix webform draft button
    
     $exists = db_result(db_query("SELECT COUNT(*) FROM {webform} WHERE nid = %d", $node->nid));
     if (!$exists) {
       db_query("INSERT INTO {webform} VALUES (%d, '%s', %d, '%s', %d, %d, %d, %d, %d, %d, '%s', %d, %d)",
       $node->nid, 'Thanks!', 0, '<confirmation>', 1, 0, 0, 0, 0, 1, '', -1, -1);
     }
}

/**
 * Set up profile fields used by Springboard.
 */
function springboard_configure_profile() {
  // Add profile fields
  $profile_fields = array();
  $profile_fields[] = array(
    'title' => st('First Name'),
    'name' => 'profile_first_name',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );

  $profile_fields[] = array(
    'title' => st('Last Name'),
    'name' => 'profile_last_name',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );

  $profile_fields[] = array(
    'title' => st('Address'),
    'name' => 'profile_address',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );

  $profile_fields[] = array(
    'title' => st('Address Line 2'),
    'name' => 'profile_address_line_2',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );
  
  $profile_fields[] = array(
    'title' => st('City'),
    'name' => 'profile_city',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );
  
  // Default options loaded from {uc_zones}
  $profile_fields[] = array(
    'title' => st('State/Province'),
    'name' => 'profile_state',
    'category' => st('Personal Information'),
    'type' => 'selection',
    'visibility' => 2,
  );
  
  $profile_fields[] = array(
    'title' => st('Postal Code'),
    'name' => 'profile_zip',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );
  
  $profile_fields[] = array(
    'title' => st('Country'),
    'name' => 'profile_country',
    'category' => st('Personal Information'),
    'type' => 'textfield',
    'visibility' => 2,
  );
  
  $profile_fields[] = array(
    'title' => st('Campaign ID'),
    'name' => 'profile_cid',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  $profile_fields[] = array(
    'title' => st('Market Source'),
    'name' => 'profile_ms',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  $profile_fields[] = array(
    'title' => st('Referrer'),
    'name' => 'profile_referrer',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  $profile_fields[] = array(
    'title' => st('Initial Referrer'),
    'name' => 'profile_initial_referrer',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  $profile_fields[] = array(
    'title' => st('Salesforce Account Id'),
    'name' => 'profile_salesforce_account_id',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  $profile_fields[] = array(
    'title' => st('Salesforce Contact Id'),
    'name' => 'profile_salesforce_contact_id',
    'category' => st('System'),
    'type' => 'textfield',
    'visibility' => 4,
  );
  
  foreach ($profile_fields as $profile_field) {
    db_query("INSERT INTO {profile_fields} (title, name, category, type, visibility) VALUES ('%s', '%s', '%s', '%s', %d)", $profile_field['title'], $profile_field['name'], $profile_field['category'], $profile_field['type'], $profile_field['visibility']);
  }
  
  // Load State/Province options from {uc_zones}, UC default is zone codes for US & Canada.
  $zones = array();
  $results = db_query('SELECT zone_code FROM {uc_zones}');
  while ($zone = db_result($results)) {
    $zones[] = $zone;
  }
  $zones = implode("\n", $zones);
  db_query("UPDATE {profile_fields} SET options = '%s' WHERE name = 'profile_state'", $zones);
}


function springboard_configure_ubercart() {
  // Enable the test payment gateway by default
  variable_set('uc_pg_test_gateway_enabled', 1);
}
