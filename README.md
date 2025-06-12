# Selene Templating Engine

**Selene** is a lightweight templating engine for generating HTML and CSS using a custom syntax.

---

## 🛠 Getting Started

1. Install [Nim](https://nim-lang.org).
2. Place your `FileName.sel` file in the same folder as `compiler.nim`.
3. Run the compiler:

```bash
sudo nim r compiler.nim
```

---

4. input the Name of your file (without the .sel)

## ✨ Features

- Supports **HTML** and **CSS** modes
- JavaScript support coming soon
- Clean, readable syntax
- Supports nesting and reusable classes

Switch to CSS mode using:

```selene
start css;
```

---

## 📐 Syntax Rules

- Commands end with `;`
- Inputs use `:`, e.g. `div: Hello;`
- Whitespace is ignored
- Max **100 commands per line**
- Nesting and multiple classes are supported
- `clid:` applies only to the next command
- Multiple classes are space-separated

---

## 📄 HTML Mode

### clid Example

```selene
clid: container : ID; div: Hello;
```

Outputs:

```html
<div class="container " id="ID">Hello</div>
```

Multiple classes:

```selene
clid: text-xl bg-white text-black: IDName;
```

---

### 🔗 External Links

```selene
link.css: style.css;       --> <link href="style.css" rel="stylesheet" type="text/css">
link.icon: icon.png;       --> <link href="icon.png" rel="icon">
link.script: script.js;    --> <script src="script.js" defer></script>
```

---

### 🧩 Self-Closing & Content Tags (also support clid: ClassName: IDName;)

| Selene Command            | Output                                  |
|---------------------------|------------------------------------------|
| `-;`                      | `<li></li>`                              |
| `btn;`                    | `<button></button>`                      |
| `source: index.html;`     | `<a href="index.html"></a>`              |
| `title: My Site;`         | `<title>My Site</title>`                 |
| `div: Hello;`             | `<div>Hello</div>`                       |
| `p: Text;`                | `<p>Text</p>`                            |
| `h1: Heading;`            | `<h1>Heading</h1>`                        |
| `img: image.png;`         | `<img src="image.png">`                  |
| `text: plain text;`       | `plain text` (no HTML added)             |

---

### 🧭 Structural Tags

#### Opening Tags (also support clid: ClassName: IDName;)

```selene
hrd;    --> <header>
hd;     --> <head>
bd;     --> <body>
nav;    --> <nav>
/div;   --> <div>
```

#### Closing Tags (do NOT suport adding classes)

```selene
!hrd;   --> </header>
!hd;    --> </head>
!bd;    --> </body>
!nav;   --> </nav>
!div;   --> </div>
```

---

## 🎨 CSS Mode

Switch to CSS mode:

```selene
start css;
```

In CSS mode:

- Write raw CSS directly into the `.sel` file.
- Use `load preset;` to include a predefined CSS bundle (appended to `FileName.css`).

Example:

```selene
start css;
body {
  background-color: #111;
  color: #eee;
}
```

---

## 🧪 Example Output

```selene
class: list; -; class: button; btn: Click me;
```

Outputs:

```html
<li class="list"> <button class="button">Click me</button> </li>
```

---

## 🔧 Notes

- Nesting is fully supported.
- You can apply multiple class commands in sequence.
- Only the next command after `class:` is affected.


