#############################################################
# Rotina de Download de arquivo unico                       #
# by Vinicius Berti                                         #
#                                                           #
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe #
# E:\Script\download_google.ps1                             #
#                                                           #
# 11/07/2017 - Implantação                                  #         
#############################################################

#############################################################
# Variáveis                                                 #
#############################################################
$rotina_var = "e:\Script"
$local_restore = "e:\Restore"
$date = Get-Date -Format yyyyMMdd
$data_inicio_processo = Get-Date -Format G
$log = "$rotina_var\log_download_google.txt"

#Google LOG
$log_google="$rotina_var\log_google.txt"
$log_google_temp="$rotina_var\log_temp.txt"


#############################################################
# QUAL ARQUIVO ????                                         #
# Deixar /nacional......                                    #
#############################################################
$file_restore = '/backupnacional/BackupCorpore/RM_20170817.rar'
#############################################################

#Function
function CalculaTempo{
$TimeDiff = New-TimeSpan $data_inicio $data_fim
if ($TimeDiff.Seconds -lt 0) {
	$Hrs = ($TimeDiff.Hours) + 23
	$Mins = ($TimeDiff.Minutes) + 59
	$Secs = ($TimeDiff.Seconds) + 59 }
else {
	$Hrs = $TimeDiff.Hours
	$Mins = $TimeDiff.Minutes
	$Secs = $TimeDiff.Seconds }

if ($TimeDiff.Days -gt 0) {
    $Difference = '({0:00}:{1:00}:{2:00}) ({3:00})Dia(s) ' -f $Hrs,$Mins,$Secs,$TimeDiff.Days
    }
else {
    $Difference = '({0:00}:{1:00}:{2:00})' -f $Hrs,$Mins,$Secs
     }
echo "                     $Difference"  | Out-File -Append $log
echo "" | Out-File -Append $log
}

############################################################
# Header                                                   #   
############################################################
If (Test-Path $log){
  Remove-Item $log }

If (Test-Path $log_google_temp){
  Remove-Item $log_google_temp }

  If (Test-Path $log_google){
  Remove-Item $log_google }


Write-Host "#############################################################" -ForegroundColor Red
Write-Host "#############################################################" -ForegroundColor Red
Write-Host "### Download do arquivo: " -ForegroundColor White
Write-Host "### $file_restore " -ForegroundColor white
Write-Host "#############################################################" -ForegroundColor Red
Write-Host "#############################################################" -ForegroundColor Red
Write-Host ""

echo "╔══════════════════════════════════════════════════════════════════╗" | Out-File -Append $log
echo "║                   LOG RESTORE  - Backup Google                   ║" | Out-File -Append $log
echo "╚══════════════════════════════════════════════════════════════════╝" | Out-File -Append $log
echo "" | Out-File -Append $log


$data_inicio = Get-Date -Format HH:mm:ss
echo "Fazendo download em : $data_inicio" | Out-File -Append $log


gsutil cp -L $log_google_temp gs:/$file_restore $local_restore


$data_fim = Get-Date -Format HH:mm:ss
echo "     Fim do processo: $data_fim" | Out-File -Append $log
CalculaTempo

echo "─══════════════════════════════════════════════════════════════════─" | Out-File -Append $log

#Log de arquivos - GOOGLE
Get-Content $log_google_temp | ? {$_.trim() -ne "" } | set-content $log_google
If (Test-Path $log_google_temp){
  Remove-Item $log_google_temp }


############################################################
# Email                                                    #
############################################################

$smtpserver = "192.168.1.134"
$fromaddress = "envio@nacionalacos.com.br"
$toaddress = "informatica2@nacionalacos.com.br" 
$Subject = "Relatório de envio - Download (Google Cloud)"
$body = (Get-Content $log | out-string )
$attachment = $log_google
 
################################################# 
 
$message = new-object System.Net.Mail.MailMessage 
$message.From = $fromaddress 
$message.To.Add($toaddress) 
#$message.IsBodyHtml = $True 
$message.Subject = $Subject 
$attach = new-object Net.Mail.Attachment($attachment) 
$message.Attachments.Add($attach) 
$message.body = $body 
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 
$smtp.Send($message)