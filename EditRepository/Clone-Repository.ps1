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
            $NewTfVarsName,
            [Parameter(Mandatory=$false)]
            [String]
            $Bucket,
            [Parameter(Mandatory=$false)]
            [String]
            $Region,
            [Parameter(Mandatory=$false)]
            [String]
            $Key,
            [Parameter(Mandatory=$false)]
            [String]
            $Encrypt
        )

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
            else {New-Item $DestinationRepo -ItemType Folder
                } #end creation of new destination repo folder
            #write-host sourcedir contains tfvar
            get-childitem -path ($sourcerepo) -recurse | Where-Object -Property FullName -notmatch ".terraform" | `
            Foreach-object {
                Copy-item -literalpath $_.fullname -destination $DestinationRepo
            } #end copying source files into the destination repo.
            #Update terraform.tfvars file


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
