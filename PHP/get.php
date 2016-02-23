<?php

// Example script for 'list-members' operation
// $Community variable is the path to a community from site root, for example '/parent1/community'
// The API also accepts the community in the URL: https://dgroups.org/parent1/communit/__api/v1/operation

$ACTION_KEY = '[key/email provided]';
$ACTION_SECRET = '[the secret code provided]';
$ACTION_COMMUNITY = '/parent1/communit';
$ACTION_OPERATION = 'list-members';
$ACTION_TIME = gmdate("Y-m-d\TH:i:s");

$data["signature"]     	= makeSHA1Sig($ACTION_OPERATION, $ACTION_KEY, $ACTION_SECRET, $ACTION_TIME);
$data["request-time"]  	= $ACTION_TIME;
$data["site-id"]       	= $ACTION_KEY;

$host = "dgroups.org";

$url_query = '&site-id=' . urlencode($data["site-id"]) .
			'&request-time=' . urlencode($data["request-time"]) .
			'&signature=' . urlencode($data["signature"]);

$url = "{$ACTION_COMMUNITY}/__api/v1/{$ACTION_OPERATION}?verbose&random=" . rand() . $url_query;


$x = PostToHost($host,$url,$data);

var_dump($x);










function PostToHost($host, $path, $data_to_send) {
	//$fp = fsockopen('ssl://'.$host, 443, $errno, $errstr); //if host support https
	$fp = fsockopen($host, 80, $errno, $errstr);
	if (!$fp) {
		echo "errno: $errno \n";
		echo "errstr: $errstr\n";
		return $result;
	}

	$out = "GET {$path} HTTP/1.1\r\n";
	$out .= "Host: {$host}\r\n";
	$out .= "Connection: Close\r\n\r\n";
	fwrite($fp, $out); //send to server

	header('Content-type: text/text');
	while (!feof($fp)) {
		echo fgets($fp, 1024);
	}
}


function makeSHA1Sig($p_operation, $p_scope, $p_secret, $p_time) {
	$sigsource = sprintf('%s%s%s%s', $p_operation, $p_scope, $p_secret, $p_time);
	$sig = sha1($sigsource);
	return $sig;
}
