###CheckForLatestBuild.ps1
###Created 4/14/2017
###Author:  PJG

Set-Variable -name DebugPreference -value Continue

Write-Debug "$?: Checking for a $env:SWStream and $env:SWBuild build..."

#Find the latest folder on Devsilo release build 
#New-Variable -Name PreviousBuildNumber -value null
Set-Variable -name DevSiloBuild -value \\devsilo1\CurrentBuilds\QaBuilds\sw$env:SWStream_unicode_$env:SWBuild64
Set-Variable -name FileForPreviousBuild -value PreviousBuild.txt
Set-Variable -name LatestDevSiloBuild -value (Get-ChildItem $DevSiloBuild | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime -desc | Select-Object -first 1)
Write-Debug "$?: Latest build is: $LatestDevSiloBuild "

#Make sure the needed directory exists and if not, create them:
$env:RUN_SW_BUILD_HERE = "C:\\Builds\\Automation"
$env:SW_ENVIRONMENT_PROPERTIES = "C:\\Automation"


Set-Variable -name strFileName -value $env:SW_ENVIRONMENT_PROPERTIES\env.properties
If (Test-Path $strFileName){
	Write-Debug "$?: Remove the pre-existing env.properties file"
	Remove-Item $strFileName
	New-Item $strFileName -ItemType file
} else {
	Write-Debug "$?: First run on this machine, no env.properties file so create the path"
	New-Item -ItemType Directory -Force -Path $env:SW_ENVIRONMENT_PROPERTIES
}
##New-Item $strFileName -ItemType file
Add-Content $strFileName "SWBuild=$env:SWBuild"
Add-Content $strFileName "SWStream=$env:SWStream"
Add-Content $strFileName "RUN_SW_BUILD_HERE=$env:RUN_SW_BUILD_HERE"

#Checking for what we new was the latest build during the previous check
if (Test-Path $FileForPreviousBuild -PathType Leaf) {
    Get-Content $FileForPreviousBuild | Foreach-Object{
        $var = $_.Split('=')
        Set-Variable -Name $var[0] -Value $var[1]
        if ($var[0] -match 'BuildNumber') {
            $PreviousBuildNumber = $var[1]
        }
    }
    Write-Debug "$?: Previous build was: $PreviousBuildNumber "
    Set-Variable -name NewBuildNumber -value $LatestDevSiloBuild.Name
    Set-Variable -name StringForFile -value "BuildNumber=$NewBuildNumber"
    Write-Debug "$?: The potential string to be written is: $StringForFile "
    #Test that the build is really there, may be inaccessible
    if (Test-Path -Path $DevSiloBuild\$NewBuildNumber\finished.txt) {
        if ($NewBuildNumber -eq $PreviousBuildNUmber) {
            #Nothing to do here, same build
            Write-Debug "$?: Nothing to do here, same build"
            exit 0
        }
        else {
            #We need to start a new test now
            $StringForFile | Out-File $FileForPreviousBuild
            Write-Debug "$?: A new build is ready, start testing now."
            exit 1
        }
    }
    else {
        #The build is not ready yet
        Write-Debug "$?: There is a new build, however the build is not ready yet"
        exit 0
    }
} 
else {
    #We need to create a new file as this is the first run, don't forget to run the tests
    New-Item $FileForPreviousBuild -type file
    $StringForFile | Out-File $FileForPreviousBuild
    Write-Debug "$?: Wrote out the initial file to monitor results"
    exit 1
}