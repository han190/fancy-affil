
// #import "@local/maketitle:0.1.0": maketitle
#import "/src/affiliation.typ": get-authors

#let authors-info = (
  (
    name: "Nicolaus Copernicus",
    affiliation: (
      "University of Krakow (Poland)",
      "University of Bologna (Italy)",
      "University of Padua (Italy)",
      "University of Ferrara (Italy)",
      "Frombork Cathedral (Poland)",
    ),
    email: "NicolausCopernicus@krakow.edu",
    orcid: "0000-0001-2345-6789"
  ),
  (
    name: "Tycho Brahe",
    affiliation: (
      "University of Copenhagen (Denmark)",
      "Leipzig University (Germany)",
      "University of Rostock (Germany)",
    ),
    email: "TychoBarhe@copenhagen.edu",
  ),
  (
    name: "Johannes Kepler",
    affiliation: (
      "Tübinger Stift (Germany)",
      "University of Tübingen (Germany)",
    ),
    orcid: "0000-0012-3456-7890"
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


#let github-black = rgb("0d1117")
#let github-white = rgb("f0f6fc")
#let dark-theme = false

#let (background, foreground) = (github-white, github-black)
#let code-background = luma(224)
// #let (background, foreground) = (github-black, github-white)
// #let code-background = luma(32)

#set page(width: 4.9in, height: 11.69in, margin: 0.5in, flipped: true, fill: background)
#set text(size: 12pt, fill: foreground)
#set grid(
  columns: (1fr, 1fr),
  align: (left, center),
  column-gutter: 8pt,
  inset: 8pt,
  fill: (code-background, background),
)

== Example 1: Default options
#grid(
  [
    ```typst
    #let authors-info = (
      (
        name: "Nicolaus Copernicus",
        affiliation: (
          "University of Krakow (Poland)",
          "University of Bologna (Italy)",
          "University of Padua (Italy)",
          "University of Ferrara (Italy)",
          "Frombork Cathedral (Poland)",
        ),
        email: "NicolausCopernicus@krakow.edu",
        orcid: "0000-0001-2345-6789"
      ), // and many other authors...
    )
    #let (auths-blk, affils-blk) = get-authors(authors-info)
    #auths-blk
    #affils-blk
    ```
  ],
  [
    #let (auths-blk, affils-blk) = get-authors(authors-info)
    #auths-blk
    #affils-blk
  ],
)
