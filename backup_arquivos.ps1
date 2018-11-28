############################################################@##
# Rotina de Backup, que mapeia o Storage,encontra os arquivos #
# criados nas últimas @PAR horas e envia para o cloud ,neste  #
# exemplo, Google Cloud                                       #
#                                                             #
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe   #
# backup_arquivos.ps1                                         #
#                                                             #
# 01/08/2017 - Add: Comparativo logs para assunto do Email    #
# 10/07/2017 - Log do Google de envio                         #         
# 08/06/2017 - Implementação                                  #         
###############################################################

#############################################################
# Variáveis                                                 #
#############################################################
$rotina_var = "E:\Script"
$date = Get-Date -Format yyyyMMdd
$data_inicio_processo = Get-Date -Format G
$log = "$rotina_var\log_envio_storage.log"

#Email
$smtpserver = "192.168.1.200"
$fromaddress = "from_address@email.com"
$toaddress = "to_address@email.com"

#Busca os arquivos criados nas últimas () horas.
$tempo = '-16'

#Google LOG
#Não esqueca de iniciar o a auth do GCloud !!!!!!!
#Pode-se importar a chave (como JSON) e use para autenticar
#gcloud auth activate-service-account --key-file=D:\chave_gcloud.json

$manifest = 1
$log_google="$rotina_var\log_google_envio.log"
$log_google_temp="$rotina_var\log_google_temp_" + $manifest + '.log'

#Storage
$storage_path = "\\192.168.1.110\backup"
$pass="P@$$w0rd"|ConvertTo-SecureString -AsPlainText -Force
$login = New-Object System.Management.Automation.PsCredential("user_storage",$pass)

#Pasta de backup.
$folder_backup = 'X:\'

#Function para calcular o tempo
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
#Pra ter certeza =]
net use * /delete /yes

If (Test-Path $log){
  Remove-Item $log }

If (Test-Path X:\){
  Remove-PSDrive X }

If (Test-Path $log_google){
  Remove-Item $log_google }

If (Test-Path $log_google_temp){
  Remove-Item $log_google_temp }


echo "╔══════════════════════════════════════════════════════════════════╗" | Out-File -Append $log
echo "║                       LOG  - Backup Google                       ║" | Out-File -Append $log
echo "╚══════════════════════════════════════════════════════════════════╝" | Out-File -Append $log
echo "" | Out-File -Append $log

############################################################
# Arquivos do Storage                                      #   
############################################################

#Mapeamento de rede, para storage do backup, (X:) - OBS - PS 3.0!!!!!!! <=====
New-PSDrive –Name “X” –PSProvider FileSystem –Root $storage_path –Persist -Credential $login

#Alterar o parametro ADDHOURS, para encontrar os arquivos 
$Files_all = Get-ChildItem $folder_backup -Include * -recurse | ? {!($_.psiscontainer) -AND $_.lastwritetime -gt (get-date).AddHours($tempo)}

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

#processo de loop, enviando cada arquivo , neste caso, GCloud
foreach ($File in $Files) {
        
   $path = Split-Path $File
   $path_google = ("gs://nome_bucket" + $path + "/" -replace '\\', '/' ) -replace ('X:/','/')
       
   #Comando do Google Cloud SDK para enviar os arquivos
   gsutil cp -L $log_google_temp $File $path_google
   
   $manifest = $manifest +1

   #Para testar, descomente as linhas abaixo e comente a linha gsutil!
   #echo "gsutil cp $File $path_google"
   #Start-Sleep -s 2
}

$data_fim = Get-Date -Format HH:mm:ss
echo "     Fim do processo: $data_fim" | Out-File -Append $log
CalculaTempo

echo "─══════════════════════════════════════════════════════════════════─" | Out-File -Append $log

#Desconecta tudo
If (Test-Path X:\){
  Remove-PSDrive X }
  net use * /delete /yes

############################################################
# Verifica o log (mail and google)                         #
############################################################

#Log - GOOGLE
Get-Content $log_google_temp | ? {$_.trim() -ne "" } | set-content $log_google

#Le o log do Google e conta quantas linhas com a palavra OK.
$ok_log_google = @( Get-Content $log_google | Where-Object { $_.Contains(",OK,") } ).Count

#Se o numero de arquivos for <> do OK contados, error.
if ($ok_log_google -ne $Files_all.Count){

#Se ok, assunto do email para SUCESSO, se não, FALHA
$Subject = "[Falha] Relatório de envio - Arquivos Storage (Google Cloud)"
echo "" | Out-File -Append $log
echo "Foi encontrado erro(s) nos logs de envio."  | Out-File -Append $log
echo "Verifique a conectividade do servidor, espaço em disco, storage, Google API e arquivo(s) a ser enviados."  | Out-File -Append $log
}
else {
$Subject = "[Sucesso] Relatório de envio - Arquivos Storage (Google Cloud)"
}

If (Test-Path $log_google_temp){
  Remove-item $log_google_temp }


############################################################
# Email                                                    #
############################################################
$body = (Get-Content $log | out-string )
$attachment = $log_google
$message = new-object System.Net.Mail.MailMessage 
$message.From = $fromaddress 
$message.To.Add($toaddress) 
$message.Subject = $Subject 
$attach = new-object Net.Mail.Attachment($attachment) 
$message.Attachments.Add($attach) 
$message.body = $body 
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 
$smtp.Send($message) 