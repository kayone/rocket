paramCount 	= %0%
userInput 	= %1%
pName 		= %2%
winId 		= %3%

if(userInput == "")
{
	run TASKKILL /F /IM %pname% /T,,Hide
}
else
{
	run TASKKILL /F /FI "imagename eq %userInput%" /T ,,Hide
}