import os, strutils, sequtils
echo " \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n what is the name of your .sel file (Do NOT include the .sel)"
let UserSelectedName = readline(stdin)
echo "your css, js and html files will have the same name"

let inputFile = UserSelectedName & ".sel"
let outputFile = UserSelectedName & ".html"
let outputFileCss = UserSelectedName & ".css"
let outputFileJs = UserSelectedName & ".js"
var htmlMode = true
var cssModeStarted = false 
var JavaScriptMode = false

proc CssParser(line: string): string =
    var result = ""

    if line != "load preset":
        # Add the current line exactly as it was
        result &= line & "\n"
        return result

    if line == "exit css":
        # come out of css mode
        cssModeStarted = false;
        htmlMode = true 
        JavaScriptMode = false
        return 

    if line == "load preset":
        echo "preset loaded"
        result &= line & """
/* === PRESET CSS CLASSES === */

/* Text sizes */
.text-xs       { font-size: 0.5rem; }
.text-small    { font-size: 0.8rem; }
.text-normal   { font-size: 1rem; }
.text-large    { font-size: 1.5rem; }
.text-xl       { font-size: 2rem; }

/* Text styles */
.text-bold     { font-weight: bold; }
.text-italic   { font-style: italic; }
.text-center   { text-align: center; }
.text-left     { text-align: left; }
.text-right    { text-align: right; }

/* Colors */
.text-black  { color: #\n000000; }
.text-grey{ color: #777777; }
.text-blue   { color: #007BFF; }
.text-red   { color: #FF4136; }
.text-green  { color: #2ECC40; }
.text-white  { color: #FFFFFF; }
.text-purple {color: #10002B;}

/* Backgrounds */
.bg-white    { background-color: #FFFFFF; }
.bg-grey       { background-color: darkgrey; }
.bg-blue    { background-color: #007BFF; }
.bg-green    { background-color: #2ECC40; }
.bg-red     { background-color: #FF4136; }
.bg-black { background-color: black;}

/* Borders */
.border        { border: 1px solid #ccc; padding: 0.5rem; }
.border-round  { border-radius: 0.5rem; border: 1px solid #ccc; padding: 0.5rem; }
.no-border     { border: none; }

/* Padding & Margin */
.p-1           { padding: 0.5rem; }
.p-2           { padding: 1rem; }
.p-3           { padding: 1.5rem; }

.m-1           { margin: 0.5rem; }
.m-2           { margin: 1rem; }
.m-3           { margin: 1.5rem; }

/* Display */
.inline        { display: inline; }
.block         { display: block; }
.flex          { display: flex; }
.flex-center   { display: flex; justify-content: center; align-items: center; }
.hidden        { display: none; }

/* Widths */
.w-100         { width: 100%; }
.w-90          { width: 90%; }
.w-80         { width: 80%; }
.w-70          { width: 70%; }
.w-60         { width: 60%; }
.w-50          { width: 50%; }
.w-40         { width: 40%; }
.w-30          { width: 30%; }
.w-20         { width: 20%; }
.w-10          { width: 10%; }
.w-auto        { width: auto; }

/* Heights */
.h-100         { height: 100%; }
.h-90          { height: 90%; }
.h-80         { height: 80%; }
.h-70          { height: 70%; }
.h-60         { height: 60%; }
.h-50          { height: 50%; }
.h-40         { height: 40%; }
.h-30          { height: 30%; }
.h-20         { height: 20%; }
.h-10          { height: 10%; }
.h-auto        { height: auto; }

/* Buttons */
.btn           { display: inline-block; padding: 0.5rem 1rem; font-size: 1rem; border: none; border-radius: 0.3rem; cursor: pointer; text-align: center; }
.btn-primary   { background-color: #007BFF; color: white; }
.btn-success   { background-color: #2ECC40; color: white; }
.btn-danger    { background-color: #FF4136; color: white; }
.btn-outline   { background-color: transparent; border: 2px solid #007BFF; color: #007BFF; }

/* Images */
.img-responsive { max-width: 100%; height: auto; }

/* centering */
.center-h {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}
.center-v {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}
.center-vh {
  left: 50%;
  top: 50%;
  position: absolute;
  transform: translate(-50%, -50%);
}
.text-top {
  display: flex;
  align-items: flex-start;
}

.text-center-v {
  display: flex;
  align-items: center;
}

.text-bottom {
  display: flex;
  align-items: flex-end;
}

.text-center-vh {
  display: flex;
  justify-content: center; /* horizontal centering */
  align-items: center;     /* vertical centering */
}

/* if you want the whole thing to be completely top bottom or side */

.top { top: 0%; }

.bottom { bottom: 0%; }

.left { left: 0%;}

.right { right: 0%; }


/* === END PRESET === */
"""
        return result





