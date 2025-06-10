This is a template engine that you can use to create websites with
To run it install nim on your machine and run <br>sudo r compiler.nim in the same folder as your index.sel file

it is divided into sections. <br> currently there are only 2, HTML and CSS (I plan to add JS later)

Here are the commands and what they output when interpreted

HTML commands:

All commmands are seperated with a semicolon ; and inputs within commands are prefaced with a colon : <br>
indentation or spaces do not matter as blank space to the left or right of the command is removed before proccessing

class: ClassName; -- >
Doesn't do anything on its own but adds a class to something infront of it e.g class: container; div: content; becomes `<div class ="container"></div>`

external links ----------------------------------------
link.css: name.css; --> `<link href="name.css" rel="stylesheet" type="text/css">` <br>
link.icon: icon.png; --> `<link href="icon.png" rel="icon">` <br>
link.script script.js --> `<script src="script.js" defer></script>` <br>


Everything Below can be altered by adding the class: NameOfClass; command before.<br>
you can also nest commands. e.g a button within a list <br>
you can also nest classes. the class command only applies to what is right of it. <br>

e.g class: ListClass; -; class: ButtonClass; btn: content; becomes <br>
`<li class="ListClass"><button class="ButtonClass">Content</button></li>` <br>

There is a max of 100 commands per line.

Self-Closing Commands --------------------------- <br>

-; --> `<li></li>` <br>
Btn; --> `<button></button>` <br>
Source: index.html; --> `<a href="link.html"></a>` <br>
title: My Website; --> `<title> My Website </title>` <br>
div: content; --> `<div>content</div>` <br>
p: content; --> `<p>content</p>` <br>
h1: content; -+> `<h1>content</h1>` (works on h1-6) <br>
img: img.png --> `<img src="img.png">` <br>

Doesn't add anything ------------- <br>
text: content; `content` <br>

Opening commands ----------------------------- <br>
hrd; --> `<header>` <br>
hd; --> `<head>` <br>
bd; --> `<body>` <br>
nav; --> `<nav>` <br>
/div; --> `<div>` <br>

closing commands -------------------------------- <br>
!hrd --> `</header>` <br>
!hd --> `</head>` <br>
!bd --> `</body>` <br>
!nav --> `</nav>` <br>
!div --> `/div` <br>

exit html; --> exits htmt mode and intitiates css mode <br>

Css Mode

There is only one command in Css mode which is:

load preset --> This loads a large amount of premade css styles which get automatically added to the index.css file

when in css mode you can write css directly in the .sel file and it will be directly added to your index.css file unchanged

when using the class command you can reference more than one class and they will all apply to the element
simply seperate the classes with a space 
e.g class: Class-1 Class-2 Class-3;

