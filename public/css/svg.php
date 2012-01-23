<?php
header("Content-Type: image/svg+xml");
?>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="100%" height="100%">
    <defs>
        <linearGradient id="linear-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
<?php foreach(explode(",", $_GET["stops"]) as $stop):?> 
<?php list($color, $offset) = explode(" ", $stop);?>
            <stop offset="<?php echo $offset;?>" stop-color="<?php echo $color;?>" stop-opacity="1"/>
<?php endforeach;?>
        </linearGradient>
    </defs>
    <rect width="100%" height="100%" fill="url(#linear-gradient)"/>
</svg>