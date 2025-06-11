import os, strutils, sequtils

let inputFile = "index.sel"
let outputFile = "index.html"
let outputFileCss = "index.css"
var htmlMode = true
var cssModeStarted = false 

proc CssParser(line: string): string =
    var result = ""

    # If this is the first CSS line, mark that CSS mode has started
    if not cssModeStarted:
        cssModeStarted = true

    if line != "load preset":
        # Add the current line exactly as it was
        result &= line & "\n"
        return result

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
.text-black  { color: #000000; }
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

/* === END PRESET === */
"""
        return result





proc parseLine(line: string): string =
    let commands = line.split(';').mapIt(it.strip())
    var results = newSeq[string](100)   # Force 100 slots to be safe
    var ClassPos = 0
    var CssClass = ""

    for i in 0 ..< results.len:
        results[i] = ""  # Initialize all to empty string

    for index, cmd in commands:
        if cmd.len == 0:
            continue

        # exitiing html mode

        elif cmd.startsWith("exit html"):
            htmlMode = false
            return

        #class linker

        elif cmd.startsWith("class:"):
            CssClass = cmd[6..^1].strip()
            ClassPos = index
            usedCssClasses.incl(CssClass)
            echo "Detected CSS class: ", CssClass


        #closing tags

        elif cmd.startsWith("!hd"):
            results[index] &= "</head>"

        elif cmd.startsWith("!bd"):
            results[index] &= "</body>"

        elif cmd.startsWith("!hrd"):
            results[index] &= "</header>"

        elif cmd.startsWith("!nav"):
            results[index] &= "</nav>"

        elif cmd.startsWith("!div"):
            results[index] &= "</div>"

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

        elif cmd.startsWith("/div"):
            if ClassPos != index - 1:
                CssClass = ""

            results[index] &= "<div class=\"" & CssClass & "\">"

        elif cmd.startsWith("nav"):
            if ClassPos != index - 1:
                CssClass = ""

            results[index] &= "<nav class=\"" & CssClass & "\">"

        elif cmd.startsWith("bd"):
            if ClassPos != index - 1:
                CssClass = ""

            results[index] &= "<body class=\"" & CssClass & "\">"

        elif cmd.startsWith("hd"):
            if ClassPos != index - 1:
                CssClass = ""

            results[index] &= "<head class=\"" & CssClass & "\">"

        elif cmd.startsWith("hrd"):
            if ClassPos != index - 1:
                CssClass = ""

            results[index] &= "<header class=\"" & CssClass & "\">"

        elif cmd.startsWith("text:"):
            let textText = cmd[5..^1].strip()
            results[index] &= textText


        elif cmd.startsWith("img:"):
            let imgSrc = cmd[4..^1].strip()
            if ClassPos != index - 1:
                CssClass = ""
            results[index] &= "<img src=\"" & imgSrc & "\" class=\"" & CssClass & "\">"

        elif cmd.startsWith("+"):
            results[index] &= cmd[1..^1]
        
        # now onto the freaky ones (they need closing tags)

        # firstly just the h1-6

        elif cmd.startsWith("h1:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h1 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h1>"

        elif cmd.startsWith("h2:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h2 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h2>"

        elif cmd.startsWith("h3:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h3 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h3>"

        elif cmd.startsWith("h4:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h4 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h4>"

        elif cmd.startsWith("h5:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h5 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h5>"

        elif cmd.startsWith("h6:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<h6 class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</h6>"

        #now the rest

        elif cmd.startsWith("p:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[2..^1].strip()
            results[index] &= "<p class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</p>"

        elif cmd.startsWith("div:"):
            if ClassPos != index - 1:
                CssClass = ""
            let content = cmd[4..^1].strip()
            results[index] &= "<div class =\"" & CssClass & "\">" & content
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</div>"

        elif cmd.startsWith("title:"):
            if ClassPos != index - 1:
                CssClass = ""
            let title = cmd[6..^1].strip()
            results[index] &= "<title class=\"" & CssClass & "\">" & title
            let titleEndPos = results.len - index - 1 # Use correct formula
            echo "titleEndPos = ", titleEndPos
            results[titleEndPos] &= "</title>"

        elif cmd.startsWith("source:"):
            if ClassPos != index - 1:
                CssClass = ""
            let source = cmd[7..^1].strip()
            results[index] &= "<a href=\"" & source & "\" class =\"" & CssClass & "\">"
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</a>"

        elif cmd.startsWith("btn"):
            if ClassPos != index - 1:
                CssClass = ""
            results[index] &= "<button class=\"" & CssClass & "\">"
            let ButtonEndPos = results.len - index - 1 # Use correct formula
            echo "ButtonEndPos = ", ButtonEndPos
            results[ButtonEndPos] &= "</button>"

        elif cmd.startsWith("-"):
            if ClassPos != index - 1:
                CssClass = ""
            results[index] &= "<li class=\"" & CssClass & "\">"
            let LinkEndPos = results.len - index - 1 # Use correct formula
            echo "LinkEndPos = ", LinkEndPos
            results[LinkEndPos] &= "</li>"

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
            
        else:
            let cssLine = CssParser(line)
            outputLinesCss.add(cssLine)

    # Insert default CSS link at top (or we can do it smarter later)
    let cssLinkTag = "<link href=\"index.css\" rel=\"stylesheet\" type=\"text/css\">"
    outputLines.insert(cssLinkTag, 0)

    # Join all lines with newlines and write to output file
    writeFile(outputFile, join(outputLines, "\n"))
    echo "Written output to ", outputFile

    writeFile(outputFileCss, join(outputLinesCss, "\n"))
    echo "Written output to ", outputFileCss




if htmlMode:
    main()