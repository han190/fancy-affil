
// #import "@local/maketitle:0.1.0": maketitle
#import "/src/affiliation.typ": get-affiliations

#let authors = (
  (
    name: "Nicolaus Copernicus",
    affiliation: (
      "University of Krakow (Poland)",
      "University of Bologna (Italy)",
      "University of Padua (Italy)",
      "University of Ferrara (Italy)",
      "Frombork Cathedral (Poland)",
    ),
  ),
  (
    name: "Tycho Brahe",
    affiliation: (
      "University of Copenhagen (Denmark)",
      "Leipzig University (Germany)",
      "University of Rostock (Germany)",
    ),
  ),
  (
    name: "Johannes Kepler",
    affiliation: (
      "Tübinger Stift (Germany)",
      "University of Tübingen (Germany)",
    ),
  ),
  (
    name: "Galileo Galilei",
    affiliation: (
      "University of Pisa (Italy)",
      "University of Padua (Italy)",
    ),
  ),
  (
    name: "Christiaan Huygens",
    affiliation: (
      "University of Leiden (Netherlands)",
      "Royal Society of London (England)",
      "Paris Academy of Sciences (France)",
    ),
  ),
  (
    name: "Giovanni Domenico Cassini",
    affiliation: (
      "Paris Observatory (France)",
      "Paris Academy of Sciences (France)",
    ),
  ),
  (
    name: "Isaac Newton",
    affiliation: (
      "Trinity College, Cambridge University (England)",
      "Royal Society of London (England)",
    ),
  ),
  (
    name: "Pierre-Simon Laplace",
    affiliation: (
      "University of Paris (France)",
      "Paris Academy of Sciences (France)",
    ),
  ),
  (
    name: "William Herschel",
    affiliation: (
      "Private Observatory in Slough (England)",
      "Royal Society of London (England)",
    ),
  ),
)


#set page("a4", margin: 1in, flipped: true)
#set text(size: 12pt)
#set grid(
  columns: (1fr, 1fr),
  align: (left, center),
  column-gutter: 8pt,
  inset: 8pt,
)

== Example 1: Default options
#grid(
  fill: (luma(240), white),
  [
    ```typst
    #let authors = (
      (
        name: "Nicolaus Copernicus",
        affiliation: (
          "University of Krakow (Poland)",
          "University of Bologna (Italy)",
          "University of Padua (Italy)",
          "University of Ferrara (Italy)",
          "Frombork Cathedral (Poland)",
        ),
      ),
      (
        name: "Tycho Brahe",
        affiliation: (
          "University of Copenhagen (Denmark)",
          "Leipzig University (Germany)",
          "University of Rostock (Germany)",
        ),
      ),
      // and many other author dictionaries...
    )

    #let (authors, affiliations) = get-affiliations(authors)
    #authors
    #affiliations
    ```
  ],
  [
    #let (authors, affiliations) = get-affiliations(authors)
    #authors
    #affiliations
  ],
)
