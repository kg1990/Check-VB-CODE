'autoWebPV_ADD.vbs
for i = 0 to 30
	Dim IE  
	Set IE = CreateObject("InternetExplorer.Application")  
	ie.navigate("http://www.github.com")  
	ie.visible=false
	ie.quit
	Set IE = Nothing  
next
MsgBox "Program Run Complete!"
