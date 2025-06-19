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

    if line == "exit css;":
        # come out of css mode
        cssModeStarted = false;
        htmlMode = true 
        JavaScriptMode = false
        

    elif line == "load preset":
        echo "preset loaded"
        result &= """
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

    elif line != "exit css":
        if line != "load preset":
            # Add the current line exactly as it was
            result &= line & "\n"
            return result

proc ClosingTags(tag: string): string =
    result = "</" & tag & ">"

proc processTag(tag: string, CLIDpos: int, Class: string, ID: string, prefixLen: int, cmd: string, index: int, results: var seq[string], Closes: bool) =
    var classVal = Class
    var idVal = ID
    
    if CLIDpos != index - 1:
        classVal = ""
        idVal = ""
    
    let content = cmd[prefixLen..^1].strip()
    var parts: seq[string] = @[]
    var current = ""
    var escapeNext = false
    
    # Parse content with escape handling
    for c in content:
        if escapeNext:
            current.add(c)
            escapeNext = false
        elif c == '$':
            escapeNext = true
        elif c == ':':
            parts.add(current.strip())
            current = ""
        else:
            current.add(c)
    
    if current.len > 0:
        parts.add(current.strip())
    
    # Extract attributes and content
    var attributes: seq[(string, string)] = @[]
    var tagContent = ""
    
    for i, part in parts:
        if part.contains('='):
            let kv = part.split('=', 1)
            let k = kv[0].strip()
            let v = if kv.len > 1: kv[1].strip() else: ""
            attributes.add((k, v))
        elif i == parts.high:
            tagContent = part
        else:
            # Treat as flag attribute (e.g., "required")
            attributes.add((part, part))
    
    # Build opening tag
    var tagStr = "<" & tag
    
    if classVal.len > 0:
        tagStr &= " class=\"" & classVal & "\""
    if idVal.len > 0:
        tagStr &= " id=\"" & idVal & "\""
    
    for (k, v) in attributes:
        if k == v:  # Flag attribute
            tagStr &= " " & k
        else:
            tagStr &= " " & k & "=\"" & v & "\""
    
    tagStr &= ">"
    
    # Set results
    let endPos = results.len - index - 1
    results[index] = tagStr & tagContent
    if Closes:
        results[endPos] = "</" & tag & ">"

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

        # reloud the page for quick developing

        elif cmd.startsWith("load devtools"):
            results[index] &= """ 
        <script>
  setInterval(() => {
    location.reload();
  }, 1000);
    </script>
            """

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

        elif cmd.startsWith("!"):
            results[index] &= ClosingTags(cmd[1..^1])

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
            processTag("div", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/meta:"):
            processTag("meta", ClidPos, CssClass, IDClass, 6, cmd, index, results, false)

        elif cmd.startsWith("/label:"):
            processTag("label", ClidPos, CssClass, IDClass, 7, cmd, index, results, false)

        elif cmd.startsWith("/opt:"):
            processTag("option", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/btn:"):
            processTag("btn", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/form:"):
            processTag("form", ClidPos, CssClass, IDClass, 6, cmd, index, results, false)

        elif cmd.startsWith("/leg:"):
            processTag("legend", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/fieldset:"):
            processTag("fieldset", ClidPos, CssClass, IDClass, 10, cmd, index, results, false)

        elif cmd.startsWith("/opt:"):
            processTag("option", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/sel:"):
            processTag("select", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/ta:"):
            processTag("textarea", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/aside:"):
            processTag("aside", ClidPos, CssClass, IDClass, 6, cmd, index, results, false)

        elif cmd.startsWith("/figcap:"):
            processTag("figcaption", ClidPos, CssClass, IDClass, 8, cmd, index, results, false)

        elif cmd.startsWith("/figure:"):
            processTag("figure", ClidPos, CssClass, IDClass, 8, cmd, index, results, false)

        elif cmd.startsWith("/section:"):
            processTag("section", ClidPos, CssClass, IDClass, 9, cmd, index, results, false)

        elif cmd.startsWith("/article:"):
            processTag("article", ClidPos, CssClass, IDClass, 9, cmd, index, results, false)

        elif cmd.startsWith("/ul:"):
            processTag("ul", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/ol:"):
            processTag("ol", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/nav:"):
            processTag("nav", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/bd:"):
            processTag("body", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/hd:"):
            processTag("head", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/hrd:"):
            processTag("header", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/frd:"):
            processTag("footer", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)

        elif cmd.startsWith("/ta:"):
            processTag("footer", ClidPos, CssClass, IDClass, 4, cmd, index, results, false)

        elif cmd.startsWith("/sel:"):
            processTag("footer", ClidPos, CssClass, IDClass, 5, cmd, index, results, false)
 
        if cmd.startsWith("nl:"):
            let content = cmd[3..^1].strip()
            results[index] &= "<br>" & content

        elif cmd.startsWith("in:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            let parts = content.split(':').mapIt(it.strip())

            var inputType = ""
            var inputName = ""
            var inputValue = ""
            var inputPlaceholder = ""
            var inputForm = ""
            var inputDisabled = false
            var inputRequired = false
            var inputReadonly = false
            var inputMin = ""
            var inputMax = ""
            var inputStep = ""

            for part in parts:
                if part.startsWith("type="): inputType = part[5..^1].strip()
                elif part.startsWith("name="): inputName = part[5..^1].strip()
                elif part.startsWith("value="): inputValue = part[6..^1].strip()
                elif part.startsWith("placeholder="): inputPlaceholder = part[12..^1].strip()
                elif part.startsWith("form="): inputForm = part[5..^1].strip()
                elif part == "disabled": inputDisabled = true
                elif part == "required": inputRequired = true
                elif part == "readonly": inputReadonly = true
                elif part.startsWith("min="): inputMin = part[4..^1].strip()
                elif part.startsWith("max="): inputMax = part[4..^1].strip()
                elif part.startsWith("step="): inputStep = part[5..^1].strip()

            results[index] &= "<input"

            if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
            if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
            if inputType.len > 0: results[index] &= " type=\"" & inputType & "\""
            if inputName.len > 0: results[index] &= " name=\"" & inputName & "\""
            if inputValue.len > 0: results[index] &= " value=\"" & inputValue & "\""
            if inputPlaceholder.len > 0: results[index] &= " placeholder=\"" & inputPlaceholder & "\""
            if inputForm.len > 0: results[index] &= " form=\"" & inputForm & "\""
            if inputMin.len > 0: results[index] &= " min=\"" & inputMin & "\""
            if inputMax.len > 0: results[index] &= " max=\"" & inputMax & "\""
            if inputStep.len > 0: results[index] &= " step=\"" & inputStep & "\""
            if inputDisabled: results[index] &= " disabled"
            if inputRequired: results[index] &= " required"
            if inputReadonly: results[index] &= " readonly"

            results[index] &= ">"

        elif cmd.startsWith("hr:"):
            let content = cmd[3..^1].strip()
            results[index] &= "<hr>" & content

        elif cmd.startsWith("#"):
            let textText = cmd[1..^1].strip()
            results[index] &= "<!--" & textText & "-->"


        elif cmd.startsWith("img:"):
            let imgSrc = cmd[4..^1].strip()
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            results[index] &= "<img src=\"" & imgSrc & "\" class=\"" & CssClass & "\" id =\"" & IDClass & "\">"
        
        # now onto the freaky ones (they need closing tags)

        # firstly just the h1-6

        elif cmd.startsWith("h1:"):
            processTag("h1", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("h2:"):
            processTag("h2", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("h3:"):
            processTag("h3", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("h4:"):
            processTag("h4", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("h5:"):
            processTag("h5", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("h6:"):
            processTag("h6", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("opt:"):
            processTag("option", ClidPos, CssClass, IDClass, 4, cmd, index, results, true)

        elif cmd.startsWith("fieldset:"):
            processTag("fieldset", ClidPos, CssClass, IDClass, 9, cmd, index, results, true)

        elif cmd.startsWith("ta:"):
            processTag("ta", ClidPos, CssClass, IDClass, 3, cmd, index, results, true)

        elif cmd.startsWith("label:"):
            processTag("label", ClidPos, CssClass, IDClass, 6, cmd, index, results, true)

        elif cmd.startsWith("btn:"):
            processTag("btn", ClidPos, CssClass, IDClass, 5, cmd, index, results, true)

        elif cmd.startsWith("form:"):
            processTag("form", ClidPos, CssClass, IDClass, 5, cmd, index, results, true)

        elif cmd.startsWith("p:"):
            processTag("p", ClidPos, CssClass, IDClass, 2, cmd, index, results, true)

        elif cmd.startsWith("legend:"):
            processTag("legend", ClidPos, CssClass, IDClass, 7, cmd, index, results, true)

        elif cmd.startsWith("section:"):
            processTag("section", ClidPos, CssClass, IDClass, 8, cmd, index, results, true)

        elif cmd.startsWith("figcap:"):
            processTag("figcaption", ClidPos, CssClass, IDClass, 7, cmd, index, results, true)

        elif cmd.startsWith("figure:"):
            processTag("figure", ClidPos, CssClass, IDClass, 7, cmd, index, results, true)

        elif cmd.startsWith("aside:"):
            processTag("aside", ClidPos, CssClass, IDClass, 6, cmd, index, results, true)

        elif cmd.startsWith("article:"):
            processTag("article", ClidPos, CssClass, IDClass, 8, cmd, index, results, true)

        elif cmd.startsWith("div:"):
            processTag("div", ClidPos, CssClass, IDClass, 4, cmd, index, results, true)

        elif cmd.startsWith("title:"):
            processTag("title", ClidPos, CssClass, IDClass, 6, cmd, index, results, true)

        elif cmd.startsWith("-:"):
            processTag("li", ClidPos, CssClass, IDClass, 2, cmd, index, results, true)

        elif cmd.startsWith("sel:"):
            processTag("sel", ClidPos, CssClass, IDClass, 4, cmd, index, results, true)

        elif cmd.startsWith("iframe:"):
            clid = cmd[6..^1].strip()
            let split = clid.split(':').mapIt(it.strip())
            if split.len == 2:
                let source = split[0]
                let options = split[1]
                results[index] &= "<iframe src=\"" & source & "\"  class=\"" & CssClass & "\" id =\"" & IDClass & "\"" & options & ">"
                let SourceEndPos = results.len - index - 1 # Use correct formula
                echo "SourceEndPos = ", SourceEndPos
                results[SourceEndPos] &= "</iframe>"

        elif cmd.startsWith("source:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let source = cmd[7..^1].strip()
            results[index] &= "<a href=\"" & source & "\"  class=\"" & CssClass & "\" id =\"" & IDClass & "\">"
            let SourceEndPos = results.len - index - 1 # Use correct formula
            echo "SourceEndPos = ", SourceEndPos
            results[SourceEndPos] &= "</a>"


# closing commands that need special attributes

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

    # sleep(1000)
    # main()


main()