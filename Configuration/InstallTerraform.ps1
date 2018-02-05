
$checks = 0
#check for existence of AWS connection
$awsCredFile = "$env:USERPROFILE\.aws"
    if ((Test-Path $awsCredFile) -eq 0) {
        Write-Warning "AWS Credential File not found"
        Write-warning "Please configure a default connection to connect to AWS by using `'AWS CONFIGURE`'"
        Write-warning "To download the latest aws cli release navigate to https://github.com/aws/aws-cli/releases"
    }
    else {
        $checks++
        write-host "AWS Credential file successfully found" -ForegroundColor Green
    }
#check for existence of terraform.exe
$terraformEXE = "Terraform.exe"
    if ((Get-Command $terraformEXE -ErrorAction SilentlyContinue) -eq $null)
        {write-warning "$terraformEXE Not found in %PATH%.  Please install the copy the exe to your %path% by downloading it from from `"https://www.terraform.io/downloads.html`""}  
    else{
        $checks++
        write-host "$terraformEXE file successfully found" -ForegroundColor Green
    }
#check for existence of terraform.exe
$terragruntEXE = "terragrunt.exe"
    if ((Get-Command $terragruntEXE -ErrorAction SilentlyContinue) -eq $null)
        {write-warning "$terragruntEXE Not found in %PATH%.  Please install the copy the exe to your %path% by downloading it from from `"https://github.com/gruntwork-io/terragrunt/releases/`""} 
    else{
        $checks++
        write-host "$terragruntEXE file successfully found" -ForegroundColor Green
    }

    if ($checks -eq 3){
        write-host ""
        write-host "All validation checks complete.  Terraform can successfully connect to your AWS instance -ForegroundColor Green"
        write-host ""

    }