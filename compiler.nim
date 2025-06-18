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

proc ClosingTags(tag: string): string =
    result = "</" & tag & ">"

proc OpenTags(tag: string, CLIDpos: int, Class: string, ID: string, prefixLen: int, cmd: string): string =
    var classVal = Class
    var idVal = ID
    let content = cmd[prefixLen..^1].strip()
    result = "<" & tag & " class=\"" & classVal & "\" id=\"" & idVal & "\">" & content 

proc processTag(tag: string, prefixLen: int, cmd: string, index: int, ClidPos: int, CssClass: string, IDClass: string, results: var seq[string]) =
    var classVal = CssClass
    var idVal = IDClass
    if ClidPos != index - 1:
        classVal = ""
        idVal = ""
    results[index] &= OpenTags(tag, ClidPos, classVal, idVal, prefixLen, cmd)

proc SelfClosingTags(tag: string, CLIDpos: int, Class: string, ID: string, prefixLen: int, cmd: string, index: int, results: var seq[string]) =
    var classVal = Class
    var idVal = ID

    if CLIDpos != index - 1:
        classVal = ""
        idVal = ""

    let content = cmd[prefixLen..^1].strip()
    let EndPos = results.len - index - 1
    results[index] = "<" & tag & " class=\"" & classVal & "\" id=\"" & idVal & "\">" & content
    results[EndPos] = "</" & tag & ">"

proc button(Closes: bool, ClidPos: int, CssClass: var string, IDClass: var string, cmd: string, index: int, results: var seq[string]) =
    if ClidPos != index - 1:
        CssClass = ""
        IDClass = ""

    let content = cmd[4..^1].strip()
    let parts = content.split(':').mapIt(it.strip())

    var buttonType = ""
    var buttonValue = ""
    var buttonName = ""
    var formAttr = ""
    var titleAttr = ""
    var disabled = false
    var btnText = ""

    for part in parts:
        if part.startsWith("type="): buttonType = part[5..^1].strip()
        elif part.startsWith("value="): buttonValue = part[6..^1].strip()
        elif part.startsWith("name="): buttonName = part[5..^1].strip()
        elif part.startsWith("form="): formAttr = part[5..^1].strip()
        elif part.startsWith("title="): titleAttr = part[6..^1].strip()
        elif part == "disabled": disabled = true
        else: btnText = part

    results[index] &= "<button"
    if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
    if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
    if buttonType.len > 0: results[index] &= " type=\"" & buttonType & "\""
    if buttonValue.len > 0: results[index] &= " value=\"" & buttonValue & "\""
    if buttonName.len > 0: results[index] &= " name=\"" & buttonName & "\""
    if formAttr.len > 0: results[index] &= " form=\"" & formAttr & "\""
    if titleAttr.len > 0: results[index] &= " title=\"" & titleAttr & "\""
    if disabled: results[index] &= " disabled"

    if Closes:
        let EndPos = results.len - index - 1
        results[EndPos] &= ">" & btnText & "</button>"
    else:
        results[index] &= ">" & btnText

