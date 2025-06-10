import os, strutils, sequtils

let inputFile = "index.sel"
let outputFile = "index.html"
var htmlMode = true

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
            echo CssClass

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

        elif cmd.startsWith("Btn"):
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

        # for the loading preset of the css styles

        elif cmd.startsWith("load presets;"):
            results[index] &= ""

        # debug
        echo "Command #" & $(index+1) & ": " & cmd


    # Join all results in order (but only for real slots)
    return results.join("")

proc main() =
    if not fileExists(inputFile):
        echo "Input file not found: ", inputFile
        return

    var outputLines = newSeq[string]()

    for line in lines(inputFile):
        if not htmlMode:
            break   # Stop processing further lines
        
        let htmlLine = parseLine(line)
        outputLines.add(htmlLine)


    # Join all lines with newlines and write to output file
    writeFile(outputFile, join(outputLines, "\n"))
    echo "Written output to ", outputFile


if htmlMode:
    main()



