#import "@preview/problemst:0.1.1": pset

// Macros
#let eps = sym.epsilon
#let to = sym.arrow
#let notin = sym.in.not
#let infty = sym.oo
#let subseteq = sym.subset.eq
#let supseteq = sym.supset.eq

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

  #doc
]
