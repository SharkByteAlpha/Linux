####################################
#        Just In Case Stuff        #
####################################

Do {
    $test1 = Get-Content $env:Linux-main\OHS_UB\users.txt
    $test2 = Get-Content $env:Linux-main\OHS_UB\admins.txt
    if ([string]::IsNullOrWhitespace($test1)){
        Write-Host "Please add authorized users to users.txt"
    }
    if ([string]::IsNullOrWhitespace($test2)){
        Write-Host "Please add authorized admins to admins.txt"
    }
    if ([string]::IsNullOrWhitespace($test1) -or [string]::IsNullOrWhitespace($test2)){
        Pause
    }
} Until ([string]::IsNullOrWhiteSpace($test1) -ne $true -and [string]::IsNullOrWhiteSpace($test2) -ne $true)

########################################
#        Authorized User Checks        #
########################################

Add-Type -AssemblyName PresentationFramework 
$secure_pw = ConvertTo-SecureString "Cyb3rP@tr10t212!" -AsPlainText -Force

#Creating User Accounts
Get-Content $env:SystemDrive\OHS_WIN\users.txt | ForEach-Object {
    $userexistscheck = Get-LocalUser -Name $_ -ErrorAction SilentlyContinue
    if($userexistscheck){
        Return
    }
    New-LocalUser -FullName $_ -Name $_ -password $secure_pw -ErrorAction Ignore
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Created User" $_ -ForegroundColor White
}

#Creating Admin Accounts
Get-Content $env:SystemDrive\OHS_WIN\admins.txt | ForEach-Object {
    $userexistscheck = Get-LocalUser -Name $_ -ErrorAction SilentlyContinue
    if($userexistscheck){
        Return
    }
    New-LocalUser -FullName $_ -Name $_ -password $secure_pw -ErrorAction Ignore
    Add-LocalGroupMember Users $_ -ErrorAction Ignore
    Add-LocalGroupMember Administrators $_ -ErrorAction Ignore
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Created Administrator" $_ -ForegroundColor White
}

#Enabling User Accounts
Get-Content $env:SystemDrive\OHS_WIN\users.txt | ForEach-Object {
    $userenabledcheck = Get-LocalUser -Name $_ | select Enabled
    if($userenabledcheck){
        return
    }
    Enable-LocalUser $_
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Enabled User" $_ -ForegroundColor White
}

#Enabling Admin Accounts
Get-Content $env:SystemDrive\OHS_WIN\admins.txt | ForEach-Object {
    $userenabledcheck = Get-LocalUser -Name $_ | select Enabled
    if($userenabledcheck){
        return
    }
    Enable-LocalUser $_
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Enabled Administrator" $_ -ForegroundColor White
}

#Adding Users to User Group
Get-Content $env:SystemDrive\OHS_WIN\admins.txt | ForEach-Object {
    Add-LocalGroupMember Users $_ -ErrorAction Ignore
}

#Adding Admins to Admin Group
Get-Content $env:SystemDrive\OHS_WIN\admins.txt | ForEach-Object {
    Add-LocalGroupMember Users $_ -ErrorAction Ignore
    $admincheck = Get-LocalGroupMember Administrators $_
    if ($admincheck){
        return
    }
    Clear-Variable -Name "admincheck"
    Add-LocalGroupMember Administrators $_ -ErrorAction Ignore
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Made User" $_ "An Administrator" -ForegroundColor White
}

##########################################
#        Unauthorized User Checks        #
##########################################

$exclude = @(
    "Administrator"
    "DefaultAccount"
    "WDAGUtilityAccount"
    "Guest"
    "OHSadm"
    "OHSgst"
    $env:UserName
    Get-Content $env:SystemDrive\OHS_WIN\users.txt
    Get-Content $env:SystemDrive\OHS_WIN\admins.txt
)  

Get-LocalUser | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }
    if ($_.Enabled -ne $true) {
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Unauthorized user" $_.Name.Split('\')[-1] "is already disabled" -ForegroundColor White
        return
    }
    $message = "Would you like to disable "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'"'
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Disable-LocalUser $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Disabled" $_.Name.Split('\')[-1] -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped disabling" $_.ObjectClass $_.Name.Split('\')[-1] -ForegroundColor White
    }
}

