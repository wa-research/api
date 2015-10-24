<?php
/**
 * DGroups V2
 * https://github.com/wa-research/api/wiki/API-Version-2
 * Created by Adam Sanchez <a.sanchez75@gmail.com>
 */

// fetching current time

$date = file_get_contents("https://dgroups.org/groups/mf-global/test/__api/v2/time");
$api_key = "api_key_here";
$secret = "secret_here";
$sha1 = SHA1("/mf-global/test/__api/v2/stats/basic" . $api_key . $secret . $date);

$ch = curl_init("https://dgroups.org/mf-global/test/__api/v2/stats/basic");

curl_setopt($ch, CURLOPT_HTTPHEADER,
  array(
  'GET /mf-global/test/__api/v2/stats/basic',
  'Accept: application/json',
  'Authorization: ' . $sha1,
  'Path: /mf-global/test/__api/v2/stats/basic',
  'X-ECS-Api-Key: condesan',
  'X-ECS-Api-RequestTime: ' . $date
  )
);

$resp = curl_exec($ch);

print_r($resp);

if(!curl_exec($ch)){
    die('Error: "' . curl_error($ch) . '" - Code: ' . curl_errno($ch));
}

curl_close($ch);


?>