proc form(Closes: bool, ClidPos: int, CssClass: var string, IDClass: var string, cmd: string, index: int, results: var seq[string]) =
    if ClidPos != index - 1:
        CssClass = ""
        IDClass = ""

    let content = cmd[5..^1].strip()
    let parts = content.split(':').mapIt(it.strip())

    var actionAttr = ""
    var methodAttr = ""
    var targetAttr = ""
    var enctypeAttr = ""
    var autocompleteAttr = ""

    for part in parts:
        if part.startsWith("action="): actionAttr = part[7..^1].strip()
        elif part.startsWith("method="): methodAttr = part[7..^1].strip()
        elif part.startsWith("target="): targetAttr = part[7..^1].strip()
        elif part.startsWith("enctype="): enctypeAttr = part[8..^1].strip()
        elif part.startsWith("autocomplete="): autocompleteAttr = part[13..^1].strip()

    results[index] &= "<form"

    if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
    if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
    if actionAttr.len > 0: results[index] &= " action=\"" & actionAttr & "\""
    if methodAttr.len > 0: results[index] &= " method=\"" & methodAttr & "\""
    if targetAttr.len > 0: results[index] &= " target=\"" & targetAttr & "\""
    if enctypeAttr.len > 0: results[index] &= " enctype=\"" & enctypeAttr & "\""
    if autocompleteAttr.len > 0: results[index] &= " autocomplete=\"" & autocompleteAttr & "\""

    results[index] &= ">"
    if Closes:
        let closePos = results.len - index - 1
        results[closePos] &= "</form>"

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
            processTag("div", 5, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/leg:"):
            processTag("legend", 5, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/fieldset:"):
            processTag("fieldset", 10, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/label:"):
            processTag("label", 7, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/opt:"):
            processTag("option", 5, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/sel:"):
            processTag("select", 5, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/ta:"):
            processTag("textarea", 4, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/aside:"):
            processTag("aside", 6, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/figcap:"):
            processTag("figcaption", 8, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/figure:"):
            processTag("figure", 8, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/section:"):
            processTag("section", 9, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("/article:"):
            processTag("article", 9, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("ul:"):
            processTag("ul", 3, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("ol:"):
            processTag("ol", 3, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("nav:"):
            processTag("nav", 4, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("bd:"):
            processTag("body", 3, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("hd:"):
            processTag("head", 3, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("hrd:"):
            processTag("header", 4, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("frd:"):
            processTag("footer", 4, cmd, index, ClidPos, CssClass, IDClass, results)

        elif cmd.startsWith("nl:"):
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

        elif cmd.startsWith("meta:"):
        # meta tags are self-closing, no content or closing tag
            let content = cmd[5..^1].strip()
            let parts = content.split(':').mapIt(it.strip())

            var metaName = ""
            var metaContent = ""
            var metaCharset = ""
            var metaHttpEquiv = ""

            for part in parts:
                if part.startsWith("name="): metaName = part[5..^1].strip()
                elif part.startsWith("content="): metaContent = part[8..^1].strip()
                elif part.startsWith("charset="): metaCharset = part[8..^1].strip()
                elif part.startsWith("http-equiv="): metaHttpEquiv = part[10..^1].strip()

            results[index] &= "<meta"

            if metaCharset.len > 0:
                results[index] &= " charset=\"" & metaCharset & "\""
            else:
                if metaName.len > 0: results[index] &= " name=\"" & metaName & "\""
                if metaContent.len > 0: results[index] &= " content=\"" & metaContent & "\""
                if metaHttpEquiv.len > 0: results[index] &= " http-equiv=\"" & metaHttpEquiv & "\""

            results[index] &= ">"



        elif cmd.startsWith("hr:"):
            let content = cmd[3..^1].strip()
            results[index] &= "<hr>" & content

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
            SelfClosingTags("h1", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        elif cmd.startsWith("h2:"):
            SelfClosingTags("h2", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        elif cmd.startsWith("h3:"):
            SelfClosingTags("h3", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        elif cmd.startsWith("h4:"):
            SelfClosingTags("h4", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        elif cmd.startsWith("h5:"):
            SelfClosingTags("h5", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        elif cmd.startsWith("h6:"):
            SelfClosingTags("h6", ClidPos, CssClass, IDClass, 3, cmd, index, results)

        #now the rest


        elif cmd.startsWith("p:"):
            SelfClosingTags("p", ClidPos, CssClass, IDClass, 2, cmd, index, results)

        elif cmd.startsWith("legend:"):
            SelfClosingTags("legend", ClidPos, CssClass, IDClass, 7, cmd, index, results)

        elif cmd.startsWith("p:"):
            SelfClosingTags("p", ClidPos, CssClass, IDClass, 2, cmd, index, results)

        elif cmd.startsWith("section:"):
            SelfClosingTags("section", ClidPos, CssClass, IDClass, 8, cmd, index, results)

        elif cmd.startsWith("figcap:"):
            SelfClosingTags("figcaption", ClidPos, CssClass, IDClass, 7, cmd, index, results)

        elif cmd.startsWith("figure:"):
            SelfClosingTags("figure", ClidPos, CssClass, IDClass, 7, cmd, index, results)

        elif cmd.startsWith("aside:"):
            SelfClosingTags("aside", ClidPos, CssClass, IDClass, 6, cmd, index, results)

        elif cmd.startsWith("article:"):
            SelfClosingTags("article", ClidPos, CssClass, IDClass, 8, cmd, index, results)

        elif cmd.startsWith("div:"):
            SelfClosingTags("div", ClidPos, CssClass, IDClass, 4, cmd, index, results)

        elif cmd.startsWith("title:"):
            SelfClosingTags("title", ClidPos, CssClass, IDClass, 6, cmd, index, results)

        elif cmd.startsWith("-:"):
            SelfClosingTags("li", ClidPos, CssClass, IDClass, 2, cmd, index, results)


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


        elif cmd.startsWith("ta:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let innerAndAttrs = cmd[3..^1].strip()
            let parts = innerAndAttrs.split(':').mapIt(it.strip()) # array based on spliiting it on colons
            var textContent = ""
            var placeholder = ""
            var rows = ""
            var cols = ""

            for i in 0..<parts.len:
                if parts[i].startsWith("placeholder="):
                    placeholder = parts[i][12..^1]
                elif parts[i].startsWith("rows="):
                    rows = parts[i][5..^1]
                elif parts[i].startsWith("cols="):
                    cols = parts[i][5..^1]
                else:
                    textContent = parts[i][0..^1]

            results[index] &= "<textarea class=\"" & CssClass & "\" id=\"" & IDClass & "\""

            if placeholder.len > 0:
                results[index] &= " placeholder=\"" & placeholder & "\""
            if rows.len > 0:
                results[index] &= " rows=\"" & rows & "\""
            if cols.len > 0:
                results[index] &= " cols=\"" & cols & "\""

            results[index] &= ">" & textContent

            let SourceEndPos = results.len - index - 1
            results[SourceEndPos] &= "</textarea>"


        elif cmd.startsWith("label:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[6..^1].strip()
            let parts = content.split(':').mapIt(it.strip())

            var targetId = ""
            var labelText = ""
            var formAttr = ""
            var titleAttr = ""

            for i in 0 ..< parts.len:
                if parts[i].startsWith("form="):
                    formAttr = parts[i][5..^1].strip()
                elif parts[i].startsWith("title="):
                    titleAttr = parts[i][6..^1].strip()
                elif parts[i].startsWith("for="):
                    targetID = parts[i][4..^1].strip()
                else:
                    labelText = parts[i][0..^1]

            results[index] &= "<label class=\"" & CssClass & "\" id=\"" & IDClass & "\""

            if targetId.len > 0:
                results[index] &= " for=\"" & targetId & "\""
            if formAttr.len > 0:
                results[index] &= " form=\"" & formAttr & "\""
            if titleAttr.len > 0:
                results[index] &= " title=\"" & titleAttr & "\""

            results[index] &= ">" & labelText

            let ButtonEndPos = results.len - index - 1
            results[ButtonEndPos] &= "</label>"


        elif cmd.startsWith("sel:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[4..^1].strip()
            let parts = content.split(':').mapIt(it.strip())

            var nameAttr = ""
            var formAttr = ""
            var titleAttr = ""
            var requiredAttr = ""

            for part in parts:
                if part.startsWith("name="):
                    nameAttr = part[5..^1].strip()
                elif part.startsWith("form="):
                    formAttr = part[5..^1].strip()
                elif part.startsWith("title="):
                    titleAttr = part[6..^1].strip()
                elif part == "required":
                    requiredAttr = "required"

            results[index] &= "<select"

            if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
            if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
            if nameAttr.len > 0: results[index] &= " name=\"" & nameAttr & "\""
            if formAttr.len > 0: results[index] &= " form=\"" & formAttr & "\""
            if titleAttr.len > 0: results[index] &= " title=\"" & titleAttr & "\""
            if requiredAttr.len > 0: results[index] &= " " & requiredAttr

            results[index] &= ">"
            
            let selectEndPos = results.len - index - 1
            results[selectEndPos] &= "</select>"


        elif cmd.startsWith("option:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[7..^1].strip()
            let parts = content.split(':').mapIt(it.strip())

            var valueAttr = ""
            var labelAttr = ""
            var optionText = ""

            for part in parts:
                if part.startsWith("value="):
                    valueAttr = part[6..^1].strip()
                elif part.startsWith("label="):
                    labelAttr = part[6..^1].strip()
                else:
                    optionText = part

            results[index] &= "<option"

            if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
            if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
            if valueAttr.len > 0: results[index] &= " value=\"" & valueAttr & "\""
            if labelAttr.len > 0: results[index] &= " label=\"" & labelAttr & "\""

            results[index] &= ">" & optionText & "</option>"


        elif cmd.startsWith("form:"):
            form(true, CLidPos, CssClass, IDClass, cmd, index, results)
        elif cmd.startsWith("/form:"):
            form(false, CLidPos, CssClass, IDClass, cmd, index, results)

        elif cmd.startsWith("fieldset:"):
            if ClidPos != index - 1:
                CssClass = ""
                IDClass = ""

            let content = cmd[9..^1].strip()
            let legendText = content  # optional, plain text legend

            results[index] &= "<fieldset"
            if CssClass.len > 0: results[index] &= " class=\"" & CssClass & "\""
            if IDClass.len > 0: results[index] &= " id=\"" & IDClass & "\""
            results[index] &= ">"

            if legendText.len > 0:
                results[index] &= "<legend>" & legendText & "</legend>"

            let closePos = results.len - index - 1
            results[closePos] &= "</fieldset>"

        elif cmd.startsWith("btn:"):
            button(true, ClidPos, CssClass, IDClass, cmd, index, results)

        elif cmd.startsWith("/btn"):
            button(false, ClidPos, CssClass, IDClass, cmd, index, results)

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

    sleep(1000)
    main()


main()