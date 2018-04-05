import pyodbc, json
## working now
print ("Connection attempt")

try:
	conn = pyodbc.connect(
	    r'DRIVER={SQL Server Native Client 11.0};'
	    r'SERVER=cxcldsrcnxqas01.database.windows.net;'
	    r'DATABASE=cxclddbcnxmaqas;'
	    r'UID=jsvehlak;'
	    r'PWD=Passw0rd426'
    )
	print('OK')

except Exception as e:

	print ("ERR:" + str(e))

print('Querying DB for schema')

try:
	cursor = conn.cursor()
	query = "select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'BlobDocumentTbl' for json path"
	json_response = cursor.execute(query)

	rows = cursor.fetchall()
	for row in rows:
		print(list(row))
		data = []
		data.append(list(row))


except Exception as e:
	print ('ERR: ' + str(e))
