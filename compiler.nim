import os, strutils

let inputFile = "index.sel"
let outputFile = "index.html"

proc parseLine(line: string): string =
  let commands = line.split(';')
  var result = ""

  # Button state
  var inButton = false
  var buttonSource = ""
  var buttonLinkText = ""
  var ButtonText = ""
  var SourceFound = false
  var LinkFound = false
  var inListItem = false
  var addListEnder = false

  for cmd in commands:
    let trimmedLine = cmd.strip()

    if trimmedLine.len == 0:
      continue  # Skip empty parts

    if trimmedLine.startsWith("-("):
      inListItem = true
      result &= "<li>"
      continue

    if trimmedLine.startsWith(")-"):
      inListItem = false
      addListEnder = true
      echo "this has worked"
      continue

    if trimmedLine.contains("Btn"):
      # Start button mode
      inButton = true
      buttonSource = ""
      buttonLinkText = ""
      ButtonText = ""
      SourceFound = false
      LinkFound = false
      continue

    if inButton:
      if trimmedLine.startsWith("source:"):
        buttonSource = trimmedLine[7..^1].strip()
        SourceFound = true
        continue
      elif trimmedLine.startsWith("link:"):
        buttonLinkText = trimmedLine[5..^1].strip()
        LinkFound = true
        continue
      elif trimmedLine.len > 0:
        # If not source: or link:, treat as button text
        ButtonText = trimmedLine
        # Now close the button
        if SourceFound and LinkFound:

          result &= "<button><a href=\"" & buttonSource & "\">" & buttonLinkText & "</a></button>"
          continue
        else:
          result &= "<button>" & ButtonText & "</button>"
        inButton = false
        continue

    # Normal command handling
    let firstHash = trimmedLine.find('#')
    if firstHash >= 0:
      let secondHash = trimmedLine.find('#', firstHash + 1)
      if secondHash > firstHash:
        let codePart = trimmedLine[0 ..< firstHash].strip()
        let commentPart = trimmedLine[(firstHash + 1) ..< secondHash].strip()
        if codePart.len > 0:
          result &= codePart & " <!-- " & commentPart & " -->"
        else:
          result &= "<!-- " & commentPart & " -->"
        continue

    if trimmedLine.contains("source: ") and trimmedLine.contains("link: "):
      let linkLineIndex = trimmedLine.find("link: ")
      let linkTextStartPos = linkLineIndex + "link: ".len

      var linkText = ""
      if linkTextStartPos < trimmedLine.len and trimmedLine[linkTextStartPos] == '+':
        linkText = ""
      else:
        linkText = trimmedLine[linkTextStartPos..^1]

      let sourceLineIndex = trimmedLine.find("source: ")
      let sourceStartPos = sourceLineIndex + "source: ".len
      let sourceOutput = trimmedLine[sourceStartPos..linkLineIndex - 1]

      result &= "<a href=\"" & sourceOutput & "\">" & linkText & "</a>"
      continue

    if trimmedLine.startsWith("-bd"):
      result &= "</body>"
      continue

    if trimmedLine.startsWith("bd"):
      result &= "<body>" & trimmedLine[2..^1].strip()
      continue

    if trimmedLine.startsWith("hd"):
      result &= "<head>" & trimmedLine[2..^1].strip()
      continue

    if trimmedLine.startsWith("-hd"):
      result &= "</head>" & trimmedLine[2..^1].strip()
      continue

    if trimmedLine.startsWith("type: "):
      result &= "<!DOCTYPE " & trimmedLine[6..^1].strip() & ">"
      continue

    if trimmedLine.startsWith("+"):
      result &= trimmedLine[1..^1]
      continue

    if trimmedLine.startsWith("h1"):
      result &= "<h1>" & trimmedLine[1..^1].strip() & "</h1>"
      continue

    if trimmedLine.startsWith(")-"):
      result &= "</li>"
      continue

    echo addListEnder

    # Otherwise, treat as paragraph
    result &= "<p>" & trimmedLine & "</p>"

  return result

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


