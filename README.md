# Nim-mustache

[Mustache](https://mustache.github.io/mustache.1.html) in [Nim](https://nim-lang.org).

Nim-mustache is a Nim implementation of Mustache.
Mustache is a logic-less templating system inspired by ctemplate and et.
Mustache "emphasizes separating logic from presentation: it is impossible to embed application logic in this template language."

![Build Status](https://travis-ci.org/soasme/nim-mustache.svg?branch=master)

## Status

Nim-mustache is in beta stage. Welcome to contribute, comment, and report issues. ❤️

## Features

- ✨ Support `Static Text`.
- ✨ Support `{{Variables}}`.
- ✨ Support `{{# Section }} {{/ Section }}`.
- ✨ Support `{{^ InvertedSection }} {{/ InvertedSection }}`.
- ✨ Support `{{! Comments }}`.
- ✨ Support `{{=<% %>=}} <% SetDelimiter %>`.
- ✨ Support `{{> Partial }}`.
- ✨ Support Lambda.
- ✨ Passed all mustache specs.

## Getting Started

Nim-mustache requires Nim >= 0.20.

```bash
$ nimble install mustache
```

## Usage

```nim
# Step 1.
import mustache, tables

# Step 2.
var c = newContext()
c["i"] = 1
c["f"] = 1.0
c["s"] = "hello world"
c["a"] = @[{"k": "v"}.toTable]
c["t"] = {"k": "v"}.toTable
c["l"] = proc(s: string, c: Context): string = "<b>" & s.render(c) & "</b>"

# Step 3.
let s = """
{{i}} {{f}} {{s}}
{{#a}}
  {{k}}
{{/a}}

{{#t}}
  {{k}}
{{/t}}

{{#l}}
  {{s}}
{{/l}}
"""
echo(s.render(c))
```

## Advanced Usage

### Set Arbitrary Objects in Context

Consider you have your own object `Stock`.

```nim
type Stock = object
  name*: string
  price*: int

let stock = Stock(name: "NIM", price: 1000)
```

It would be convenient if you can set it to context:

```nim
let c = newContext()
c["stock"] = stock
let s = "{{#stock}}{{name}}: {{price}}{{/stock}}"
echo(s.render(c))
```

The trick is to define a `castValue` proc for your type.
Below is an example of how to define a `castValue` for `Stock`.

```nim
proc castValue(value: Stock): Value =
  let newValue = new(Table[string, Value])
  result = Value(kind: vkTable, vTable: newValue)
  newValue["name"] = value.name.castValue
  newValue["price"] = value.price.castValue
```

### Change Partials Searching Dir

By default, partials are located in `cwd`.

```
$ ls
main.mustache    partial.mustache
$ cat main.mustache
{{> partial}}
```

But what if mustache files are in other locations?

```
$ pwd
/tmp/path/to
$ ls -R
main.mustache
templates/partial.mustache
```

In this case, You can specify other searching dirs:

```nim
let c = newContext(searchDirs=@["/path/to/templates", "./"])
let s = readFile("main.mustache")
echo(s.render(c))
```

### Read Partials From Memory

You can also read mustache partials from an in-memory table:

```nim
import tables
let partials = {
  "something": "This is something"
}.toTable()
let c = newContext(partials=partials)
let s = "something: {{> something}}"
echo(s.render(c))
```

### Use Mustache With Jester

It's recommended using Mustache with Jester, a sinatra-like web framework for Nim, when writing a web application.

Imagine you have a template file named `hello.mustache`. Rendering the template can be as simple as calling it in a route.

```nim
import jester
import mustache

routes:
  get "/hello/@name":
    let c = newContext()
    c["name"] = @"name"
    resp "{{ >hello }}".render(c)
```

In `hello.mustache`, it's just mustache template content.

```mustache
<html>
  <body>
    <h1>Hello, {{ name }}</h1>
  </body>
</html>
```

If you have a dedicated directory template directory, you can specify it as:

```
let c = newContext(searchDirs = @["/path/to/templates"])
```


## Develop

Build the binary.

```
$ nimble build
```

Run test cases.

```bash
$ nimble test
```

## Changelog

* v0.2.1, 20 Sep 2019, fix locks level warnings.
* v0.2.0, 20 Sep 2019, support setting arbitrary objects in context.
* v0.1.0, 19 Sep 2019, initial release.

## Alternatives

* [moustachu](https://github.com/fenekku/moustachu). Moustachu doesn't implement some mustache features, such as lambda, set delimiters, while Nim-mustache supports all mustache features.

## References

* [Spec](https://github.com/mustache/spec)
* [Syntax](http://mustache.github.com/mustache.5.html)
