<?php

// this script will generate all the diffs that can be used for patching the
// avorion source with these modifications.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

define('ProjectRoot','..');
define('StockDir', '/avorion-stock/data/scripts');
define('ModDir', '/avorion-mothballing/data/scripts');
define('PatchDir', '/avorion-mothballing/patches');

define('Files',[
	'/commands/mothballs.lua'           => '/patch-commands-mothballs.diff',
	'/lib/dcc-mothballs/enable.lua'     => '/patch-lib-dcc-mothballs-enable.diff',
	'/lib/dcc-mothballs/disable.lua'    => '/patch-lib-dcc-mothballs-disable.diff',
	'/lib/dcc-mothballs/main.lua'       => '/patch-lib-dcc-mothballs-main.diff'
]);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function
Pathify(String $Filepath):
String {
/*//
generate proper file paths for the os given that we are writing the code for
forward slashes in mind. seems to be needed for some windows commands.
//*/

	$Filepath = str_replace('%VERSION%','Version',$Filepath);

	return str_replace('/',DIRECTORY_SEPARATOR,$Filepath);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

$File;
$Patch;
$Command;

foreach(Files as $File => $Patch) {
	$Command = sprintf(
		'diff -urN %s %s > %s',
		escapeshellarg((ProjectRoot.StockDir.$File)),
		escapeshellarg((ProjectRoot.ModDir.$File)),
		escapeshellarg(Pathify(ProjectRoot.PatchDir.$Patch))
	);

	echo $Command, PHP_EOL;
	system($Command);
}
