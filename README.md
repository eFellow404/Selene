This is a template engine that you can use to create websites with <br>
To run it install nim on your machina and run sudo r compiler.nim in the same folder as your index.sel file<br>
<br>
it is divided into sections. currently there are only 2, HTML and CSS (I plan to add JS later)<br>
<br>
Here are the commands and what they output when interpreted<br>

HTML commands:<br>

All commmands are seperated with a semicolon ; and inputs within commands are prefaced with a colon :<br>
indentation or spaces do not matter as blank space to the left or right of the command is removed before proccessing<br>
<br>
class: ClassName; -- >                  <br>                                                                                    
Doesn't do anything on its own but adds a class to something infront of it e.g class: container; div: content; becomes `<div class ="container"></div>`<br>

external links ---------------------------------------- <br>                                                                            
link.css: name.css; --> `<link href="name.css" rel="stylesheet" type="text/css">`   <br>                                            
link.icon: icon.png; --> `<link href="icon.png" rel="icon">`           <br>                                                             
link.script script.js --> `<script src="script.js" defer></script>`            <br>                                             


Everything Below can be altered by adding the class: NameOfClass; command before.<br>
you can also nest commands. e.g a button within a list<br>
you can also nest classes. the class command only applies to what is right of it.<br>
<br>
e.g class: ListClass; -; class: ButtonClass; btn: content; becomes<br>
`<li class="ListClass"><button class="ButtonClass">Content</button></li>`<br>
<br>
There is a max of 100 commands per line.<br>
<br>
Self-Closing Commands ---------------------------<br>
<br>
-; --> `<li></li>`<br>
Btn; --> `<button></button>`<br>
Source: index.html; `<a href="link.html"></a>`<br>
title: My Website; `<title> My Website </title>`<br>
div: content; `<div>content</div>`<br>
p: content; `<p>content</p>`<br>
h1: content; `<h1>content</h1>` (works on h1-6)<br>
img: img.png `<img src="img.png">`<br>
<br>
Doesn't add anything -------------<br>
text: content; `content`<br>
<br>
Opening commands -----------------------------<br>
hrd; --> `<header>`<br>
hd; --> `<head>`<br>
bd; --> `<body>`<br>
nav; --> `<nav>`<br>
/div; --> `<div>` <br>
<br>
closing commands --------------------------------<br>
!hrd --> `</header>`<br>
!hd --> `</head>`<br>
!bd --> `</body>`<br>
!nav --> `</nav>`<br>
!div --> `/div`<br>
<br>
exit html; --> exits htmt mode and intitiates css mode<br>
<br>
Css Mode<br>
<br>
There is only one command in Css mode which is:<br>
<br>
load preset --> This loads a large amount of premade css styles which get automatically added to the index.css file<br>
<br>
when in css mode you can write css directly in the .sel file and it will be directly added to your index.css file unchanged<br>
<br>
when using the class command you can reference more than one class and they will all apply to the element<br>
simply seperate the classes with a space <br>
e.g class: Class-1 Class-2 Class-3;<br>

