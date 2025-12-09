# tty driver
---

tty (Teletypewriter) is a driver class made for basic text output (ASCII only) used for primitive ui.

```
API Signature

    print(String: text):Nil
        Prints text to the screen with a following \n
    
    printInline(String: text):Nil
        Prints text to the screen without following \n

    clear():Nil
        Clears screen sets x,y of cursor to 0,0

    setBackgroundColor(Number: index):Nil
        Sets background color to index of pallete
    
    getBackgroundColor():Number
        Returns current background index of screen
    
    setForegroundColor(Number: index):Nil
        Sets foreground color to index of pallete

    getForegroundColor():Number
        Returns current foreground index of screen

    setCursorPos(Number: x, Number: y):Nil
        Sets x,y position of cursor
    
    getCursorPos():Number, Number
        Gets x,y position of cursor
```