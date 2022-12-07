<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
$bgcolor = "BACKGROUND_COLOR";
$handle = fopen("/etc/timelapse/timelapse.conf", "r");
if ($handle) {
  while (!feof($handle)) {
    $buffer = fgets($handle);
    if(strpos($buffer, $bgcolor,0) !== FALSE) {
      $match = str_replace(PHP_EOL,'',$buffer);
      $bg_color = str_replace("'","",substr($match,strpos($match, "=")+1));
    }
  }
  fclose($handle);
}

$videos = glob('./*.mp4', GLOB_BRACE);
?>

<!DOCTYPE html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="style.css">
<style>
body {
  background-color: <?=$bg_color;?>;
}
</style>
<html>
  <body>
<?php foreach($videos as $video) {?>
      <video controls preload poster="">
      <source src="<?=$video;?>" type="video/mp4">
        Your browser does not support the video tag.
      </video>
<?php }?>
  </body>
</html>
