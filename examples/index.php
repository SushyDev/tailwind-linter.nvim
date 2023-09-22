<?php
$somebVar = 1;

$classListInOrder = "container flex flex-wrap";
$classListNotInOrder = "flex-wrap container flex";
?>

<div class="<?= $classListInOrder ?>">

</div>

<div class="<?= $classListNotInOrder ?>">

</div>

<div class="container flex flex-wrap">

</div>

<div class="flex-wrap container flex">

</div>
