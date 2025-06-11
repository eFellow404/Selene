This is a template engine that you can use to create websites with
To run it install nim on your machina and run sudo r compiler.nim in the same folder as your index.sel file

it is divided into sections. currently there are only 2, HTML and CSS (I plan to add JS later)

Here are the commands and what they output when interpreted

HTML commands:

All commmands are seperated with a semicolon ; and inputs within commands are prefaced with a colon :
indentation or spaces do not matter as blank space to the left or right of the command is removed before proccessing

class: ClassName; -- >                                                                                                      
Doesn't do anything on its own but adds a class to something infront of it e.g class: container; div: content; becomes `<div class ="container"></div>`

external links ----------------------------------------                                                                             
link.css: name.css; --> `<link href="name.css" rel="stylesheet" type="text/css">`                                               
link.icon: icon.png; --> `<link href="icon.png" rel="icon">`                                                                        
link.script script.js --> `<script src="script.js" defer></script>`                                                         


Everything Below can be altered by adding the class: NameOfClass; command before.
you can also nest commands. e.g a button within a list
you can also nest classes. the class command only applies to what is right of it.

e.g class: ListClass; -; class: ButtonClass; btn: content; becomes
`<li class="ListClass"><button class="ButtonClass">Content</button></li>`

There is a max of 100 commands per line.

Self-Closing Commands ---------------------------

-; --> `<li></li>`
Btn; --> `<button></button>`
Source: index.html; `<a href="link.html"></a>`
title: My Website; `<title> My Website </title>`
div: content; `<div>content</div>`
p: content; `<p>content</p>`
h1: content; `<h1>content</h1>` (works on h1-6)
img: img.png `<img src="img.png">`

Doesn't add anything -------------
text: content; `content`

Opening commands -----------------------------
hrd; --> `<header>`
hd; --> `<head>`
bd; --> `<body>`
nav; --> `<nav>`
/div; --> `<div>` 

closing commands --------------------------------
!hrd --> `</header>`
!hd --> `</head>`
!bd --> `</body>`
!nav --> `</nav>`
!div --> `/div`

exit html; --> exits htmt mode and intitiates css mode

Css Mode

There is only one command in Css mode which is:

load preset --> This loads a large amount of premade css styles which get automatically added to the index.css file

when in css mode you can write css directly in the .sel file and it will be directly added to your index.css file unchanged

when using the class command you can reference more than one class and they will all apply to the element
simply seperate the classes with a space 
e.g class: Class-1 Class-2 Class-3;

