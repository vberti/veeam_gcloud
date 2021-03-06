#############################################################
# Rotina de Backup dos arquivos do VEEAM                    #
#                                                           #
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe #
# E:\Script\backup_veeam.ps1                                #
#                                                           #
# 01/08/2017 - Add: Comparativo logs para assunto do Email  #
# 10/07/2017 - Adicionado o log de envio do Google          # 
# 14/06/2017 - Adicionado o tamanho do conjunto em MB       # 
# 08/06/2017 - Implementação                                #
#############################################################

#############################################################
# Variáveis                                                 #
#############################################################
$rotina_var = "e:\Script"
$log = "$rotina_var\log_envio_veeam.log"
$date = Get-Date -Format yyyyMMdd
$data_inicio_processo = Get-Date -Format G

#Email
$smtpserver = "192.168.1.200"
$fromaddress = "from_address@email.com"
$toaddress = "to_address@email.com"

#Busca os arquivos criados nas últimas () horas.
$tempo = '-6'

#Google LOG
#Não esqueca de iniciar o a auth do GCloud !!!!!!!
#Pode-se importar a chave (como JSON) e use para autenticar
#gcloud auth activate-service-account --key-file=D:\chave_gcloud.json

$manifest = 1
$log_google="$rotina_var\log_google_envio1.log"
$log_google_temp="$rotina_var\log_google_temp_1" + $manifest + '.log'

#Storage dos arquivos do VEEAM
$folder_backup = 'E:\Veeam\Backup\'

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

If (Test-Path $log_google){
  Remove-Item $log_google }

If (Test-Path $log_google_temp){
  Remove-Item $log_google_temp }



echo "╔══════════════════════════════════════════════════════════════════╗" | Out-File -Append $log
echo "║                       LOG  - Backup Google                       ║" | Out-File -Append $log
echo "╚══════════════════════════════════════════════════════════════════╝" | Out-File -Append $log
echo "" | Out-File -Append $log

############################################################
# Veeam                                                    #   
############################################################

#Alterar o parametro ADDHOURS, para encontrar os arquivos especificos                                                                          
$Files_all = Get-ChildItem $folder_backup -Include * -Exclude *.vbm -recurse | ? {!($_.psiscontainer) -AND $_.lastwritetime -gt (get-date).AddHours($tempo)}

#Arquivos
$Files = $Files_all | % { $_.ToString() }

#Qtd of files
$count_files = $Files_all.Count

#Tamanho dos arquivos
$Size = $Files_all | Select-Object -property Length

#Converte em MB e deixa 2 casas
$totalSize = ((($Size | Measure-Object -Sum Length).Sum)/1024/1024)
$Size_valor = [math]::Round($totalSize,2)

#Lista os arquivos a serem enviados
echo "Arquivos a serem enviados: " | Out-File -Append $log
echo "" | Out-File -Append $log
echo $Files | Out-File -Append $log
echo "" | Out-File -Append $log
echo "Arquivo(s): $count_files" | Out-File -Append $log
echo "Tamanho: $Size_valor (Mb)" | Out-File -Append $log
echo "" | Out-File -Append $log

echo "─══════════════════════════════════════════════════════════════════─" | Out-File -Append $log
echo "" | Out-File -Append $log

$data_inicio = Get-Date -Format HH:mm:ss
echo "Enviando arquivos em: $data_inicio" | Out-File -Append $log

#processo de loop, enviando cada arquivo
foreach ($File in $Files) {
        
   $path = Split-Path $File
   $path_google = ("gs://bucket" + $path + "/" -replace '\\', '/' ) -replace ('E:/','/')
       
   gsutil cp -L $log_google_temp $File $path_google

   $manifest = $manifest +1
   
   #Para testar, descomente as linhas abaixo e comente a de cima!!!!
   #echo "gsutil cp $File $path_google"
   #Start-Sleep -s 10
}

$data_fim = Get-Date -Format HH:mm:ss
echo "     Fim do processo: $data_fim" | Out-File -Append $log
CalculaTempo

echo "─══════════════════════════════════════════════════════════════════─" | Out-File -Append $log

############################################################
# Verifica o log (mail and google)                         #
############################################################

#Le o log do Google e conta quantas linhas com a palavra OK.
Get-Content $log_google_temp | ? {$_.trim() -ne "" } | set-content $log_google

#Le o log do Google e conta quantas linhas com a palavra OK.
$ok_log_google = @( Get-Content $log_google | Where-Object { $_.Contains(",OK,") } ).Count

#Se o numero de arquivos for <> do OK contados, error.
if ($ok_log_google -ne $Files_all.Count){

#Se ok, assunto do email para SUCESSO, se não, FALHA
$Subject = "[Falha] Relatório de envio - VEEAM (Google Cloud)"
echo "" | Out-File -Append $log
echo "Foi encontrado erro(s) nos logs de envio."  | Out-File -Append $log
echo "Verifique a conectividade do servidor, espaço em disco, storage, Google API e arquivo(s) a ser enviados."  | Out-File -Append $log
}
else {
$Subject = "[Sucesso] Relatório de envio - VEEAM (Google Cloud)"
}

If (Test-Path $log_google_temp){
  Remove-item $log_google_temp }

############################################################
# Email                                                    #
############################################################
$body = (Get-Content $log | out-string )
$attachment = $log_google
################################################# 
$message = new-object System.Net.Mail.MailMessage 
$message.From = $fromaddress 
$message.To.Add($toaddress) 
$message.Subject = $Subject 
$attach = new-object Net.Mail.Attachment($attachment) 
$message.Attachments.Add($attach) 
$message.body = $body 
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 
$smtp.Send($message) 