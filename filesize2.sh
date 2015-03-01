#!/bin/sh
#taille du chunk
chunksize=19288
#converison base64

fileglobal=( `cat "entretienconseil.ipa" `)
fileSize=${#fileglobal[@]}
#decoupage
split -b $chunksize entretienconseil.ipa data.tsv
index=1

for csv in $(ls data.tsv*); do
	filepartcontent=( `cat "${csv}" `)
    openssl base64 -in ${csv} -out base64${csv}
	#tentative de virer les sauts de ligne : pas bonne approche
    #filecontent=( `cat "test.txt"  | xargs | sed "s/ ---- /\n---- /g"`)
    fileSizePart=$(du -k ${csv} | sed 's/\([0-9]*\)\(.*\)/\1/')
    echo $(($fileSizePart*1024))
	if [ $index = 1 ]; then
		echo "<InternalAppChunk xmlns='http://www.air-watch.com/servicemodel/resources'><ChunkData>${filepartcontent[@]}</ChunkData><TransactionId></TransactionId><ChunkSequenceNumber>$index</ChunkSequenceNumber><TotalApplicationSize>1928856</TotalApplicationSize><ChunkSize>19288</ChunkSize><IsAssembled>0</IsAssembled></InternalAppChunk>" | sed 's/ //g')> la$index
		#requete CURL
		response=$(curl -k -H "Content-type: application/xml" -H "Authorization: Basic YWRtaXRlbXVuYjpKYW52aWVyMjAxNSo=" -H "aw-tenant-code: 1ONPA4AAAAG6A53QADQA" -X POST "http://a-ibmobe00.srv-ib.ibp/API/v1/mam/apps/internal/uploadchunk" --data-binary @la$index)
        echo $response >> tmp.xml
        transcationId=$(sed -e 's/^.*<TranscationId>//' -e 's!</TranscationId>.*!!' tmp.xml)
        echo $transcationId
        echo $response
        #rm tmp.xml	
	else 
        echo "<InternalAppChunk xmlns='http://www.air-watch.com/servicemodel/resources'><TransactionId>$transcationId</TransactionId><ChunkData>${filepartcontent[@]}</ChunkData><ChunkSequenceNumber>$index</ChunkSequenceNumber><TotalApplicationSize>1928856</TotalApplicationSize><ChunkSize>19288</ChunkSize><IsAssembled>0</IsAssembled></InternalAppChunk>" | sed 's/ //g'> la$index
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