# Todoey

https://code-examples.net/en/q/23c5e73


https://stackoverflow.com/questions/44006513/how-to-save-pdf-files-from-firebase-storage-into-app-documents-for-future-use

https://stackoverflow.com/questions/40251223/downloading-firebase-storage-files-device-issue/40413487#40413487



https://stackoverflow.com/questions/24055146/how-to-find-nsdocumentdirectory-in-swift
let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]


<Load local file>
https://stackoverflow.com/questions/42982666/loading-data-object-from-local-file-in-swift-3


<firebase -> From Database : select file by value >
https://stackoverflow.com/questions/44625257/swift-select-from-firebase-by-child-value
  
 <Firebase/Database][I-RDB034028] Using an unspecified index. Your data will be downloaded and filtered on the client. Consider adding ".indexOn": "fileName">
 https://stackoverflow.com/questions/46372756/firebase-error-consider-adding-indexon?rq=1
https://stackoverflow.com/questions/35540080/firebase-indexon-security-rules-not-working

 {
    "rules": {
         ".read": true,
         ".write": true,    
         "Data" : {
             ".indexOn": "fileName/animal"
         }

        }
    }
