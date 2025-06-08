import os, strutils

let inputFile = "index.sel"
let outputFile = "index.html"

proc parseLine(line: string): string =
    let trimmedLine = line.strip()

    let firstHash = trimmedLine.find('#')
    if firstHash >= 0:
        let secondHash = trimmedLine.find('#', firstHash + 1)
        if secondHash > firstHash:
            let codePart = trimmedLine[0 ..< firstHash].strip()
            let commentPart = trimmedLine[(firstHash + 1) ..< secondHash].strip()
            # Compose line with HTML comment replacing #...#
            # If codePart is empty, output only comment as a comment line
            if codePart.len > 0:
                return codePart & " <!-- " & commentPart & " -->"
            else:
                return "<!-- " & commentPart & " -->"
    
    if trimmedLine.startsWith("-bd"): # </body> tag
        return "</body>"

    if trimmedLine.startsWith("bd"): # <body> tag
        return "<body>" & trimmedLine[2..^1].strip()

    if trimmedLine.startsWith("-bd"): # </body> tag
        return "</body>"

    if trimmedLine.startsWith("hd"): # <head> tag
        return "<head>" & trimmedLine[2..^1].strip()

    if trimmedLine.startsWith("-hd"): # close header
        return "</head>"

    if trimmedLine.startsWith("type: "):
        return "<!DOCTYPE " & trimmedLine[6..^1].strip() & ">"

    if trimmedLine.startsWith("+"): #if they dont want anything added
        return trimmedLine[1..^1]

    if trimmedLine.startsWith("h1"):
        return "<h1>" & trimmedLine[1..^1].strip() & "</h1>"

    elif trimmedLine.startsWith("- "):
        return "<li>" & trimmedLine[2..^1].strip() & "</li>"

  # Otherwise, treat it as a paragraph <p>
    else:
        return "<p>" & line & "</p>"

proc main() =
  if not fileExists(inputFile):
    echo "Input file not found: ", inputFile
    return

  var outputLines = newSeq[string]()

  for line in lines(inputFile):
    let htmlLine = parseLine(line)
    outputLines.add(htmlLine)

  # Join all lines with newlines and write to output file
  writeFile(outputFile, join(outputLines, "\n"))
  echo "Written output to ", outputFile

main()


