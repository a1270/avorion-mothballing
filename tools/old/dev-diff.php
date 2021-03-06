<?php

// this script will generate all the diffs that can be used for patching the
// avorion source with these modifications.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

define('ProjectRoot','..');
define('StockDir', '/avorion-stock');
define('ModDir', '/avorion-mothballing');
define('PatchDir', '/avorion-mothballing/patches');

define('Files',[
	'/data/scripts/commands/mothball.lua'            => '/Patch-Commands-Mothball.diff',
	'/mods/DccMothballing/ConfigDefault.lua'         => '/Patch-Mods-DccMothballing-ConfigDefault.diff',
	'/mods/DccMothballing/Commands/Enable.lua'       => '/Patch-Mods-DccMothballing-Commands-Enable.diff',
	'/mods/DccMothballing/Commands/Disable.lua'      => '/Patch-Mods-DccMothballing-Commands-Disable.diff',
	'/mods/DccMothballing/Entity/MothballedShip.lua' => '/Patch-Mods-DccMothballing-Entity-MothballedShip.diff'
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
