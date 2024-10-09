#import "./src/lib.typ": maketitle

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
      "University of Copenhagen",
      "Leipzig University",
      "University of Rostock",
    ),
  ),
  (
    name: "Johannes Kepler",
    affiliation: (
      "Tübinger Stift",
      "University of Tübingen",
    ),
  ),
  (
    name: "Galileo Galilei",
    affiliation: (
      "University of Pisa",
      "University of Padua",
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
      "University of Paris (Sorbonne) (France)",
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

#show: doc => maketitle(
  title: [
    On the Development of Astronomy in 
    Renaissance and Early Modern Europe
  ],
  authors: authors,
  date: datetime(year: 1799, month: 12, day: 31),
  doc,
)