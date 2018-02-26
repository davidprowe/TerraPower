
#gotta figure out lines that begine with "module * {" - because like the main.tf that is the building block of a new environment
#lines that begin with # are commented out - possible skip those or . remove all spaces into a temp imported file and check for module*{ then output that it is a module file
    # to which it then runs a different work stream.
function Import-TerraHCLFile{
    Param (
            [Parameter(Mandatory=$true)]
            [String]
            $file
    )#end param entry
    $array = @{}
    try{$file = get-content -path $file

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

