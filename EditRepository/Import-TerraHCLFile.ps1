

<#get parameters by searching for each line that has a {
    if line has a bracket make first word a key value.  Search for next bracket
    
    if you find another bracket - make this new field a array with key values add a number to the bracket search, so that it has to find the next bracket

or maybe import file, remove all return characters and make array based on the values.
#>
function Import-TerraHCLFile{
    Param (
            [Parameter(Mandatory=$true)]
            [String]
            $file
    )#end param entry
    $array = @{}
    try{$file = get-content -raw -path $file

        ($file -replace "`n","" -replace "`r","," ) -split "," |ForEach-Object {
           if ($_ -like "*=*"){
               if ((($_ -split "=")[1] -replace '(^\s+|\s+$)','' -replace '\s+',' ').Length -gt 1) {
                   $array.Add((($_ -split "=")[0] -replace '(^\s+|\s+$)','' -replace '\s+',' '), (($_ -split "=")[1] -replace '(^\s+|\s+$)','' -replace '\s+',' '))
               }
           }
           else{}
        }
        $array
    }
    catch{
        write-warning Filename $file not found in directory
    }
    
}

