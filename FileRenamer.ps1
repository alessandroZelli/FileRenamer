
#Returns file as a collection of file names.
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFIleDialog.Multiselect = $true;
    #$OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileNames
}

#Returns true or false via a binary prompt that answers a single keypress
#All values but the
Function Get-BinaryPrompt($promptString,$promptControl){
    #promptString must be a yes/no questions
    #avoids editing stuff by mistake
    #$promptControl must be a single key ex."y"
    $tempUpdateController=Read-Host -prompt  $promptString 
    if($tempUpdateController.ToLower() -eq $promptControl.ToLower()){
        return $true
    }
    else{
        return $false
    }
    
}



#Returns size 2 array with fileName w/o extension at 0 and extension at 1
Function Split-Extension($fileName)
{
    try{
        $nameSplit = $fileName -split "\."
        $ext = $nameSplit[$nameSplit.Count -1]
        $returnArr = @()
        if ($ext -eq "old"){
            $maxRange  = $nameSplit.Count -3
            $name = $nameSplit[0..$maxRange]
            $returnArr[0] = $name
            $returnArr[1] = $ext
        }
        else{
            $maxRange  = ($nameSplit.Count -2)
            $name = $nameSplit[0..$maxRange]
            $returnArr += $name
            $returnArr += $ext
        }
        return $returnArr
        
    }catch{
        Write-Host "file has no extension"
    }
}

Function Rename-File($filepath, $replacer)
{
     Rename-item -LiteralPath "$filepath" -NewName "$replacer"
}


	
do{
    $FAILED = $false
    $SUCCESS = $false
    #Write-Host "Inserire il filepath"
    
    #$filepath= Read-Host
    
    Write-Host "Select the files to rename"
    $nameArray = @(Get-FileName "C:\")
    Write-Host $nameArray
    $listSize = $nameArray.Count
    Try{
        
        $newName = Read-Host -Prompt "Insert new file name"
        
        if($listSize -lt 2){
            $oldFile = $nameArray[0]
            $oldName = Split-Path -Path $oldFile -Leaf
            
            
        
            if(Get-BinaryPrompt "$oldName will be renamed $newName. Continue?(y/n)" "y" ){
    
                if(Get-BinaryPrompt "Would you like to change extension? (y/n)" "y"){
                    $EXTPARSED=$false
                    do{
				        $newExt = Read-Host -prompt  "Insert the new extension ex. <.txt>"
					    $newExt = $newExt.Trim();
                    if(!([string]::IsNullOrEmpty($newExt))){
                        $EXTPARSED = $true
                    }                        					    
                    }while($EXTPARSED)
                    $newName += ".$newExt"
                    Rename-File $oldFile $newName
                }else{
                    $splitName = Split-Extension $oldName
                    $newName += "."+$splitName[1]
                    Rename-File $oldFile $newName
                    Write-Host "File renamed."
                    pause
                    $SUCCESS = $true
					}
				}
            else{
                Throw "File Not Found"
            }
             
        }elseif($nameArray.Count -gt 1){
            $oldFile = $nameArray[0]
            $oldName = Split-Path -Path $oldFile -Leaf
           if(Get-BinaryPrompt "$listSize files will be renamed to $newName[1..$listSize].ext. Continue(y/n)" "y"){
                if(Get-BinaryPrompt "Would you like to change extension? (y/n)" "y"){
                     
                        $ext = Read-Host -prompt  "Insert the new extension without the point ex. <txt>"
                     
                }
                else{
                    $splitName = Split-Extension $oldName
                    $ext = $splitName[1]
                    }
    
                for ($i=0;$i -lt $listSize;$i++){
                        $t=1+$i
                        $replacer = $newName + "[$t]" + "."+$ext
                        Rename-File $nameArray[$i] $replacer
                    }
    
                Write-Host "$listSize files renamed."
                $SUCCESS = $true
                
            }
        }
    }catch{
                $_
                Write-Host "Errore"
                $FAILED=$true
               }
}while($FAILED -and $SUCCESS)

#C:\Users\Utente\Documenti\WebDev\Trevigiana\TrevigianaWebsite\Content\Smart-Medium-Premium