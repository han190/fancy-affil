#import "@local/maketitle:0.1.0": maketitle

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

#show heading: it => {
  set align(center)
  set text(16pt, weight: "regular", baseline: -1pt)
  let content = smallcaps(it.body)
  let content-size = measure(content)
  layout(size => {
    let content-width = content-size.width + 1pt
    let line-width = (size.width - content-width) * 0.5
    grid(
      columns: (line-width, content-width, line-width),
      align: (left + horizon, center + horizon, right + horizon),
      line(length: 100%), content, line(length: 100%),
    )
  })
}
#set page(width: 12in, height: 14in, margin: 1.1in)
#set grid(
  columns: (0.9fr, 1fr),
  align: (left, center),
  column-gutter: 8pt,
  inset: 8pt,
)

= Example 1: Title, Authors (Array of dictionaries)
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
      ...
    )

    #show: doc => maketitle(
      title: [
        On the Development of Astronomy in
        Renaissance and Early Modern Europe
      ],
      authors: authors,
      doc,
    )
    ```
  ],
  [
    #show: doc => maketitle(
      title: [
        On the Development of Astronomy in
        Renaissance and Early Modern Europe
      ],
      authors: authors,
      doc,
    )
  ],
)

= Example 2: Title, Authors (Array of strings), Date
#grid(
  fill: (luma(240), white),
  [
    ```typst
    #show: doc => maketitle(
      title: [
        Supplementary Material: On the Development
        of Astronomy in Renaissance and Early Modern Europe
      ],
      authors: ("Nicolaus Copernicus", "Tycho Brahe"),
      date: datetime(year: 1799, month: 12, day: 31),
      doc,
    )
    ```
  ],
  [
    #show: doc => maketitle(
      title: [
        Supplementary Material: On the Development of Astronomy in
        Renaissance and Early Modern Europe
      ],
      authors: ("Nicolaus Copernicus", "Tycho Brahe"),
      date: datetime(year: 1799, month: 12, day: 31),
      doc,
    )
  ]
)
