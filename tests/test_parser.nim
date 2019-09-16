import unittest, strscans, streams, strutils, tables

import mustachepkg/tokens
import mustachepkg/values
import mustachepkg/parser
import mustachepkg/render

test "parse text - normal text":
  check "parse text".parse.render(newContext()) == "parse text"

test "parse text - unopened tag":
  check "parse text }}".parse.render(newContext()) == "parse text }}"

test "parse text - unbalanced tag":
  check "parse text {{ xyz".parse.render(newContext()) == "parse text {{ xyz"

test "parse tag - escaped":
  let ctx = newContext()
  ctx["key"] = "value"
  for s in @["{{key}}", "{{ key  }}"]:
    check s.parse.render(ctx) == "value"

test "parse comment":
  check "{{!comment}}".parse.render(newContext()) == ""

test "parse unescaped":
  let ctx = newContext()
  ctx["name"] = "&mustache"
  check "{{& name}}".parse.render(ctx) == "&mustache"
  check "{{{ name }}}".parse.render(ctx) == "&mustache"

test "parse section open":
  let r = "{{# start }}".parse
  check r.len == 1
  check r[0] of SectionOpen
  check SectionOpen(r[0]).key.strip == "start"
  check SectionOpen(r[0]).inverted == false

test "parse section open - inverted":
  let r = "{{^ start }}".parse
  check r.len == 1
  check r[0] of SectionOpen
  check SectionOpen(r[0]).key.strip == "start"
  check SectionOpen(r[0]).inverted == true

test "parse section close":
  let r = "{{/section}}".parse
  check r.len == 1
  check r[0] of SectionClose
  check SectionClose(r[0]).key.strip == "section"

test "parse set elimiter - changed":
  let s = "{{=<% %>=}}<% key %>"
  let r = parse(s)
  check r.len == 2

test "parse partial":
  let s = "{{> key }}"
  let r = parse(s)
  check r.len == 1
  check r[0] of Partial
  check Partial(r[0]).key.strip == "key"

test "render section - never shown":
  let s = "{{#section}}Never shown{{/section}}"
  let c = newContext()
  let r = s.parse.render(c)
  check r == ""

test "render section - shown":
  let s = "{{#section}}Shown{{/section}}"
  let c = newContext()
  c["section"] = true
  let r = s.parse.render(c)
  check r == "Shown"

test "render section - non-empty lists":
  let s = "{{#repo}}{{name}}{{/repo}}"
  let c = newContext()
  c["repo"] = @[{"name": "Shown."}.toTable, {"name": "Shown Again."}.toTable]
  let r = s.parse.render(c)
  check r == "Shown.Shown Again."

test "render section - non-false values":
  let s = "{{#repo}}{{name}}{{/repo}}"
  let c = newContext()
  c["repo"] = {"name": "Shown."}.toTable
  let r = s.parse.render(c)
  check r == "Shown."

test "render section - .":
  let s = "{{#repo}}{{.}}{{/repo}}"
  let c = newContext()
  c["repo"] = @["Shown.", "Shown Again."]
  let r = s.parse.render(c)
  check r == "Shown.Shown Again."

test "render section - inverted":
  let s = "{{^section}}Shown.{{/section}}"
  let c = newContext()
  let r = s.parse.render(c)
  check r == "Shown."

test "render section - inverted truthy value":
  let s = "{{^section}}Never Shown.{{/section}}"
  let c = newContext()
  c["section"] = true
  let r = s.parse.render(c)
  check r == ""

#test "parse set delimiter":
  #let src = @["= <% %> =", "=<% %>="]
  #for s in src:
    #var delim = Delimiter(open: "{{", close: "}}")
    #var idx = 0
    #let r = setDelimiter(s, idx, delim)
    #check r == s.len
    #check delim.open == "<%"
    #check delim.close == "%>"
