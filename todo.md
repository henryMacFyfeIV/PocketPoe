# Todo

* ~~Add scrolling~~

* Break shelf and book views out into files

* Add a few more stories to fill up shelf

* Add scrolling save progress

* Add crank input for scrolling, selecting books

* Add annotations

* Add book of user annotations

* Find/Create a gothic font

* title card : PocketPoe in gothic font, pixelated Edgar Allen Poe portrait

* hyper read mode

## Bugs:

* ~~takes a while to startup, I'm guessing the issue is parsing all the words out of stories at once maybe I can format the files like they are after the gmatch(), and just store those instead of the current txt file~~

* right now you can scroll past the end of a book, causing the program to crash
main.lua:67: attempt to concatenate a nil value (field '?')
stack traceback:
	main.lua:67: in function 'drawPage'
	main.lua:128: in function <main.lua:105>
main.lua:67: attempt to concatenate a nil value (field '?')
stack traceback:
	main.lua:67: in function 'drawPage'
	main.lua:128: in function <main.lua:105>


* I've lost some text at the end of stories
