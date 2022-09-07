function Get-ComponentData {
    $componentData = Get-ChildItem -Path 'C:\Usre\Components' -Recurse | `
    Where-Object { $_.PSIsContainer -eq $false -and $_.Extension -eq '.json' } | `
    Select-Object  BaseName, @{Name="FilePath";Expression={$_.FullName}}

    return $componentData
}

function Show-Components ($componentData) {
    Write-host "`nTotal : "$componentData.Count "Components `n"
    ForEach($component in $componentData)
    {
        $name = $component.BaseName
        Write-output "$name"
    }
}

function Read-Metadata {
    $metadata = @()
    $meta = Read-Host -prompt 'Do you want to add Metadata? (Y/N) '
    if ($meta -eq 'y') {
        do
        {
            Write-host "Please, Enter details for Metadata" 
            $metaName = Read-Host -prompt 'Enter Name '
            $metaValue = Read-Host -prompt 'Enter Value '
            $meta = @{
                Name = $metaName;
                Value = $metaValue
            }
            $metadata += $meta
            $exit = Read-Host " Do you want to add another value? (Y/N) "
        }
        while($exit -eq 'y')
    }
    return $metadata
}

function Write-CIFile ($componentInstances) {
    $tId = Read-Host -prompt 'Enter Id '
    $tCode = Read-Host -prompt 'Enter Short Code '
    $DestinationFileName = $tCode + '_' + $tId + '.json'
    $componentInstances | ConvertTo-Json -Depth 3 | Out-File C:\cisPS\$DestinationFileName
}

$yesNo = Read-Host -prompt 'Do you want to add Components to Component Instance File? (Y/N) '
if ($yesNo -eq 'y')
{
    # List of Components in Components folder
    $componentData = Get-ComponentData
    # Add Components
    $componentInstances = @()
    do 
    {
        $componentName = Read-Host -prompt "Please, Enter Component Name"
        $flag = $true
        ForEach($component in $componentData){
            if($component.BaseName.ToLower() -eq "$componentName".ToLower())
            {
                $flag = $false
                $componentObject = Get-Content $component.FilePath | Out-String | ConvertFrom-Json
                # Metadata of Component Instance
                $metadata = Read-Metadata
                $componentInstance = @{
                    Name = $componentObject.Name;
                    ComponentId = $componentObject.ComponentId;
                    CId = New-Guid;
                    Metadata = $metadata 
                }
                $componentInstances += $componentInstance
                break
            }
        }
        # Invalid Component Name
        if($flag -eq $true)
        {
            Write-output "Please, Enter valid Component Name" 
            $display = Read-Host -prompt 'Do you want to view available Components? (Y/N) '
            if ($display -eq 'y')
            {
                Show-Components $componentData
            }
        }
        $exitFromLoop = Read-Host " Do you want to add another Component? (Y/N) "                
    }
    while($exitFromLoop -eq 'y')
    # Generate Component Instance File
    $createFile = Read-Host -prompt 'Do you want to Create Component Instance File? (Y/N) '
    if ($createFile -eq 'y')
    {
        Write-host "Please, Enter details to generate Component Instance File" 
        Write-CIFile $componentInstances
        Write-output "Created Component Instance File..." 
    }
}
else {
    Write-output "No Components to Create Component Instance File..." 
}