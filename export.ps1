[CmdletBinding()]
param (
	[Parameter()]
	[Switch]
	$DebugExport
)

$project_name_key = "config/name"
$project_version_key = "config/version"

$config = ([xml](Get-Content '.\export_config.xml')).config
if (Test-Path '.\export_config.user.xml') {
	$config_user = ([xml](Get-Content '.\export_config.user.xml')).config
}

$exports = $config.exports.export

$version_prefix = $config.version_prefix

$git_main_branch = $config.git_main_branch

$NoVersionIncrement = $true

if ($config_user -and $config_user.godot_command) {
	$godot_command = $config_user.godot_command
}
else {
	$godot_command = $config.godot_command
}

$additional_command_args = $config.additional_args

if (!(Test-Path -PathType Leaf .\project.godot)) {
	Write-Error "Couldn't find project.godot: must be run from project root"
	exit 1;
}

# $test_path_result = Test-Path "$godot_command"
# if (! $test_path_result) {
	# do {
		# $godot_command = Read-Host -Prompt "Godot path invalid. Enter Godot executable path"
		# $test_path_result = Test-Path "$godot_command"
	# }
	# while (! $test_path_result)

	# # Write to the user file. This is a hack and should be replaced
	# $outputXml = @'
# <?xml version="1.0" encoding="UTF-8"?>
# <config>
	# <godot_command>
# '@
	# $outputXml += $godot_command
	# $outputXml += @'
# </godot_command>
# </config>
# '@
	# "$outputXml" | Out-File -FilePath '.\export_config.user.xml'
# }


#====  PROJECT NAME  ====#

# Get the project name from project.godot
$project_name_groups = (Select-String -Path .\project.godot -Pattern "$project_name_key=""(.*)""").Matches.Groups

if ($project_name_groups) {
	$project_name = $project_name_groups[1].Value
}
else {
	Write-Error "Invalid project.godot: missing or empty project name ($project_name_key)"
	exit 1;
}

#====  VERSION - GET AND UPDATE  ====#

# Get the version from project.godot
# Note that this must end with a number, which is what will be considered the build number
$version_groups = (Select-String -Path .\project.godot -Pattern "$project_version_key=""((.*)([0-9]+))""").Matches.Groups

$version_string = "$version_prefix$project_version"

if ($version_groups) {
	# Set the version string
	$project_version = $version_groups[1].Value
	$version_string = "$version_prefix$project_version"

	# If on non-main branch, append the commit number
	if ((git rev-parse --abbrev-ref HEAD) -ne $git_main_branch -or $DebugExport) {
		$commit = (git rev-parse --short HEAD)
		
		if ($commit) {
			$version_string = "$version_string $commit"
		}
	}
	elseif (!$NoVersionIncrement) {
		# Update the version if on main branch
		$rev_number = $version_groups[3].Value
		$rest = $version_groups[2].Value

		$new_rev_number = [int]$rev_number + 1

		$new_version = "$rest$new_rev_number"

		Write-Host "Updating project version ($project_version_key) from $rest$rev_number to $new_version" -ForegroundColor Green

		(Get-Content .\project.godot) `
			-replace "$project_version_key="".*""", "$project_version_key=""$new_version""" |
		Out-File .\project.godot -Encoding ASCII
	}
}
else {
	Write-Host "Couldn't find project version ($project_version_key), ommitting from export path" -ForegroundColor Red
	$version_string = ""
}

#====  FOR USE IN CONFIGURABLE VERSIONED FILES  ====#
$project_and_version = "$project_name$version_string"
function ReplaceValues {
	param (
		[string]
		$Val
	)
	
	$Val = $Val -replace "\[project_and_version\]", "$project_name$version_string"
	$Val = $Val -replace "\[project\]", "$project_name"
	$Val = $Val -replace "\[version\]", "$version_string"
	return $Val
}

#====  CREATE BASE DIRECTORIES  ====#

$exports_base_dir = ReplaceValues $config.exports_base_dir
Write-Host "Project name: '$project_name'"
Write-Host "Version: '$project_version'"
Write-Host "Exports base dir: '$exports_base_dir'"
New-Item -Path "$exports_base_dir" -ItemType Directory


#====  EXPORT TEMPLATES FROM CONFIG  ====#

foreach ($export in $exports) {
	$export_name = $export.name

	# Get zip file name (if blank use default)
	$zip_file_no_extension = "[project_and_version]_$export_name"

	if ($export.zip_file_name) {
		$zip_file_no_extension = $export.zip_file_name
	}
	$zip_file_no_extension = ReplaceValues $zip_file_no_extension

	$export_zip_file = "$zip_file_no_extension.zip"

	# Get export file name (if blank use default)
	$export_file_name = "$[project_and_version]_$export_name"

	if ($export.file_name) {
		$export_file_name = $export.file_name
	}

	$export_file_name = ReplaceValues $export_file_name


	$export_path = "$exports_base_dir\$export_name"
	$export_file_path = "$export_path\$export_file_name"

	$export_switch = "--export-release"
	if ($DebugExport) {
		$export_switch = "--export-debug"
	}

	Write-Host "Creating directory for export '$export_name': $export_path" -ForegroundColor Green
	New-Item -Path "$export_path" -ItemType Directory

	Write-Host "Exporting for '$export_name', to file $export_file_path" -ForegroundColor Green
	$cmd_args = "$export_switch ""$export_name"" ""$export_file_path"" $additional_command_args"
	Write-Host "> $godot_command $cmd_args"
	Start-Process -Wait "$godot_command" "$cmd_args"
	
	Write-Host "Compressing contents of '$export_path\' to '$exports_base_dir\$export_zip_file'" -ForegroundColor Green
	Compress-Archive "$export_path\*" -DestinationPath "$exports_base_dir\$export_zip_file"
}