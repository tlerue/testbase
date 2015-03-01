xcurl -k \
-H "Content-type: application/xml" \
-H "Authorization: Basic YWRtaXRlbXVuYjpKYW52aWVyMjAxNSo=" \
-H "aw-tenant-code: 1ONPA4AAAAG6A53QADQA" \
-X POST http://a-ibmobe00.srv-ib.ibp/API/v1/mam/apps/internal/begininstall \
-d '<InternalAppChunkTranscation xmlns="http://www.air-watch.com/servicemodel/resources"><TransactionId>06d640a8-2138-444c-a11c-9d80ab1812ca</TransactionId><DeviceType>2</DeviceType><ApplicationName>entretienconseil</ApplicationName><PushMode>Auto</PushMode></InternalAppChunkTranscation>'