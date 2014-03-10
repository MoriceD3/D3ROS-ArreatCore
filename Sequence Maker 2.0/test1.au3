global $test=10

#Include <WinAPI.au3>

   
     HotKeySet("a", "plus")
   func plus()
	  $test=$test+10
	  msgbox(4096,"test",$test)
	
	  endfunc
	  while 1
   
   WEnd