<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
$title = "TIMELAPSE";
$start_date = "START";
$handle = fopen("/etc/timelapse/timelapse.conf", "r");
if ($handle) {
  while (!feof($handle)) {
    $buffer = fgets($handle);
    if(strpos($buffer,$title,0) !== FALSE) {
      $match = str_replace(PHP_EOL,'',$buffer);
      $title = str_replace("'","",substr($match,strpos($match, "=")+1));
    }
    if(strpos($buffer,$start_date,0) !== FALSE) {
      $match = str_replace(PHP_EOL,'',$buffer);
      $start_date = str_replace("'","",substr($match,strpos($match, "=")+1));
    }
  }
  fclose($handle);
}

$videos = glob('./*.mp4', GLOB_BRACE);
?>

<html>
<!DOCTYPE html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="output.css" rel="stylesheet">
  <title><?=ucfirst($title);?> Timelapse</title>
</head>
<body class="bg-green-400 max-h-screen">
  <h1 class="text-2xl text-center"><?=ucfirst($title);?> <small>(Started <?=$start_date;?>)</small></h1>
  

  <div class="container justify-items-center mx-auto grid sm:grid-cols-1 lg:grid-cols-auto pt-6 gap-8">
<?php foreach($videos as $video) {?>
    <video controls preload class="max-h-80 aspect-ratio rounded">
      <source src="<?=$video;?>" type="video/mp4">
        Your browser does not support the video tag.
    </video>
<?php }?>
  </div>


</body>
</html>
