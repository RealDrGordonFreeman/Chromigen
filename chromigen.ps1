# ------------------------------------------------------------------------------------------------------------------------------------------ #

#  THIS SCRIPT REQUIRES POWERSHELL v6.0 OR HIGHER TO RUN

#  CHROMIUM INSTALLER & UPDATER FOR WINDOWS 8 & 10 (32-bit & 64-bit) FOR LATEST CHROMIUM BUILD.

# ------------------------------------------------------------------------------------------------------------------------------------------ #

cls

Write-Host "WELCOME TO THE CHROMIUM INSTALLER AND UPDATER FOR WINDOWS."

Write-Host "`n"

Write-Host "THIS WILL INSTALL OR UPDATE THE LATEST VERSION OF CHROMIUM DIRECTLY FROM THE CHROMIUM PROJECT @ https://commondatastorage.googleapis.com/chromium-browser-snapshots/"

Write-Host "`n"
    
    Read-Host -Prompt "Press ENTER to Continue";

Write-Host "`n"

Write-Host "CHROMIUM INSTALL/UPDATE NOW STARTING. IF CHROMIUM IS CURRENTLY OPEN OR RUNNING PLEASE CLOSE IT IMMEDIATELY.....";

# Get the latest update version and check if internet connection is available

Write-Host "`n"

Write-Host "Getting details of the latest Chromium version..."

Write-Host "`n"

# PowerShell HTTP(S) Web Request download function to display download progress, being defined early on here so it can be called anywhere where BITS is not being used

    function Download-File($url, $targetfile)

    {

    $uri = New-Object "System.Uri" "$url"

    $request = [System.Net.HttpWebRequest]::Create($uri)

    $response = $request.GetResponse()

    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)

    $responseStream = $response.GetResponseStream()

    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetfile, Create

    $buffer = New-Object byte[] 4KB

    $count = $responseStream.Read($buffer,0,$buffer.length)

    $downloadedBytes = $count

    while ($count -gt 0)

        {

            $targetStream.Write($buffer, 0, $count)

            $count = $responseStream.Read($buffer,0,$buffer.Length)

            $downloadedBytes = $downloadedBytes + $count

            Write-Progress -Activity "Chromium downloading from: '$($url)'" -Status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength) * 100)

        }

        Write-Progress -Activity "Chromium downloading from: '$($url)'" -Complete

        $targetStream.Flush()

        $targetStream.Close()

        $targetStream.Dispose()

        $responseStream.Dispose()
}

