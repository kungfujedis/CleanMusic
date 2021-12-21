$Settings = Import-Csv '.\Clean Music Settings.csv'
$MusicPath = $Settings.MusicPath
$PhonePath = $Settings.PhonePath
$TrackingPath = '.\Clean Music Tracking.csv'

Write-Host "Music path: $MusicPath"
Write-Host "Phone staging path: $PhonePath"
$New = Read-Host "Continue or set new paths? [C]/N?"

if($New -eq 'N')
    {
    $MusicPath = Read-Host "Enter new music path"
    $PhonePath = Read-Host "Enter new phone staging path"
    "MusicPath,PhonePath" | Out-File '.\Clean Music Settings.csv' -Encoding ascii
    $MusicPath + "," + $PhonePath | Out-File '.\Clean Music Settings.csv' -Encoding ascii -Append    
    }

$Music = Get-ChildItem $MusicPath -Recurse
$Phone = 
$Tracking = Import-Csv $TrackingPath

foreach($File in $Music)
    {
    if($file.extension -eq ".mp3" -or $file.extension -eq ".wma" -or $file.extension -eq ".mp4" -or $file.extension -eq ".m4a" -or $file.extension -eq ".flac")
        {
        $FilePath = "`"" + $File.FullName + "`""

        $Run = $True
        foreach($Record in $Tracking)
            {
            if($File.FullName -eq $Record.Path)
                {
                $Run = $False
                }
            }

        if($Run)
            {
            $Choice = "r"    
            Write-Host "Now Playing:" $FilePath   
            While($Choice -eq "r")
                {            
                Start-Process -Wait "C:\Program Files\VideoLAN\VLC\vlc.exe" -argumentlist "$FilePath --play-and-exit"
                $Choice = "k"            
                $Choice = Read-Host "[Keep], Delete, Replay or send to Phone? K/D/R/P"
                if($Choice -eq "")
                    {
                    $Choice = "k"
                    }
                if($Choice -eq "d")
                    {
                    Write-Host "Deleting " $File.Fullname
                    Remove-Item $File.FullName
                    }
                if($Choice -eq "p")
                    {
                    Write-Host "Copying to phone staging..." $File.Fullname
                    Copy-Item $File.Fullname $PhonePath
                    }
                if($Choice -ne "r")
                    {
                    $Choice + "," + $FilePath | Out-File -FilePath $TrackingPath -Encoding ascii -Append
                    }
                }
            }
        
        }
    }
