<?php
/*
 *  Custom settings.php for Drupal 6/7 website deployment
 *  v1.0.1
 */

/** 
 * Database connection Drupal 7
 */
$databases = array (
  'default' => 
  array (
    'default' => 
    array (
      'host' => '%s',
      'database' => '%s',
      'username' => '%s',
      'password' => '%s',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

/** 
 * Database connection Drupal 6
 */
$db_url = 'mysql://%s:%s@%s/%s';
$db_prefix = '';

/**
 * reverse proxy settings
 */ 
// $conf['reverse_proxy']=TRUE;
// $conf['reverse_proxy_addresses']=array('127.0.0.1');


// $base_url = 'http://www.example.com';  // NO trailing slash!
// $conf['error_level'] = 0;

/** 
 * Disabling emails sendings (devel module required)
 */
//$conf['smtp_library'] = 'sites/all/modules/devel/devel.module';

error_reporting(E_ALL & ~E_NOTICE);

/** 
 * Other settings
 */
$update_free_access = FALSE;
$drupal_hash_salt = 'wiqB0akLV4RuRGhMVFHvOA1EcGDRrVCZTFCR7BPtV4c';
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);
ini_set('session.gc_maxlifetime', 200000);
ini_set('session.cookie_lifetime', 2000000);
$conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';