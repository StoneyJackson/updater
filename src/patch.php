<?php

/* This file is part of Updater.
 * 
 * Updater is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Updater is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with Updater.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * taken from: http://php.net/manual/en/function.shell-exec.php
 */
function cmd_exec($cmd, &$stdout, &$stderr)
{
    $outfile = tempnam(".", "cmd");
    $errfile = tempnam(".", "cmd");
    $descriptorspec = array(
        0 => array("pipe", "r"),
        1 => array("file", $outfile, "w"),
        2 => array("file", $errfile, "w")
    );
    $proc = proc_open($cmd, $descriptorspec, $pipes);
   
    if (!is_resource($proc)) return 255;

    fclose($pipes[0]);    //Don't really want to give any input

    $exit = proc_close($proc);
    $stdout = file($outfile);
    $stderr = file($errfile);

    unlink($outfile);
    unlink($errfile);
    return $exit;
}

function update()
{
    $error_msg = "";
    $script = dirname(__FILE__).'/private/patch.bash';
    $patch_file = dirname(__FILE__).'/private/upload.patch';
    if ($_FILES["Patch"]["error"] > 0) {
        $error_msg = "Error: " . $_FILES["Patch"]["error"] . "<br>";
    } else {
        if (!file_exists($_FILES["Patch"]["tmp_name"])) {
            $error_msg =  "Temp file doesn't exist: ". $_FILES["Patch"]["tmp_name"] . "<br>";
        } else if (!move_uploaded_file($_FILES["Patch"]["tmp_name"], $patch_file)) {
            $error_msg = "Could not move file. <br>";
        } else {
            $cmd = "bash $script $patch_file";
            $exit_code = cmd_exec($cmd, $stdout, $stderr);
        }
    }
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Patch</title></head>
<body>
<?php
    if ($error_msg) {
        echo $error_msg;
    }
?>
<h1>Patch</h1>
<h2>exit code</h2>
<pre><?php print($exit_code); ?></pre>
<h2>stdout</h2>
<pre><?php foreach($stdout as $line) { print($line); } ?></pre>
<h2>stderr</h2>
<pre><?php foreach($stderr as $line) { print($line); } ?></pre>
</body>
</html><?php
}

function form()
{
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Patch</title></head>
<body>
<h1>Patch</h1>
<form action="#" method="POST" enctype="multipart/form-data">
<div>
    <label for="Patch">Patch file:</label>
    <input type="file" name="Patch" id="Patch" />
</div>
<div>
    <label for="Password">Password:</label>
    <input type="password" name="Password" id="Password" />
</div>
<input type="submit" name="Update" id="Update" value="Update" />
</form>
</body>
</html><?php
} 


$PASSWORD = trim(file_get_contents(dirname(__FILE__).'/private/PASSWORD'));
if (
    isset($_POST['Update']) &&
    isset($_POST['Password']) &&
    $_POST['Password'] === $PASSWORD
) {
    update();
} else {
    form();
}
