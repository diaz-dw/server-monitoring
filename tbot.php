<?php
/*
douglas.diaz@
Jan-2022
Mar-2022: Added special chars replacement
*/

if ( empty($_GET['from']) || empty($_GET['msg']) ) {
	http_response_code(406);
	exit;
}

$from = escapeshellcmd($_GET['from']);
$msg = escapeshellcmd($_GET['msg']);

$data='';
if ( !empty($_GET['data']) )
	$data = str_replace( array('&', '<', '>', '\'', '"'), '_', $_GET['data'] );

$output = `/opt/NMS/tbot "$from" "$msg" "$data"`;

?>
