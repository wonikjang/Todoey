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
   
    
    
 {
    "rules": {
         ".read": true,
         ".write": true,    
           
         "objects": {
           "animal":  {

             ".indexOn": "fileName"
           						   	}		
         					 	  }
         						
        		}
}

<Firebase Storage & URLSession - Download >
https://mrgott.com/swift-programing/32-firebase-storage-how-to-download-files-using-firebase-3-sdk-with-swift-3-in-xcode-8

<Save data Permanantly>
https://medium.com/aviabird/the-one-with-userdefaults-aab2c2a7e170
  
<Save file >
https://medium.com/@ankitbansal806/save-and-get-image-from-document-directory-in-swift-5c1280ec17f5
  
 <Firebase Query>
  https://stackoverflow.com/questions/40656589/firebase-query-if-child-of-child-contains-a-value
