#import "showdate.typ": showdate
#let SPACE = " "

#let parse-authors(authors) = {
  let (names, affil-array, affil-indices) = ((), (), ())

  for author in authors {
    assert("name" in author, message: "Invalid author.")
    names.push(author.name)

    if not "affiliation" in author {
      affil-indices.push(none)
      affil-array.push(none)
      continue
    }

    let affils = ()
    if type(author.affiliation) == str {
      affils.push(author.affiliation)
    } else if type(author.affiliation) == array {
      for affil in author.affiliation {
        assert(type(affil) == str, message: "Invalid affiliation.")
        affils.push(affil)
      }
    } else {
      assert("Invalid affiliation.")
    }

    let indices = ()
    for affil in affils {
      if affil in affil-array {
        let findloc = x => {
          x == affil
        }
        let loc = affil-array.position(findloc)
        indices.push(loc + 1)
      } else {
        affil-array.push(affil)
        let loc = affil-array.len()
        indices.push(loc)
      }
    }
    affil-indices.push(indices)
  }

  // Return
  (names, affil-array, affil-indices)
}

#let push-indices(indices, start-end, format) = {
  let start-str = numbering(format, start-end.at(0))
  let end-str = numbering(format, start-end.at(1))

  if start-end.at(1) == start-end.at(0) {
    indices.push(start-str)
  } else if start-end.at(1) == start-end.at(0) + 1 {
    indices.push(start-str + "," + end-str)
  } else {
    indices.push(start-str + "-" + end-str)
  }

  // Return
  indices
}

#let join-indices(indices, format) = {
  indices = indices.sorted()
  let start-end = (indices.at(0), indices.at(0))
  let results = ()

  for i in range(1, indices.len()) {
    if indices.at(i) == start-end.at(1) + 1 {
      start-end.at(1) = indices.at(i)
    } else {
      results = push-indices(results, start-end, format)
      start-end = (indices.at(i), indices.at(i))
    }
  }
  // Concatenate the last pair
  results = push-indices(results, start-end, format)

  // Return
  results.join(",")
}

#let optional-argument(parameters-dict, argument, default) = {
  let result = default
  if argument in parameters-dict {
    result = parameters-dict.at(argument)
  }

  // Return
  result
}

#let maketitle(title: none, authors: none, date: none, ..parameters, body) = {
  // Local constant and functions
  let GAP = h(1pt)
  let optional = optional-argument.with(parameters.named())

  // Title
  assert(title != none, message: "Invalid title.")
  let title-align = optional("title-align", center)
  let title-par = optional("title-par", (leading: 0.5em))
  let title-block = optional("title-block", ())
  let title-text = optional("title-text", (size: 18pt, weight: "bold"))

  {
    set align(title-align)
    set par(..title-par)
    set block(..title-block)
    block(text(..title-text, title))
  }

  if authors.len() >= 1 {
    // Authors
    let (names, affil-array, affil-indices) = parse-authors(authors)
    // If there are only 2 authors use "and" otherwise use ",".
    let auth-texts = ()
    let join-script = "," + SPACE
    if names.len() == 2 {
      join-script = SPACE + "and" + SPACE
      // If two authors share same affiliation combine them.
      if affil-indices.at(0) == affil-indices.at(1) {
        affil-indices.at(0) = none
      }
    }

    let authors-numbering = optional("authors-numbering", "1")
    for i in range(names.len()) {
      let auth = names.at(i)
      if affil-indices.at(i) != none {
        let indices = join-indices(affil-indices.at(i), authors-numbering)
        auth-texts.push(auth + super(GAP + indices))
      } else {
        auth-texts.push(auth)
      }
    }

    let authors-align = optional("authors-align", center)
    let authors-par = optional("authors-par", ())
    let authors-block = optional("authors-block", ())
    let authors-text = optional("authors-text", (size: 14pt))
    {
      set align(authors-align)
      set par(..authors-par)
      set block(..authors-block)
      block(text(..authors-text, auth-texts.join(join-script)))
    }

    // Affiliations
    let affil-numbering = optional("affil-numbering", "1.")
    let affil-style = optional("affil-style", x => super(emph(x)))
    let affil-join = optional("affil-join", "," + SPACE)
    let affil-align = optional("affil-align", center)
    let affil-par = optional("affil-par", (justify: false))
    let affil-block = optional("affil-block", (width: 85%))
    let affil-text = optional("affil-text", (size: 10pt, style: "italic"))

    let affil-strs = ()
    let affil-label = ""
    let affil-str = ""
    for i in range(affil-array.len()) {
      if affil-array.at(i) != none {
        affil-label = affil-style(numbering(affil-numbering, i + 1))
        affil-str = text(..affil-text, affil-array.at(i))
        affil-strs.push(affil-label + affil-str)
      }
    }

    {
      set align(affil-align)
      set par(..affil-par)
      set block(..affil-block)
      block(affil-strs.join(affil-join))
    }
  }

  // Date
  if date != none {
    let date-display = ""
    if type(date) == dictionary {
      if "option" in date {
        let _date = date.remove("date")
        date-display = showdate(_date, ..date)
      } else {
        date-display = showdate(date.date)
      }
    } else if type(date) == datetime {
      date-display = showdate(date)
    } else if type(date) == str {
      date-display = date
    } else {
      assert("Invalid datetime.")
    }

    // Date block
    let date-align = optional("date-align", center)
    let date-par = optional("date-par", ())
    let date-block = optional("date-block", ())
    let date-text = optional("date-text", (size: 12pt))
    {
      set align(date-align)
      set par(..date-par)
      set block(..date-block)
      block(text(..date-text, date-display))
    }
  }

  // Return
  body
}