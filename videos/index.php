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

$videos = shell_exec("ls *.mp4 | xargs");
$videos = explode(" ", $videos);
?>


<html>
<!DOCTYPE html>
<head class="p-0 m-0 h-screen">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="output.css" rel="stylesheet">
  <title><?=ucfirst($title);?> Timelapse</title>
</head>
<body class="bg-green-400 max-h-screen m-0 p-0">
  <h1 class="text-2xl text-center pb-6 pt-3"><?=ucfirst($title);?> <small>(Started <?=$start_date;?>)</small></h1>
  <div class="container justify-items-center mx-auto space-y-0 grid grid-cols-1 gap-0 grid-flow-row auto-rows-auto">
<?php foreach($videos as $video) {?>
    <div>
    <video controls preload class="h-5/6 rounded-xl">
      <source src="<?=$video;?>" type="video/mp4">
        Your browser does not support the video tag.
    </video>
    </div>
<?php }?>
  </div>
</body>
</html>
