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

#let push-indices(indices: (), start: 0, end: 0, format: "1") = {
  let start-str = numbering(format, start)
  let end-str = numbering(format, end)
  if start == end {
    indices.push(start-str)
  } else if end == start + 1 {
    indices.push(start-str + "," + end-str)
  } else {
    indices.push(start-str + "-" + end-str)
  }
  // Return
  indices
}

#let join-indices(indices: (), format: "1") = {
  let (start, end) = (indices.at(0), indices.at(0))
  let indices-strings = ()

  for i in range(1, indices.len()) {
    if indices.at(i) == end + 1 {
      end = indices.at(i)
    } else {
      indices-strings = push-indices(
        indices: indices-strings,
        start: start,
        end: end,
        format: format,
      )
      (start, end) = (indices.at(i), indices.at(i))
    }
  }

  // Concatenate the last pair
  indices-strings = push-indices(
    indices: indices-strings,
    start: start,
    end: end,
    format: format,
  )
  // Return
  indices-strings.join(",")
}

#let optional-argument(parameters-dict, argument, default: none) = {
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
  let title-align = optional("title-align", default: center)
  let title-par = optional("title-par", default: (leading: 0.5em))
  let title-block = optional("title-block", default: ())
  let title-text = optional(
    "title-text",
    default: (size: 18pt, weight: "bold"),
  )

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

    let authors-numbering = optional("authors-numbering", default: "1")
    for i in range(names.len()) {
      let auth = names.at(i)
      if affil-indices.at(i) != none {
        let indices = join-indices(
          indices: affil-indices.at(i),
          format: authors-numbering,
        )
        auth-texts.push(auth + super(GAP + indices))
      } else {
        auth-texts.push(auth)
      }
    }

    let authors-align = optional("authors-align", default: center)
    let authors-par = optional("authors-par", default: ())
    let authors-block = optional("authors-block", default: ())
    let authors-text = optional("authors-text", default: (size: 14pt))
    {
      set align(authors-align)
      set par(..authors-par)
      set block(..authors-block)
      block(text(..authors-text, auth-texts.join(join-script)))
    }

    // Affiliations
    let affiliation-numbering = optional("affiliation-numbering", default: "1.")
    let affiliation-join = optional("affiliation-join", default: "," + SPACE)
    let affiliation-align = optional("affiliation-align", default: center)
    let affiliation-par = optional("affiliation-par", default: (justify: false))
    let affiliation-block = optional("affiliation-block", default: (width: 85%))
    let affiliation-text = optional("affiliation-text", default: (size: 10pt, style: "italic"))

    let affil-texts = ()
    let affil-label = ""
    for i in range(affil-array.len()) {
      if affil-array.at(i) != none {
        affil-label = super(numbering(affiliation-numbering, i + 1) + GAP)
        affil-texts.push(affil-label + affil-array.at(i))
      }
    }

    {
      set align(affiliation-align)
      set par(..affiliation-par)
      set block(..affiliation-block)
      block(text(..affiliation-text, affil-texts.join(affiliation-join)))
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
    let date-align = optional("date-align", default: center)
    let date-par = optional("date-par", default: ())
    let date-block = optional("date-block", default: ())
    let date-text = optional("date-text", default: (size: 12pt))
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