#Find out if this system is AMD64 or x86 (32-bit/64-bit)
if (([Environment]::Is64BitOperatingSystem) -eq $true) {

    $chromium_details_64 = $null

    while ([string]::IsNullOrEmpty($chromium_details_64)) {

    do { $chromium_details_64 = 

       try {  
                (Invoke-RestMethod -Uri 'https://www.googleapis.com/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2FLAST_CHANGE' -ErrorAction SilentlyContinue)
            }
    
        catch [System.Net.WebException] {
    
        $response = Read-Host "Internet connection error. Please check your internet connection and try again. [Q] to quit [ENTER] to continue."
        
        $quitnow = ! [bool]$response
        
        $quitnow = $response -eq "q"
        
            if ($response -eq "q") 
        
                {
                    exit;
                }       
            }
       }

    until (! [string]::IsNullOrEmpty($chromium_details_64))
                 
        Write-Output $chromium_details_64

    }

    $chromium_version_64 = ($chromium_details_64 | Select -ExpandProperty 'metadata' | Select -ExpandProperty 'cr-commit-position-number')

    Write-Host "`n"

    Write-Output "Latest Version:" "`n" $chromium_version_64

    Write-Host "`n"

    Write-Host "Would you like to download using the built-in PowerShell Web Request Client or using the Windows BITS downloader?"

    Write-Host "`n"

    Write-Host "The built-in PowerShell Web Request Client is good for reliable high-speed connections. The Windows BITS downloader uses idle network time, is slower, but much more reliable."
    
    Write-Host "`n"
    
    Write-Host "BITS should be used with unreliable or slow connections as BITS downloads can survive multiple connection interruptions."

    Write-Host "`n"
    
    $download64_choice = $null

    while ($download64_choice -notmatch "[1|2]") {

    $download64_choice = Read-Host -Prompt "Choose [1] to use the PowerShell Web Request Client or choose [2] to use the Windows BITS downloader....."
    
            if ($download64_choice -notmatch "[1|2]") 
            
                {

                    Write-Host "`n"

                    Write-Host "INVALID OPTION. PLEASE TRY AGAIN!" -BackgroundColor Red
                    
                    Write-Host "`n"

                }
     
            if ($download64_choice -eq 1) 
            
                {

                    Write-Host "`n"

                    Write-Host "Chromium is downloading. If the connection is interrupted, download should resume automatically. Use the Microsoft BITS download option on slower or unstable connections. Please wait....."

                    Download-File "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/${chromium_version_64}/chrome-win.zip" "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp"

                    If ((Test-Path -Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp") -eq $true)
                    
                        {
                    
                            Write-Host "`n"

                            Write-Host "File download complete. Finalizing download....."

                            Write-Host "`n"

                            Rename-Item -Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp" "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -Force -ErrorAction SilentlyContinue
                    
                        } 

                        
                        else

                        {

                            Write-Host "`n"

                            Write-Host "File download error. Try again." -BackgroundColor Red

                            Write-Host "`n"

                            $download64_choice = Read-Host -Prompt "Choose [1] to use the PowerShell Web Request Client or choose [2] to use the Windows BITS downloader....."

                        }

                    Write-Host "`n"

                    Write-Host "Chromium version $chromium_version_64 download has finished. The downloaded file has been placed within ${env:USERPROFILE}\AppData\Local\Temp\"

                }

            if ($download64_choice -eq 2) 
            
                {
    
                Write-Host "`n"

                $bits_download_job = $null

                $bits_download_job = (Start-BitsTransfer -DisplayName "Chromium Download....." -Source "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/${chromium_version_64}/chrome-win.zip" -Destination "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -Priority Normal -ErrorVariable bits_error -ErrorAction SilentlyContinue -Asynchronous)

                Get-BitsTransfer -Name "Chromium Download....."
                
                Write-Host "Starting download....."

                        while (($bits_download_job.JobState -eq "Connecting") -or ($bits_download_job.JobState -eq "Transferring"))

                            {
                                
                                Start-Sleep -s 1

                                $percent_download = [int](($bits_download_job.BytesTransferred * 100)/$bits_download_job.BytesTotal);

                                Write-Progress -activity "Downloading Chromium from: https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/${chromium_version_64}/chrome-win.zip" -status "Completed: $percent_download %" -PercentComplete $percent_download

                                if ($bits_download_job.JobState -match "TransientError")

                                    {
                                        
                                        Start-Sleep -s 5
                                        
                                        Write-Host "`n"

                                        Write-Host "Download connection interrupted. Download will automatically resume when connection is restored. Waiting....."

                                    }
                                                                                                
                                if ($bits_download_job.JobState -match "Connecting")

                                    {

                                        Write-Host "`n"
                                        
                                        Write-Host "Now connecting and downloading data....."

                                    } 
                                                                
                                while ($bits_download_job.JobState -match "Connecting")

                                    {

                                        Start-Sleep -s 5

                                    }    
                           
                                while ($bits_download_job.JobState -match "TransientError")

                                    {

                                        Start-Sleep -s 5

                                    }       
                                     
                                if ($bits_download_job.JobState -match "Transferred")

                                    {
                 
                                        Start-Sleep -s 5

                                        Complete-BitsTransfer -BitsJob $bits_download_job

                                        Write-Progress -activity "Downloading Chromium from: https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/${chromium_version_64}/chrome-win.zip" -status "Completed: $percent_download %" -PercentComplete $percent_download -Completed
                                    
                                    }
                                                        
                            }
         
                if ((Test-Path ${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip) -eq $True) 
                
                            {

                                Write-Host "`n"

                                Write-Host "Chromium download successful....."

                                Write-Host "`n"

                                Write-Host "Chromium version $chromium_version_64 download has finished. The downloaded file has been placed within ${env:USERPROFILE}\AppData\Local\Temp\"

                            }

                else 
                            {

                                Write-Host "`n"

                                Write-Host "Error. Chromium download failed!" -BackgroundColor Red
                 
                            }
                
                    }

            }

    }

else {

    $chromium_details_32 = $null

    while ([string]::IsNullOrEmpty($chromium_details_32)) {

    do { $chromium_details_32 = 

        try {  
                (Invoke-RestMethod -Uri 'https://www.googleapis.com/storage/v1/b/chromium-browser-snapshots/o/Win%2FLAST_CHANGE' -ErrorAction SilentlyContinue)
            }
    
        catch [System.Net.WebException] {
    
        $response = Read-Host "Internet connection error. Please check your internet connection and try again. [Q] to quit [ENTER] to continue."
        
        $quitnow = ! [bool]$response
        
        $quitnow = $response -eq "q"
        
            if ($response -eq "q") 
        
                {
                    exit;
                }       
            }
       }

    until (! [string]::IsNullOrEmpty($chromium_details_32))
                 
        Write-Output $chromium_details_32

    }

    $chromium_version_32 = ($chromium_details_32 | Select -ExpandProperty 'metadata' | Select -ExpandProperty 'cr-commit-position-number')

    Write-Host "`n"

    Write-Output "Latest Version:" "`n" $chromium_version_32

    Write-Host "`n"

    Write-Host "Would you like to download using the built-in PowerShell Web Client or using the Windows BITS downloader?"

    Write-Host "`n"

    Write-Host "The built-in PowerShell Web Client is good for reliable high-speed connections. The Windows BITS downloader uses idle network time, is slower, but much more reliable."
    
    Write-Host "`n"
    
    Write-Host "BITS should be used with unreliable or slow connections as BITS downloads can survive multiple connection interruptions."

    Write-Host "`n"

    $download32_choice = $null

    while ($download32_choice -notmatch "[1|2]") {

    $download32_choice = Read-Host -Prompt "Choose [1] to use the PowerShell Web Client or choose [2] to use the Windows BITS downloader....."

            if ($download32_choice -notmatch "[1|2]") 
            
                {

                    Write-Host "`n"
            
                    Write-Host "INVALID OPTION. PLEASE TRY AGAIN!" -BackgroundColor Red
 
                    Write-Host "`n"

                }
            
            if ($download32_choice -eq 1) {

                Write-Host "`n"

                Download-File "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/${chromium_version_32}/chrome-win.zip" "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp"

                 If ((Test-Path -Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp") -eq $true)
                    
                        {
                    
                            Write-Host "`n"

                            Write-Host "File download complete. Finalizing download....."

                            Write-Host "`n"

                            Rename-Item -Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip.tmp" "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -Force -ErrorAction SilentlyContinue
                    
                        } 

                        
                        else

                        {

                            Write-Host "`n"

                            Write-Host "File download error. Try again." -BackgroundColor Red

                            Write-Host "`n"

                            $download64_choice = Read-Host -Prompt "Choose [1] to use the PowerShell Web Request Client or choose [2] to use the Windows BITS downloader....."

                        }
                
                Write-Host "`n"

                Write-Host "Chromium version $chromium_version_32 download has finished. The downloaded file has been placed within ${env:USERPROFILE}\AppData\Local\Temp\"

                Write-Host "`n"

                Write-Host "Now proceeding with update/install...."

        }

              if ($download32_choice -eq 2) 
            
                {
    
                Write-Host "`n"

                $bits_download_job = $null

                $bits_download_job = (Start-BitsTransfer -DisplayName "Chromium Download....." -Source "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win/${chromium_version_32}/chrome-win.zip" -Destination "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -Priority Normal -ErrorVariable bits_error -ErrorAction SilentlyContinue -Asynchronous)

                Get-BitsTransfer -Name "Chromium Download....."
                
                Write-Host "Starting download....."

                        while (($bits_download_job.JobState -eq "Connecting") -or ($bits_download_job.JobState -eq "Transferring"))

                            {
                                
                                Start-Sleep -s 1

                                $percent_download = [int](($bits_download_job.BytesTransferred * 100)/$bits_download_job.BytesTotal);

                                Write-Progress -activity "Downloading Chromium from: https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win/${chromium_version_32}/chrome-win.zip" -status "Completed: $percent_download %" -PercentComplete $percent_download

                                if ($bits_download_job.JobState -match "TransientError")

                                    {
                                        
                                        Start-Sleep -s 5
                                        
                                        Write-Host "`n"

                                        Write-Host "Download connection interrupted. Download will automatically resume when connection is restored. Waiting....."

                                    }
                                                                                                
                                if ($bits_download_job.JobState -match "Connecting")

                                    {

                                        Write-Host "`n"
                                        
                                        Write-Host "Now connecting and downloading data....."

                                    } 
                                                                
                                while ($bits_download_job.JobState -match "Connecting")

                                    {

                                        Start-Sleep -s 5

                                    }    
                           
                                while ($bits_download_job.JobState -match "TransientError")

                                    {

                                        Start-Sleep -s 5

                                    }       
                                         
                                if ($bits_download_job.JobState -match "Transferred")

                                    {
                 
                                        Start-Sleep -s 1

                                        Complete-BitsTransfer -BitsJob $bits_download_job

                                        Write-Progress -activity "Downloading Chromium from: https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win/${chromium_version_32}/chrome-win.zip" -status "Completed: $percent_download %" -PercentComplete $percent_download -Completed
                                    
                                    }
                                                        
                            }
                              
                if ((Test-Path ${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip) -eq $True) 
                
                            {

                                Write-Host "`n"

                                Write-Host "Chromium download successful....."

                                Write-Host "`n"

                                Write-Host "Chromium version $chromium_version_32 download has finished. The downloaded file has been placed within ${env:USERPROFILE}\AppData\Local\Temp\"

                            }

                else 
                            {

                                Write-Host "`n"

                                Write-Host "Error. Chromium download failed!" -BackgroundColor Red
                 
                            }
                
                }

        }

    }

# Is this an update or a new install?

Write-Host "`n"

Write-Host "Is this a new install or an update?"

Write-Host "`n"

$type_choice = ""

while ($type_choice -notmatch "[1|2|3]") {

$type_choice = Read-Host "Choose [1] for INSTALL or [2] for UPDATE or [3] to EXIT....."

if ($type_choice -eq "1") { 

Write-Host "`n"

    Write-Host "INSTALL SELECTED"

# If INSTALL selected

            $drive_letter = ""

            while ($drive_letter -notmatch "[a-z,A-Z]") {

            Write-Output ([System.IO.DriveInfo]::GetDrives() | Format-Table)

            Write-Host "(Note: Chromium will be installed to a valid drive you choose within [DRIVE YOU CHOOSE]:\Users\$env:USERNAME\Applications\Chromium)"

            Write-Host "`n"

            $drive_letter = Read-Host "Choose installation drive. For example, enter the letter [c] to install to drive [C:\]...... "

            if ($drive_letter -match "[a-z,A-Z]") { 

                Write-Host "`n"

                Write-Host "Checking drive [${drive_letter}:], please wait....."
               
            }

            if ($drive_letter -notmatch "[a-z,A-Z]") {

                Write-Host "`n"

                Write-Host "ERROR. INVALID OPTION. TRY AGAIN." -BackgroundColor Red

                Write-Host "`n"
 
            }
          
            else {            
                        
                while ((Test-Path -Path ${drive_letter}:\ -IsValid) -eq $false) {

                    Write-Host "`n"

                    $drive_letter = Read-Host -Prompt "Drive is not a valid location or is experiencing issues. Choose drive again. For drive C:\ type [c] and press enter..... "
            
                    }

                if ((Test-Path -Path ${drive_letter}:\ -IsValid) -eq $true) {

                    Write-Host "`n"

                    Write-Host "Drive is valid."
                                   
                    Write-Host "`n"
                    
                    Write-Host "Checking for any possible running Chromium processes and closing them if found....."
                    
                        Start-Sleep -s 5

                        Get-Process chrome -ErrorAction SilentlyContinue | Foreach-Object {$_.CloseMainWindow() | Out-Null }

                        Start-Sleep -s 5

                        Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -force

                    Write-Host "`n"
                    
                    Write-Host "Checking for any possible existing Chromium Profiles....."

                    Start-Sleep -s 3
                    
                    if ((Get-Item -Path "${env:USERPROFILE}\AppData\Local\Chromium" -ErrorAction SilentlyContinue) -match "Chromium")
                
                        {

                            Write-Host "`n"

                            Write-Host "WARNING. AN EXISTING CHROMIUM PROFILE WAS FOUND FOR YOUR LOCAL WINDOWS USER ACCOUNT (NOT YOUR GOOGLE ACCOUNT OR ANY ONLINE ACCOUNT)." -BackgroundColor Red
                            
                            Write-Host "`n"

                            Write-Host "THE CHROMIUM PROFILE IS DIFFERENT FROM THE CHROMIUM APPLICATION - THE PROFILE CONTAINS ALL BOOKMARKS, EXTENSIONS, SETTINGS, AND OTHER PERSONALIZATIONS ON THIS COMPUTER ONLY." -BackgroundColor Red

                            Write-Host "`n"

                            Write-Host "YOU CAN LEAVE THIS EXISTING CHROMIUM PROFILE IN PLACE OR REMOVE IT. YOU CAN STILL PROCEED WITH A NEW CHROMIUM BUILD IF YOU LEAVE IT. IF YOU REMOVE IT, ANY EXISTING CHROMIUM DATA WILL BE ERASED!" -BackgroundColor Red

                            Write-Host "`n"

                            $profile_decision = $null
                            
                            while ($profile_decision -notmatch "[Y|N]")  {
                            
                            $profile_decision = Read-Host -Prompt "Press [Y] to remove existing Chromium Profile. Press [N] to leave the existing Chromium Profile in place and still proceed with installation of Chromium......"

                            Write-Host "`n"

                                if ($profile_decision -eq "Y")

                                    {

                                        Remove-Item -Path "${env:USERPROFILE}\AppData\Local\Chromium" -Force -ErrorAction SilentlyContinue -Recurse -Verbose

                                    }

                                if ($profile_decision -eq "N")

                                    {
                                         
                                        Write-Host "Proceeding with install while leaving existing Chromium Profile in place....."

                                        Write-Host "`n"
                              
                                    }
                                
                                if ($profile_decision -notmatch "[Y|N]")

                                    {
 
                                        Write-Host "ERROR. INVALID OPTION. TRY AGAIN." -BackgroundColor Red

                                        Write-Host "`n"
                    
                                    }

                            }                    

}

                    Write-Host "`n"

                    Write-Host "Creating installation directory....."

                    New-Item -Path "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\" -type directory -Force -ErrorAction SilentlyContinue
                    
                        if ((Test-Path -Path "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\") -eq $false) 
                    
                            {
                    
                                Write-Host "ERROR. INSTALLATION DIRECTORY COULD NOT BE CREATED. TERMINATING INSTALLATION/UPDATE PROCESS." -BackgroundColor Red
                                
                                Write-Host "`n"

                                Read-Host -Prompt "Press [ENTER] to quit."
                                
                                exit;

                            }
                       
                        else {

                                Write-Host "`n"

                                Write-Host "Installation directory created..."

                              }

                    Write-Host "`n"

                    Write-Host "Expanding downloaded data....."
                    
                    Write-Host "`n"
                        
                        if ((Test-Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip") -eq $false) 
                        
                            {
                                
                                Write-Host "Error. Downloaded data not found. Aborting installation/update." -BackgroundColor Red

                                Write-Host "`n"

                                Read-Host -Prompt "Press [ENTER] to quit."
                                
                                exit;
                    
                            }

                        Expand-Archive "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -ErrorAction Stop -Verbose -Destination "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\" -Force
                        
                        if ((Test-Path -Path "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\") -eq $false) 
                        
                            {
                                
                                Write-Host "Error. Files cannot be expanded. Aborting installation/update." -BackgroundColor Red

                                Write-Host "`n"

                                Read-Host -Prompt "Press [ENTER] to quit."
                                
                                exit;
                    
                            }
         
                            else {

                                Write-Host "`n"
                                
                                Write-Host "Files expanded..."

                              }    
                                        
                    Write-Host "`n"

                    Write-Host "(Chromium application was successfully installed at the following location:' ${drive_letter}:\Users\$env:UserName\Applications\Chromium\'. Now performing additional tasks.)"   
                    
                    Write-Host "`n"

                    $batch_choice = $null

                    while ($batch_choice -notmatch "[Y|N]") {

                        Write-Host "Would you also like to install batch file launchers for Chromium to set command line switches?"  
                        
                        Write-Host "`n"

                        Write-Host "If you choose YES, two batch files will be added to the \Chromium installation directory with some default command line switches already set. These can be edited at anytime."

                        Write-Host "`n"

                        Write-Host "If you do set/change any command line switches within the batch file launchers, you must save the files with ANSI encoding (not UNICODE)."

                        Write-Host "`n"
                        
                        $batch_choice = Read-Host -Prompt "Choose [Y] for YES or [N] for NO....."
                        
                        Write-Host "`n"

                        if ($batch_choice -eq "Y") { 

                                Write-Host "Now installing Chromium launcher batch files for Normal and Incognito launch modes....."

                                Write-Host "`n"
                                
                                #Add some standard command line switches, including disabling of old/currently unsafe cipher suites via hex for each suite to be disabled, etc.
                                Set-Content -Path ${drive_letter}:\Users\$env:UserName\Applications\Chromium\chromium_normal.bat -Passthru -Value "start `"`"` `"${drive_letter}:\Users\${env:UserName}\Applications\Chromium\chrome-win\chrome.exe`" --ssl-version-min=tls1.2 --cipher-suite-blacklist=0xc014,0xc013,0x8a8a,0xc007,0xc011,0x0066,0xc00c,0xc002,0x0005,0x0004,0x009c,0x009d,0x002f,0x0035,0x000a --profile-directory=Default --enable-potentially-annoying-security-features --enable-strict-mixed-content-checking"
                         
                                if ((Test-Path -Path "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\chromium_normal.bat") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Batch file for Chromium Normal mode not installed. Aborting installation/update." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit."
                                
                                            exit;
                    
                                        }
                           
                                        else {

                                            Write-Host "`n"
                                
                                            Write-Host "Batch file for Chromium Normal mode installed. The specific command line switches added to the batch file are shown above. Edit as required."

                                            Write-Host "`n"

                                          }    

                                Set-Content -Path ${drive_letter}:\Users\$env:UserName\Applications\Chromium\chromium_incognito.bat  -PassThru -Value "start `"`"` `"${drive_letter}:\Users\${env:UserName}\Applications\Chromium\chrome-win\chrome.exe`" --incognito --ssl-version-min=tls1.2 --cipher-suite-blacklist=0xc014,0xc013,0x8a8a,0xc007,0xc011,0x0066,0xc00c,0xc002,0x0005,0x0004,0x009c,0x009d,0x002f,0x0035,0x000a --profile-directory=Default --enable-potentially-annoying-security-features --enable-strict-mixed-content-checking"
                                
                                #Add some standard command line switches, including disabling of old/currently unsafe cipher suites via hex for each suite to be disabled, etc.
                                if ((Test-Path -Path "${drive_letter}:\Users\${env:UserName}\Applications\Chromium\chromium_incognito.bat") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Batch file for Chromium Incognito mode not installed. Aborting installation/update. Press [ENTER] to quit." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit."
                                
                                            exit;
                    
                                        }
                           
                                        else {

                                            Write-Host "`n"
                                
                                            Write-Host "Batch file for Chromium Incognito mode installed. The specific command line switches added to the batch file are shown above. Edit as required."

                                            Write-Host "`n"

                                          }  

                                Write-Host "Creating desktop shortcuts....."
                    
                                Write-Host "`n"   
                    
                                    $desktop_path = [Environment]::GetFolderPath("Desktop")
                        
                                    $WshShell = New-Object -ComObject WScript.Shell
                        
                                    $Shortcut_Normal = $WshShell.CreateShortcut("$desktop_path\Chromium.lnk")
                        
                                    $Shortcut_Normal.TargetPath = "$env:windir\System32\cmd.exe"
                        
                                    $Shortcut_Normal.Arguments = "/C `"${drive_letter}:\Users\$env:UserName\Applications\Chromium\chromium_normal.bat`""
                        
                                    $Shortcut_Normal.WorkingDirectory = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win"
                        
                                    $Shortcut_Normal.IconLocation = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe, 0"
                        
                                    $Shortcut_Normal.WindowStyle = 1

                                    $Shortcut_Normal.Save()
                      
                                    $WshShell = New-Object -ComObject WScript.Shell
                        
                                    $Shortcut_Incognito = $WshShell.CreateShortcut("$desktop_path\Chromium - Incognito.lnk")
                        
                                    $Shortcut_Incognito.TargetPath = "$env:windir\System32\cmd.exe"
                        
                                    $Shortcut_Incognito.Arguments = "/C `"${drive_letter}:\Users\$env:UserName\Applications\Chromium\chromium_incognito.bat`""
                        
                                    $Shortcut_Incognito.WorkingDirectory = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win"
                        
                                    $Shortcut_Incognito.IconLocation = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe, 2"
                        
                                    $Shortcut_Normal.WindowStyle = 1

                                    $Shortcut_Incognito.Save()
                            
                            }

                        if ($batch_choice -eq "N") {                         
                        
                                    Write-Host "Creating desktop shortcuts....."
                    
                                    Write-Host "`n"   
                    
                                    $desktop_path = [Environment]::GetFolderPath("Desktop")
                        
                                    $WshShell = New-Object -ComObject WScript.Shell
                        
                                    $Shortcut_Normal = $WshShell.CreateShortcut("$desktop_path\Chromium.lnk")
                        
                                    $Shortcut_Normal.TargetPath = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe"
                        
                                    $Shortcut_Normal.Arguments = ""
                        
                                    $Shortcut_Normal.WorkingDirectory = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win"
                        
                                    $Shortcut_Normal.IconLocation = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe, 0"
                        
                                    $Shortcut_Normal.WindowStyle = 1

                                    $Shortcut_Normal.Save()
                      
                                    $WshShell = New-Object -ComObject WScript.Shell
                        
                                    $Shortcut_Incognito = $WshShell.CreateShortcut("$desktop_path\Chromium - Incognito.lnk")
                        
                                    $Shortcut_Incognito.TargetPath = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe"
                        
                                    $Shortcut_Incognito.Arguments = "--incognito"
                        
                                    $Shortcut_Incognito.WorkingDirectory = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win"
                        
                                    $Shortcut_Incognito.IconLocation = "${drive_letter}:\Users\$env:UserName\Applications\Chromium\chrome-win\chrome.exe, 2"
                        
                                    $Shortcut_Normal.WindowStyle = 1

                                    $Shortcut_Incognito.Save()
                                
                            }

                            if ($batch_choice -notmatch "[Y|N]")

                                {

                                    Write-Host "ERROR. INVALID OPTION. TRY AGAIN." -BackgroundColor Red

                                    Write-Host "`n"

                                }


                        }        
                                    
                    Write-Host "Shortcuts created....."

                    Write-Host "`n"

                    Write-Host "Cleaning up....."

                    Write-Host "`n"

                    Remove-Item -Path "${env:USERPROFILE}\AppData\Local\Temp\chromium_download.zip" -Force

                }
            }              
        }
    }                

# If UPDATE is selected

if ($type_choice -eq "2") { 

    Write-Host "`n"

    Write-Host "UPDATE SELECTED"

    Write-Host "`n"

    Write-Host "Now searching for existing Chromium installations. Please wait...."

    Write-Host "`n"

    $drive = $null
    
    $SystemDrives = (Get-PSDrive -PSProvider FileSystem)
   
        foreach ($drive in $SystemDrives) {

                if ((Get-Item -Path "${drive}:\Users\Local User\Applications\Chromium\" -ErrorAction SilentlyContinue) -match "Chromium")
                
                        {

                            Write-Host "Installation found. Now beginning update. Be sure Chromium is not running and is fully closed......"
                            
                            Start-Sleep -s 5

                            if ((Get-Process chrome -ErrorAction SilentlyContinue) -eq $Null) 
                            
                            {
                            
                                Write-Host "`n"
                                
                                Write-Host "CHROMIUM IS NOT RUNNING. PROCEEDING WITH UPDATE....."
                                
                                Write-Host "`n" 
                                
                                Write-Host "Expanding downloaded data....."

                                Write-Host "`n" 
                        
                                    if ((Test-Path "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Downloaded data not found. Aborting installation/update." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit."
                                
                                            exit;
                    
                                        }

                                    Expand-Archive "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip" -ErrorAction Stop -Destination "${drive}:\Users\${env:UserName}\Applications\Chromium\" -Force -Verbose 

                                    if ((Test-Path -Path "${drive}:\Users\${env:UserName}\Applications\Chromium\") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Files cannot be expanded. Aborting installation/update." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit...."
                                
                                            exit;
                    
                                        }
                          
                                    else 
                                    
                                        {

                                            Write-Host "`n"
                                            
                                            Write-Host "Files expanded..."

                                            Write-Host "`n"

                                            Write-Host "Cleaning up....."

                                            Write-Host "`n"

                                            Remove-Item -Path "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip" -Force

                                            Remove-Item -Path "${drive}:\Users\${env:UserName}\Applications\Chromium\chrome-win\interactive_ui_tests.exe" -Force -ErrorAction SilentlyContinue
                                        
                                        }                                          
                                                   
                            }
                        
                        else 
                            
                            {
                        
                                Write-Host "`n"

                                Write-Host "WARNING: CHROMIUM IS RUNNING. CHROMIUM WILL BE FORCED CLOSED IF YOU CONTINUE....." -BackgroundColor Red
                            
                                Start-Sleep -s 5
                                
                                Write-Host "`n"

                                Read-Host -Prompt "PRESS [ENTER] TO FORCE CLOSE CHROMIUM AND BEGIN UPDATE....."

                                Get-Process chrome -ErrorAction SilentlyContinue | Foreach-Object {$_.CloseMainWindow() | Out-Null }

                                Start-Sleep -s 3

                                Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -force

                                Start-Sleep -s 1
                                
                                Write-Host "`n"

                                Write-Host "Removing previous Chromium version....."

                                Remove-Item -Path "${drive}:\Users\${env:UserName}\Applications\Chromium\chrome-win\" -Recurse -Force -ErrorAction SilentlyContinue
                                
                                Write-Host "`n"

                                Write-Host "Expanding downloaded data....."

                                Write-Host "`n"
                        
                                    if ((Test-Path "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Downloaded data not found. Aborting installation/update." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit."
                                
                                            exit;
                    
                                        }

                                    Expand-Archive "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip" -ErrorAction Stop -Destination "${drive}:\Users\${env:UserName}\Applications\Chromium\" -Force -Verbose

                                    if ((Test-Path -Path "${drive}:\Users\${env:UserName}\Applications\Chromium\") -eq $false) 
                        
                                        {
                                
                                            Write-Host "Error. Files cannot be expanded. Aborting installation/update." -BackgroundColor Red

                                            Write-Host "`n"

                                            Read-Host -Prompt "Press [ENTER] to quit...."
                                
                                            exit;
                    
                                        }
                          
                                    else 
                                    
                                        {

                                            Write-Host "`n"
                                            
                                            Write-Host "Files expanded..."

                                            Write-Host "`n"

                                            Write-Host "Cleaning up....."

                                            Write-Host "`n"

                                            Remove-Item -Path "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip" -Force
                                            
                                        }                                                                                                
                                
                            }

                        }
                                              
                    }
                                 
        foreach ($drive in $SystemDrives) {

                if ((Get-Item -Path "${drive}:\Users\Local User\Applications\Chromium\" -ErrorAction SilentlyContinue) -notmatch "Chromium")
                
                        {

                            Write-Host "Installation not found. Terminating update. Please be sure Chromium is installed before updating." -BackgroundColor Red 
                            
                            $type_choice = Read-Host "Choose [1] for INSTALL or [2] for UPDATE or [3] to EXIT....."
                                                                            
                        }
                                             
                    }
                     
                }
               
#FULL EXIT        

if ($type_choice -eq "3") { 

    Write-Host "`n"
    
    Write-Host "EXITING....."
    
    Remove-Item -Path "${env:UserProfile}\AppData\Local\Temp\chromium_download.zip" -Force -ErrorAction SilentlyContinue
    
    Start-Sleep -s 3;
    
    exit;
}

if ($type_choice -notmatch "[1|2|3]") {

    Write-Host "`n"
    
    Write-Host "ERROR. INVALID OPTION. TRY AGAIN" -BackgroundColor Red
 
    Write-Host "`n"
}

else 

    {
    
    Write-Host "CHROMIUM INSTALLATION/UPDATE COMPLETE!"
    
    Write-Host "`n"

    Write-Host "`n"

    Read-Host -Prompt "Press [ENTER] to exit..."
    
    }

}