$GroupName = "Administrators"
$exclude = @(
    "Administrator"
    "OHSadm"
    $env:UserName
    Get-Content $env:SystemDrive\OHS_WIN\admins.txt
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Access Control Assistance Operatorsa"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName -erroraction 'silentlycontinue' | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Backup Operators"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Cryptographic Operators"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Device Owners"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Distributed COM Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Event Log Readers"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Backup Operators"
$exclude = @(
    $env:UserName

)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Hyper-V Administrators"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "IIS_IUSRS"
$exclude = @(
    $env:UserName
    "IUSR"
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Network Configuration Operators"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Performance Log Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Performance Monitor Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Power Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Remote Desktop Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Remote Management Users"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "Replicator"
$exclude = @(
    $env:UserName
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

$GroupName = "System Managed Accounts Group"
$exclude = @(
    $env:UserName
    "DefaultAccount"
)  

Get-LocalGroupMember $GroupName | ForEach-Object {
    if ($_.Name.Split('\')[-1] -in $exclude) {
        return
    }

    $message = "Would you like to remove "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'" from group '+$GroupName
    $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

    if ($continue -eq 'Yes') {
        Remove-LocalGroupMember -Group $GroupName -Member $_.Name
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Removed" $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
    else{
        Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Manually skipped removing" $_.ObjectClass $_.Name.Split('\')[-1] "from group" $GroupName -ForegroundColor White
    }
}

########################################
#        User Password Changer         #
########################################

# Script: ChangeUserPasswordsScript.ps1

# Prompt the user to enter a password using a GUI
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object Windows.Forms.Form
$form.Text = "Enter Password"
$form.Size = New-Object Drawing.Size(300, 150)
$form.StartPosition = "CenterScreen"

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point(10, 20)
$label.Size = New-Object Drawing.Size(280, 20)
$label.Text = "Enter password for all users:"
$form.Controls.Add($label)

$passwordBox = New-Object Windows.Forms.TextBox
$passwordBox.Location = New-Object Drawing.Point(10, 50)
$passwordBox.Size = New-Object Drawing.Size(260, 20)
$passwordBox.PasswordChar = '*'
$form.Controls.Add($passwordBox)

$okButton = New-Object Windows.Forms.Button
$okButton.Location = New-Object Drawing.Point(75, 90)
$okButton.Size = New-Object Drawing.Size(75, 23)
$okButton.Text = "OK"
$okButton.Add_Click({
    $form.Tag = $passwordBox.Text
    $form.DialogResult = [Windows.Forms.DialogResult]::OK
    $form.Close()
})
$form.Controls.Add($okButton)

$cancelButton = New-Object Windows.Forms.Button
$cancelButton.Location = New-Object Drawing.Point(150, 90)
$cancelButton.Size = New-Object Drawing.Size(75, 23)
$cancelButton.Text = "Cancel"
$cancelButton.Add_Click({
    $form.DialogResult = [Windows.Forms.DialogResult]::Cancel
    $form.Close()
})
$form.Controls.Add($cancelButton)

$form.AcceptButton = $okButton
$form.CancelButton = $cancelButton

$result = $form.ShowDialog()

if ($result -eq [Windows.Forms.DialogResult]::OK) {
    $enteredPassword = $form.Tag

    # Process the entered password
    if ([string]::IsNullOrWhiteSpace($enteredPassword)) {
        Write-Host "[01 - User Management] " -ForegroundColor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Passwords were not changed because the answer was null. Please try again." -ForegroundColor Yellow
    } else {
        $pw = ConvertTo-SecureString $enteredPassword -AsPlainText -Force
        $users = Get-LocalUser | Where-Object { $exclude -notcontains $_.Name }

        foreach ($user in $users) {
            Set-LocalUser -Name $user.Name -Password $pw
        }

        Write-Host "[01 - User Management] " -ForegroundColor Cyan -BackgroundColor DarkBlue -NoNewline
        Write-Host "Changed All User Passwords." -ForegroundColor White
    }
} else {
    Write-Host "[01 - User Management] " -ForegroundColor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Password change operation was canceled." -ForegroundColor Yellow
}


#############################################
#        User Remover (Last Resort)         #
#############################################

$message = "Would you like to fully delete users? (It is reccomended to wait until later in the competition)"
$continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

if ($continue -eq 'Yes') {
    $exclude = @(
        "Administrator"
        "DefaultAccount"
        "WDAGUtilityAccount"
        "Guest"
        $env:UserName
        Get-Content $env:SystemDrive\OHS_WIN\users.txt
        Get-Content $env:SystemDrive\OHS_WIN\admins.txt
    )  

    Get-LocalUser | ForEach-Object {
        if ($_.ObjectClass -ne 'User') {
            return
        }
        
        if ($_.Name.Split('\')[-1] -in $exclude) {
            return
        }

        $message = "Would you like to delete "+$_.ObjectClass+' "'+$_.Name.Split('\')[-1]+'"'
        $continue = [System.Windows.MessageBox]::Show($message, "User Management", 'YesNo')

        if ($continue -eq 'Yes') {
            Remove-LocalUser $_.Name
            Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
            Write-Host "Disabled" $_.Name.Split('\')[-1] -ForegroundColor White
        }
        else{
            Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
            Write-Host "Manually skipped disabling" $_.ObjectClass $_.Name.Split('\')[-1] -ForegroundColor White
        }
    }
}
else{
    Write-Host "[01 - User Management] " -Foregroundcolor Cyan -BackgroundColor DarkBlue -NoNewline
    Write-Host "Manually skipped removing users" -ForegroundColor White
}