proc parseLine(line: string): string =
    let commands = line.split(';').mapIt(it.strip())
    var results = newSeq[string](100)   # Force 100 slots to be safe
    var clid = ""
    var clidpos = 0
    var class = ""
    var id = ""
    var ClidPos = 0
    var CssClass = ""
    var IDClass = ""

    for i in 0 ..< results.len:
        results[i] = ""  # Initialize all to empty string

    for index, cmd in commands:
        if cmd.len == 0:
            continue

        # exitiing html mode

        elif cmd.startsWith("start css"):
            htmlMode = false
            cssModeStarted = true
            JavaScriptMode = false
            return

        elif cmd.startsWith("start JS"):
            JavaScriptMode = true
            htmlMode = false
            cssModeStarted = false
            return

        #class and id linker

        elif cmd.startsWith("clid:"):
            clid = cmd[5..^1].strip()
            let split = clid.split(':').mapIt(it.strip())
            ClidPos = index
            if split.len == 2:
                CssClass = split[0]
                IDClass = split[1]
            else:
                echo "2 parts not found within the clid command"

        #closing tags

        elif cmd.startsWith("!hd"):
            results[index] &= "</head>"

        elif cmd.startsWith("!ta"):
            results[index] &= "</textarea>"

        elif cmd.startsWith("!label"):
            results[index] &= "</label>"
        
        elif cmd.startsWith("!opt"):
            results[index] &= "</option>"

        elif cmd.startsWith("!sel"):
            results[index] &= "</select>"

        elif cmd.startsWith("!in"):
            results[index] &= "</input>"

        elif cmd.startsWith("!art"):
            results[index] &= "</article>"

        elif cmd.startsWith("!form"):
            results[index] &= "</form>"

        elif cmd.startsWith("!aside"):
            results[index] &= "</aside>"

        elif cmd.startsWith("!figure"):
            results[index] &= "</figure>"

        elif cmd.startsWith("!figcap"):
            results[index] &= "</figcaption>"

        elif cmd.startsWith("!sec"):
            results[index] &= "</section>"

        elif cmd.startsWith("!bd"):
            results[index] &= "</body>"

        elif cmd.startsWith("!hrd"):
            results[index] &= "</header>"

        elif cmd.startsWith("!frd"):
            results[index] &= "</footer>"

        elif cmd.startsWith("!nav"):
            results[index] &= "</nav>"

        elif cmd.startsWith("!div"):
            results[index] &= "</div>"

        elif cmd.startsWith("!ul"):
            results[index] &= "</ul>"

        elif cmd.startsWith("!ol"):
            results[index] &= "</ol>"

        # linking at the top of the document

        elif cmd.startsWith("link.css:"):
            let linkcssText = cmd[9..^1].strip()
            results[index] &= "<link href=\"" & linkcssText & "\" rel=\"stylesheet\" type=\"text/css\">"

        elif cmd.startsWith("link.icon:"):
            let linkiconText = cmd[10..^1].strip()
            results[index] &= "<link href=\"" & linkiconText & "\" rel=\"icon\">"

        elif cmd.startsWith("link.script:"):
            let linkJSText = cmd[12..^1].strip()
            results[index] &= "<script src=\"" & linkJSText & "\" defer></script>"
        
        # Normal command processing

        elif cmd.startsWith("/div:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[5..^1].strip()
            results[index] &= "<div class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/label:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[7..^1].strip()
            results[index] &= "<label class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/opt:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[5..^1].strip()
            results[index] &= "<option class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/sel:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[5..^1].strip()
            results[index] &= "<select class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/ta:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<textarea class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/in:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<input class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/form:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            results[index] &= "<form class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/aside:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            results[index] &= "<aside class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/figcap:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[8..^1].strip()
            results[index] &= "<figcaption class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/figure:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[8..^1].strip()
            results[index] &= "<figure class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/section:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[9..^1].strip()
            results[index] &= "<section class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("/article:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[9..^1].strip()
            results[index] &= "<article class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("nl:"):
            let content = cmd[3..^1].strip()
            results[index] &= "<br>" & content

        elif cmd.startsWith("hr:"):
            let content = cmd[3..^1].strip()
            results[index] &= "<hr>" & content

        elif cmd.startsWith("meta:"):
            let content = cmd[5..^1].strip()
            results[index] &= "<meta" & content & ">"

        elif cmd.startsWith("ul:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[3..^1].strip()
            results[index] &= "<ul class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content

        elif cmd.startsWith("ol:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[3..^1].strip()
            results[index] &= "<ol class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content    

        elif cmd.startsWith("nav"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<nav class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("bd"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<body class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("hd"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<head class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("hrd"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<header class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("frd"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<footer class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("text:"):
            let textText = cmd[5..^1].strip()
            results[index] &= textText


        elif cmd.startsWith("img:"):
            let imgSrc = cmd[4..^1].strip()
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<img src=\"" & imgSrc & "\" class=\"" & CssClass & "\" id =\"" & IDClass & "\">"

        elif cmd.startsWith("+"):
            results[index] &= cmd[1..^1]
        
        # now onto the freaky ones (they need closing tags)

        # firstly just the h1-6

        elif cmd.startsWith("h1:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h1 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h1>"

        elif cmd.startsWith("h2:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h2 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h2>"

        elif cmd.startsWith("h3:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h3 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h3>"

        elif cmd.startsWith("h4:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h4 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h4>"

        elif cmd.startsWith("h5:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h5 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h5>"

        elif cmd.startsWith("h6:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<h6 class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h6>"

        #now the rest

        elif cmd.startsWith("p:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[2..^1].strip()
            results[index] &= "<p class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</p>"

        elif cmd.startsWith("label:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            results[index] &= "<label class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</label>"

        elif cmd.startsWith("opt:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<option class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</option>"

        elif cmd.startsWith("sel:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<select class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</select>"

        elif cmd.startsWith("ta:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[2..^1].strip()
            results[index] &= "<textarea class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</textarea>"

        elif cmd.startsWith("in:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[3..^1].strip()
            results[index] &= "<input class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</input>"

        elif cmd.startsWith("form:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[5..^1].strip()
            results[index] &= "<form class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</form>"

        elif cmd.startsWith("section:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[8..^1].strip()
            results[index] &= "<section class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</section>"#

        elif cmd.startsWith("figcap:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[7..^1].strip()
            results[index] &= "<figcaption class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</figcaption>"

        elif cmd.startsWith("figure:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[7..^1].strip()
            results[index] &= "<figure class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</figure>"

        elif cmd.startsWith("aside:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[8..^1].strip()
            results[index] &= "<aside class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</aside>"

        elif cmd.startsWith("article:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[8..^1].strip()
            results[index] &= "<article class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</article>"

        elif cmd.startsWith("div:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            results[index] &= "<div class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</div>"

        elif cmd.startsWith("title:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            results[index] &= "<title class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</title>"

        elif cmd.startsWith("source:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let source = cmd[7..^1].strip()
            results[index] &= "<a href=\"" & source & "\"  class=\"" & CssClass & "\" id =\"" & IDClass & "\">"
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</a>"

        elif cmd.startsWith("btn:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1]
            results[index] &= "<button  class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let ButtonEndPos = results.len - index - 1 # Use correct formula
            echo "ButtonEndPos = ", ButtonEndPos
            results[ButtonEndPos] &= "</button>"

        elif cmd.startsWith("-:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[2..^1]
            results[index] &= "<li  class=\"" & CssClass & "\" id =\"" & IDClass & "\">" & content
            let ButtonEndPos = results.len - index - 1 # Use correct formula
            echo "ButtonEndPos = ", ButtonEndPos
            results[ButtonEndPos] &= "</li>"

        # debug
        echo "Command #" & $(index+1) & ": " & cmd


    # Join all results in order (but only for real slots)
    return results.join("")

proc main() =
    if not fileExists(inputFile):
        echo "Input file not found: ", inputFile
        return

    var outputLines = newSeq[string]()
    var outputLinesCss = newSeq[string]()

    for line in lines(inputFile):
        if htmlMode:
            let htmlLine = parseLine(line)
            outputLines.add(htmlLine)
            
        elif cssModeStarted:
            let cssLine = CssParser(line)
            outputLinesCss.add(cssLine)
        
         #elif JavaScriptMode:
          #  let JavaScriptLine = JSParser(line)
           # outputLinesJs.add(JavaScriptLine)

    # Insert default CSS link at top (or we can do it smarter later)
    let CssJsLink = "<head> <link href=\"" & outputFileCss & "\" rel=\"stylesheet\" type=\"text/css\"><script src=\"" & outputFileJs & "\" defer></script></head>"
    outputLines.insert(CssJsLink, 0)

    # Join all lines with newlines and write to output file
    writeFile(outputFile, join(outputLines, "\n"))
    echo "Written output to ", outputFile

    writeFile(outputFileCss, join(outputLinesCss, "\n"))
    echo "Written output to ", outputFileCss




if htmlMode:
    main()