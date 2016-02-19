<?php
// Example script for 'adduser' operation
// $Community variable is the path to a community from site roo, for example '/parent1/community'
// The API also accepts the community in the URL: https://dgroups.org/parent1/communit/__api/v1/operation
$key = <your key here>;
$secret = <your secret here>;
$community = <path to community>;

function PostToHost($host, $path, $data_to_send){
	$dc = 0;
	$bo="-----------------------------305242850528394";
	$fp = fsockopen('ssl://'.$host, 443, $errno, $errstr);
	//$fp = fopen($_SERVER['DOCUMENT_ROOT'].'/oc/wRegister/wOverlays/portlets/log.txt', 'w');
	if (!$fp) {
		echo "errno: $errno \n";
		echo "errstr: $errstr\n";
		return $result;
	}
	fputs($fp, "POST $path HTTP/1.0\n");
	fputs($fp, "Host: $host\n");
	fputs($fp, "User-Agent: CottonLoginScript\n");
	fputs($fp, "Content-type: multipart/form-data; boundary=$bo\n");
	foreach($data_to_send as $key=>$val) {
		$ds =sprintf("--%s\nContent-Disposition: form-data; name=\"%s\"\n\n%s\n", $bo, $key, $val);
		$dc += strlen($ds);
	}
	$dc += strlen($bo)+3;
	fputs($fp, "Content-length: $dc \n");
	fputs($fp, "\n");
	foreach($data_to_send as $key=>$val) {
		$ds =sprintf("--%s\nContent-Disposition: form-data; name=\"%s\"\n\n%s\n", $bo, $key, $val);
		fputs($fp, $ds );
	}
	$ds = "--".$bo."\n";
	fputs($fp, $ds);
 
	while(!feof($fp)) {
		$res .= fread($fp, 1);
	}
	fclose($fp);
	return $res;
}

$iso8601time = gmdate("c");
$iso8601time = preg_split('/\+/',$iso8601time);
$iso8601time = $iso8601time[0];

function makeSHA1Sig($email, $siteid, $pass, $iso8601time) {
	$sigsource = sprintf('%s%s%s%s', $email, $siteid, $pass, $iso8601time);
	$sig = sha1($sigsource);
	return $sig;
}

// $code = $this-&gt;elements['country'];
// $country = code2country($code); // no longer in use (function deletet because of space)
$country = $this-&gt;elements['country'];

$data["signature"]     	= makeSHA1Sig('adduser', $key, $secret, $iso8601time);
$data["scope"]         	= $community;
$data["request-time"]  	= $iso8601time;
$data["operation"]     	= "adduser";
$data["site-id"]       	= $key;
$data["email"]       	= $this-&gt;elements['email'];
$data["firstName"]     	= $this-&gt;elements['firstname'];
$data["password"]     	= $password;
$data["country"]      	= $country;
$data["lastName"]   	= $this-&gt;elements['surname'];
$data["timezone"]    	= '+01:00,1';
$data["title"]			= $this-&gt;elements['title'];
$data["organization"]	= $this-&gt;elements['company'];
$data["address"]		= $this-&gt;elements['street'].'\n'.$this-&gt;elements['zipcode'].' '.$this-&gt;elements['town'];
$data["telephone"]		= $this-&gt;elements['phone'];
$data["fax"]			= $this-&gt;elements['fax'];

$host = "dgroups.org";
$url = "/api.axd?verbose";

$x = PostToHost("$host","$url",$data);
?>
