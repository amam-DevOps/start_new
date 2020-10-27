
$rg = "azure_test_group"

foreach ($i in 13..20) {
    New-AzStorageAccount `
     -ResourceGroupName $rg `
     -name "StorageTest$i" `
     -skuname Standard_LRS `
     -Location 'South Central US'    
}

Get-AzStorageAccount | foramt-list

stop-azvm -resourcegroup "azure_test" -name "testazurevm" -force 
new-azvm -resourcegroup test_azure -name test_azure_vm -location 
#------------------------------------------------------------------


$array1=@()
$carry_process = get-process

foreach ($i in $carry_process) { 
    if ($i.CPU -gt 1) {
    $array1 += new-object psobject -property @{'ProcessName' =$i.name ; 'WorkingSet' = $i.ws}
}
    
}
$array1

#----------------------------------------------------------------
$input_client = Read-host "Please enter the value for switch?"

switch ($input_client)
{
1 {write-host "you choose a really good option" -foregroundcolor green}
default {write-host "you made a wrong choice ur sukkle!" -foregroundcolor red}

}

#---------------------- introduce the variable thingy

