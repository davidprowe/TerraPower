    Function Clone-TerraRepo {

        Param (
            [Parameter(Mandatory=$true)]
            [String]
            $SourceRepo,
            [Parameter(Mandatory=$true)]
            [String]
            $DestinationRepo,
            [Parameter(Mandatory=$false)]
            [String]
            $Backend,
            [Parameter(Mandatory=$false)]
            [String]
            $Encrypt,
            [Parameter(Mandatory=$false)]
            [String]
            $Bucket,
            [Parameter(Mandatory=$false)]
            [String]
            $Key,
            [Parameter(Mandatory=$false)]
            [String]
            $KeyFolder,
            [Parameter(Mandatory=$false)]
            [String]
            $Region,
            [Parameter(Mandatory=$false)]
            [String]
            $Commands<#,
            [Parameter(Mandatory=$false)]
            [String]
            $OptVarsFile   #> 
        )#END PARAMETER ENTRY
        
        #check path for source
    if (!(Test-Path $SourceRepo)) {Write-warning "-message Folder: `"$SourceRepo`" Does not exist.  Please specify a valid Source repository"
        BREAK
        }#End test source repo check
    #check repository    
    else{
        #check for a tfvars file, if tfvar settings file  exists in the entered repo
        if((get-childitem -Path $sourcerepo |Where-Object -Property name -like "*.tfvars") -ne $null)
        {
            #successfully found tfvar, now to make a destination directory for copying all source files
            if ((test-path $DestinationRepo) -eq 1) {write-host $DestinationRepo already exists. Skipping folder creation.}
            else {New-Item $DestinationRepo -ItemType Directory
                } #end creation of new destination repo folder
            #write-host sourcedir contains tfvar
            get-childitem -path ($sourcerepo) -recurse | Where-Object -Property FullName -Notlike "*.terraform*" | `
            Foreach-object {
                Copy-item -literalpath $_.fullname -destination $DestinationRepo
            } #end copying source files into the destination repo.
            #Update terraform.tfvars file
            $tfvarfile = $DestinationRepo + "\terraform.tfvars"
            $tfcontent = get-content $tfvarfile
            $tfcontentNewVars = @()
            #fix - only replace spaces on lines with an equal sign
            $tfcontent = $tfcontent.Replace(" ","")
                $i = 0
                foreach ($c in $tfcontent){
                    if ($c -like "*=*"){
                        $c = $c.Replace(" ","") #remove insane number of spaces
                        if (($c.split("="))[1].length -eq 1) {
                            $c = ($c.split("=")[0]) + " = " + ($c.Split("=")[1]).replace("$($c.Split('=')[1])","$($tfcontent[($i+1)])")
                        }#if length after = is 1 or less, go to next line
                        else{
                            $c = $c.Replace("="," = ")

                        }#add back spaces
                     $tfcontentNewVars += $c   
                    }#end if line contains an =
                    $i++
                }#end parsing variables from current tfcontent file into var tfcontentnewvars
                if ($PSBoundParameters.ContainsKey('Key') -eq $true) {
                    $i = 0
                    
                    if ($PSBoundParameters.ContainsKey('KeyFolder') -eq $true) {
                        foreach ($line in $tfcontentNewVars){
                            if ($line -match "Key"){
                                        #creating tfvars file with key param, keyfolder param present
                                       $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($keyfolder + "/" + $key+".tfstate")))
                            }#end if match Key
                            $i++
                        }#end new line match and replace

                    } #end check for keyfolder param
                    else{
                        foreach ($line in $tfcontentNewVars){
                            if ($line -match "Key"){
                                        #creating tfvars file with key param, no keyfolder
                                       $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($key+".tfstate")))
                            }#end if match Key
                            $i++
                        }#end new line match and replace
                    }# end no keyfolder param - key goes to default root of s3

                }#end psbound check for key variable
                else{
                    $i = 0
                    foreach ($line in $tfcontentNewVars){
                        if ($line -match "Key"){
                                #split destination repo to the last folder if a full path is given
                                if($DestinationRepo[$destinationrepo.Length -1] -eq "\"){
                                    $l = $DestinationRepo.Length -1
                                    $DestinationRepo = $DestinationRepo.Substring(0,$l)
                                }#if destinationrepo ends in "\" remove the \ for splitting of name
                                else{}#do nothing if the last character is not \

                                if($DestinationRepo.Split("\").Count -gt 1){
                                    $key = ($DestinationRepo.Split("\"))[($DestinationRepo.Split("\").count-1)]
                                }#end if check to see if destination repo is full folder path
                                else{
                                    $key = $DestinationRepo
                                }#end else check to se if destination repo is not full folder path

                                if ($PSBoundParameters.ContainsKey('KeyFolder') -eq $true) {
                                                   $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($keyfolder + "/" + $key+".tfstate")))
                                } #end check for keyfolder param
                                    #creating tfvars file with definationrepo as name of key value
                                   $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($key+".tfstate")))
                        }#end if match Key
                        $i++
                    }#end new line match and replace on tfcontentnewvars

                } #end no Key variable set - took key setting from tfcontentnewvars and imported it into the tfcontent file
                $paramcheckloop = @("backend","Encrypt","bucket","region","commands") #standard replace on tfvars lines.  No special editing to lines needed, simple replace
                foreach ($paramcheck in $paramcheckloop){
                    if ($PSBoundParameters.ContainsKey($varcheck) -eq $true){
                        $i = 0
                        foreach ($line in $tfcontentNewVars){
                            if ($line -match $paramcheck){
                                        #creating tfvars file with key param, keyfolder param present
                                       $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($paramcheck)))
                            }#end if match Key
                            $i++
                        }#end new line match and replace
                    }#end if varscheckloop variable is entered into script
                }
                
                else{} #end foreach paramcheck loop. do nothing to the tfvars with  - copy it from source tfvars file.

                #take all necessary variables from tfcontentnewvars and enter into tfcontent
                $tfupdatelist = @("backend","encrypt","bucket","key","region","commands")
                foreach($tf in $tfupdatelist){
                    $i = 0
                    foreach ($line in $tfcontent){
                        if ($line -like "$tf*"){
                                   $tfcontent[$i] = $tfcontentNewVars -like "$tf*=*"
                                   
                        }#end if match Key
                        $i++
                    }#end new line match and replace

                }#end updating tfcontent with variables from tfcontentnewvars
                $tfcontent|Out-File -FilePath ($DestinationRepo + "\terraform.tfvars")
                #out variable tfcontent to new terraform.tfvars file

            #update _backend.tf
            
            if($DestinationRepo[$destinationrepo.Length -1] -eq "\"){
                                    $l = $DestinationRepo.Length -1
                                    $DestinationRepo = $DestinationRepo.Substring(0,$l)
                                }#if destinationrepo ends in "\" remove the \ for splitting of name
                                else{}#do nothing if the last character is not \

                                if($DestinationRepo.Split("\").Count -gt 1){
                                    $backendname = ($DestinationRepo.Split("\"))[($DestinationRepo.Split("\").count-1)]
                                }#end if check to see if destination repo is full folder path
                                else{
                                    $backendname = $DestinationRepo
                                }
            
            
            Get-ChildItem -Path $DestinationRepo -filter "*_backend.tf" | foreach-object {
                Rename-Item -path $_.fullname -NewName ($backendname + "_backend.tf")
                }#end rename of the _backend.tf file
            
                } #end creation of new destination repo and copy of files into repo
        #
        else{
            BREAK
        }
        }

}