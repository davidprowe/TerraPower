    Function Clone-TerraRepo {

        Param (
            [Parameter(Mandatory=$true)]
            [String]
            $SourceRepo,
            [Parameter(Mandatory=$true)]
            [String]
            $DestinationRepo <#,
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
            $Region,
            [Parameter(Mandatory=$false)]
            [String]
            $Commands,
            [Parameter(Mandatory=$false)]
            [String]
            $OptVarsFile   #> 
        )#END PARAMETER ENTRY
        #Need to update the beginning to have destination repo set to a variable that takes the last folder or name of the path given
        # rename item on backend does not work if a full path is entered for destination repo
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
                    foreach ($line in $tfcontentNewVars){
                        if ($line -match "Key"){
                                   $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($key+".tfstate")))
                        }#end if match Key
                        $i++
                    }#end new line match and replace
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
                                   $tfcontentNewVars[$i] = $line.split("=")[0] + " = " + ($line.split("=")[1].replace($($line).split("=")[1],($key+".tfstate")))
                        }#end if match Key
                        $i++
                    }#end new line match and replace on tfcontentnewvars

                } #end no Key variable set - took key setting from tfcontentnewvars and imported it into the tfcontent file
                #take all necessary variables from tfcontentnewvars and enter into tfcontent
                $tfupdatelist = @("backend","encrypt","bucket","key","region","commands")
                foreach($tf in $tfupdatelist){
                    $i = 0
                    foreach ($line in $tfcontent){
                        if ($line -match $tf){
                                   $tfcontent[$i] = $tfcontentNewVars -match $tf
                        }#end if match Key
                        $i++
                    }#end new line match and replace

                }#end updating tfcontent with variables from tfcontentnewvars
                $tfcontent|Out-File -FilePath ($DestinationRepo + "\terraform.tfvars")
                #out variable tfcontent to new terraform.tfvars file

            #update _backend.tf
            Get-ChildItem -Path $DestinationRepo -filter "*_backend.tf" | foreach-object {
                Rename-Item -path $_.fullname -NewName ($destinationrepo + "_backend.tf")
                }#end rename of the _backend.tf file
            
                } #end creation of new destination repo and copy of files into repo
        #
        else{
            BREAK
        }
        }

        get-childitem -path ($scriptpath + "\admpwd.ps") -recurse |Foreach-object {
        Copy-item -literalpath $_.fullname -destination "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\admpwd.ps"
}
        


    }
