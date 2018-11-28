
# veeam_gcloud
Script de backup dos arquivos do VEEAM para Gcloud, em powershell.
Todos os parâmetros estão nos cabeçalhos dos arquivos.

Arquivos validados em W2k8R2 , W2k12 e W2k16.

#### Exemplos de email - VEEAM 
```
╔══════════════════════════════════════════════════════════════════╗
║                       LOG  - Backup Google                       ║
╚══════════════════════════════════════════════════════════════════╝

Arquivos a serem enviados: 

E:\Veeam\Backup\SISTEMA_103\SISTEMA_103D2017-08-29T200023.vib
E:\Veeam\Backup\SISTEMA_112\SISTEMA_112D2017-08-29T200349.vib
E:\Veeam\Backup\SISTEMA_114\SISTEMA_114D2017-08-29T200654.vib
E:\Veeam\Backup\SISTEMA_115\SISTEMA_115D2017-08-29T201243.vib
E:\Veeam\Backup\SISTEMA_124\SISTEMA_124D2017-08-29T201546.vib
E:\Veeam\Backup\SISTEMA_134\SISTEMA_134D2017-08-29T202047.vib
E:\Veeam\Backup\SISTEMA_144\SISTEMA_144D2017-08-29T202415.vib
E:\Veeam\Backup\SISTEMA_154\SISTEMA_154D2017-08-29T202853.vib
E:\Veeam\Backup\SISTEMA_218\SISTEMA_218D2017-08-29T203417.vib

Arquivo(s): 9
Tamanho: 17836.06 (Mb)

─══════════════════════════════════════════════════════════════════─

Enviando arquivos em: 22:00:05
     Fim do processo: 22:51:59
                     (00:51:54)

─══════════════════════════════════════════════════════════════════─
```

#### Exemplos de email com arquivos diversos
```
╔══════════════════════════════════════════════════════════════════╗
║                       LOG  - Backup Google                       ║
╚══════════════════════════════════════════════════════════════════╝

Arquivos a serem enviados: 

X:\BackupDATABASE\ERP_DATA_20170829.rar
X:\BackupPONTO\Ponto_20170829.rar
X:\BackupDEVELOPER\files_bkp_20170829.rar
X:\BackupOPS\ops_system_20170829.rar
X:\BackupSISTEMA\SISTEMA_20170829_inc.RAR
X:\BackupSISTEMA\SISTEMA_campinas_20170829111758.rar
X:\BackupSISTEMA\SISTEMA_holambra_20170829180753.rar
X:\BackupSISTEMA\SISTEMA_campinas_20170829171757.rar

Arquivo(s): 7
Tamanho: 3450.77 (Mb)

─══════════════════════════════════════════════════════════════════─
Enviando arquivos em: 00:00:06
     Fim do processo: 00:11:59
                     (00:11:53)
─══════════════════════════════════════════════════════════════════─
```

