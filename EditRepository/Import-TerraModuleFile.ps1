
#gotta figure out lines that begine with "module * {" - because like the main.tf that is the building block of a new environment
#lines that begin with # are commented out - possible skip those or . remove all spaces into a temp imported file and check for module*{ then output that it is a module file
    # to which it then runs a different work stream.
function Import-TerraModuleFile{
    Param (
            [Parameter(Mandatory=$true)]
            [String]
            $file
    )#end param entry
    $array = @{}
    try{
        #Ignore lines beginning with #
        $file = Foreach ($line in (Get-Content -Path $file | Where {$_ -notmatch '^#.*'})) {$line}

        $modulelist = @()
        ($file -replace "`n","" -replace "`r","," -replace "  "," " ) -split "," |ForEach-Object {
           #find the modules by splitting on lines starting with module
           if ($_ -like "*module*`"*`"*{*"){
                #Split the module name into a new hashtable
                $newhash = ($_ -split "`"" |where {$_ -notlike '*module '}|where {$_ -notlike ' {'})
                iex ('$' + $newhash  + '= @{}' )
                $modulelist += $newhash
                
           
           }
           }#end creating new hash tables
           #make modules 
           foreach ($module in $modulelist){
           <#
            $file|foreach-object {if ($_ -like "*$module*"){write-host $_ on line $i
            $i++}}
            module "create_P3_DC" { on line 17

           #>
           $i = 0
                ($file -replace "`n","" -replace "`r","," -replace "  "," " ) -split "," |ForEach-Object {
               #find the modules by splitting on lines starting with module
               
               if($_ -like "*$module*"){
               write-host "line $i looks like $module"
               $startingline = $i
               }
               else {
               $i++
               }
               }#end getting line count for starting line

           }#end foreach module loop

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