#!/bin/sh
#taille du chunk
chunksize=19288
#converison base64

fileSize=$(stat "entretienconseil.ipa"  | sed 's/\([0-9]*\) \([0-9]*\) -\([a-z\–]*\) \([0-9]*\) \([a-z]*\) \([a-z]*\) \([0-9]*\) \([0-9]*\) \(.*\)/\8/') 
echo $fileSize

#decoupage
split -b $chunksize entretienconseil.ipa data.tsv
index=1

for csv in $(ls data.tsv*); do	
    openssl base64 -in ${csv} -out base64${csv}
    filepartcontent=( `cat "base64${csv}" `)
    fileSizePart=$(stat "${csv}"  | sed 's/\([0-9]*\) \([0-9]*\) -\([a-z\-]*\) \([0-9]*\) \([a-z]*\) \([a-z]*\) \([0-9]*\) \([0-9]*\) \(.*\)/\8/') 
    echo $fileSizePart
	if [ $index = 1 ]; then
		echo "<InternalAppChunk xmlns='http://www.air-watch.com/servicemodel/resources'><ChunkData>${filepartcontent[@]}</ChunkData><TransactionId></TransactionId><ChunkSequenceNumber>$index</ChunkSequenceNumber><TotalApplicationSize>$fileSizePart</TotalApplicationSize><ChunkSize>$fileSize</ChunkSize><IsAssembled>0</IsAssembled></InternalAppChunk>" | sed 's/ //g'> la$index
		#requete CURL
		response=$(curl -k -H "Content-type: application/xml" -H "Authorization: Basic YWRtaXRlbXVuYjpKYW52aWVyMjAxNSo=" -H "aw-tenant-code: 1ONPA4AAAAG6A53QADQA" -X POST "http://a-ibmobe00.srv-ib.ibp/API/v1/mam/apps/internal/uploadchunk" --data-binary @la$index)
        echo $response >> tmp.xml
        transcationId=$(sed -e 's/^.*<TranscationId>//' -e 's!</TranscationId>.*!!' tmp.xml)
        echo $transcationId
        echo $response
        #rm tmp.xml	
	else 
        echo "<InternalAppChunk xmlns='http://www.air-watch.com/servicemodel/resources'><TransactionId>$transcationId</TransactionId><ChunkData>${filepartcontent[@]}</ChunkData><ChunkSequenceNumber>$index</ChunkSequenceNumber><TotalApplicationSize>$fileSizePart</TotalApplicationSize><ChunkSize>$fileSize</ChunkSize><IsAssembled>0</IsAssembled></InternalAppChunk>" | sed 's/ //g'> la$index
        #requete CURL
        response=$(curl -k -H "Content-type: application/xml" -H "Authorization: Basic YWRtaXRlbXVuYjpKYW52aWVyMjAxNSo=" -H "aw-tenant-code: 1ONPA4AAAAG6A53QADQA" -X POST "http://a-ibmobe00.srv-ib.ibp/API/v1/mam/apps/internal/uploadchunk" --data-binary @la$index)	
        echo $response	
    fi
	index=$((index+1))
    echo $csv
    
done
#nettoyage
#rm data.tsv*
#rm la*