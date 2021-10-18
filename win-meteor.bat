SET dir1=%~dp0
del /Q %dir1%ICTRiskTool.json

curl http://www.meteorkitchen.com/api/getapp/json/8R7NFyfzjb7Xt4EBL  -o %dir1%ICTRiskTool.json

rmdir ICTRiskTool /S /Q
mkdir emptyfolder
robocopy emptyfolder ICTRiskTool /purge
rmdir emptyfolder
rmdir ICTRiskTool

meteor-kitchen ./ICTRiskTool.json ./ICTRiskTool

cd ./ICTRiskTool
meteor --port 3000
