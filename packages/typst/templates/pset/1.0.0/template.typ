#import "@preview/problemst:0.1.1": pset
#import "@preview/lemmify:0.1.7": *

// Macros
#let eps = sym.epsilon
#let to = sym.arrow
#let notin = sym.in.not
#let infty = sym.oo
#let subseteq = sym.subset.eq
#let supseteq = sym.supset.eq

#let codeblock(filename) = raw(read(filename), block: true, lang: filename.split(".").at(-1))

#let (
  theorem,
  lemma,
  corollary,
  remark,
  proposition,
  example,
  proof,
  rules: thm-rules,
) = default-theorems("thm-group", lang: "en")

// Custom config
#let custom(doc) = [
  #set math.equation(numbering: "(1)")

  #show math.equation: it => {
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("")
    ] else {
      it
    }
  }

  #show: thm-rules

  #doc
]
