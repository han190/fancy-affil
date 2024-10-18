#import "showdate.typ": showdate
#let SPACE = " "

/*
  # argument-type
  Check type of input argument.
  ## Parameters
  * argument: any
  ## Return
  * type-num: int

    The return value is
    * 0 if argument is an array of strings.
    * 1 if argument is an array of dictionaries.
    * 2 if argument is a string.
    * 3 if argument is a dictionary.
*/
#let argument-type(authors) = {
  let type-num = -1
  let assert-msg = "Invalid arguments."
  if type(authors) == array {
    let type-num0 = -1
    if type(authors.at(0)) == str {
      type-num0 = 0
    } else if type(authors.at(0)) == dictionary {
      type-num0 = 1
    }
    assert(type-num0 in (0, 1), message: assert-msg)

    for authors-element in authors {
      if type(authors-element) == str {
        type-num = 0
      } else if type(authors-element) == dictionary {
        type-num = 1
      } else {
        type-num = -1
      }
      assert(
        type-num0 == type-num,
        message: "Inconsistent element.",
      )
    }
  } else if type(authors) == str {
    type-num = 2
  } else if type(authors) == dictionary {
    type-num = 3
  }
  assert(type-num in (0, 1, 2, 3), message: assert-msg)
  type-num
}

/*
  # Find location
*/
#let findloc(array, element) = {
  let loc = array.position(x => {
    x == element
  })
  loc
}

/*
  # parse-dict-arr
  Parse authors, which is an array of dictionaries to 1. names of authors,
  2. names of affiliations, and 3. an array of integer arrays that represents
  the affiliation(s) of each author.
  ## Parameters
  * authors: an array of dictionaries.
  ## Return
  * names: an array of strings.
  * affils: an array of strings.
  * affil-indices: an array of integer arrays
*/
#let parse-dict-arr(authors) = {
  // Initialization
  let (names, affils, affil-indices, emails) = ((), (), (), ())

  for author in authors {
    assert("name" in author, message: "Invalid author.")
    names.push(author.name)

    if not "email" in author {
      emails.push(none)
    } else if type(author.email) == str {
      emails.push(author.email)
    } else {
      assert("Invalid email.")
    }

    if not "affiliation" in author {
      affil-indices.push(none)
      affils.push(none)
      continue
    }

    let affil-local = ()
    let affil-type = argument-type(author.affiliation)
    if affil-type == 0 {
      affil-local = author.affiliation
    } else if affil-type = 2 {
      affil-local.push(author.affiliation)
    } else {
      assert("Invalid affiliation.")
    }

    let indices = ()
    let loc = 0
    for affil in affil-local {
      loc = findloc(affils, affil)
      if loc != none {
        indices.push(loc + 1)
      } else {
        affils.push(affil)
        indices.push(affils.len())
      }
    }
    affil-indices.push(indices)
  }

  // Return
  (names, affils, affil-indices, emails)
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

  // Authors
  if authors != none {
    let authors-type = argument-type(authors)
    if authors-type == 0 {
      let authors-join = optional("authors-join", "," + SPACE)
      let authors-align = optional("authors-align", center)
      let authors-par = optional("authors-par", ())
      let authors-block = optional("authors-block", ())
      let authors-text = optional("authors-text", (size: 14pt))

      // If there are only 2 authors use "and" otherwise use ",".
      if authors.len() == 2 {
        authors-join = SPACE + "and" + SPACE
      }

      {
        set align(authors-align)
        set par(..authors-par)
        set block(..authors-block)
        block(text(..authors-text, authors.join(authors-join)))
      }
    } else if authors-type == 1 {
      // Authors
      let (names, affil-array, affil-indices, emails) = parse-dict-arr(authors)

      let authors-numbering = optional("authors-numbering", "1")
      let authors-join = optional("authors-join", "," + SPACE)
      let authors-align = optional("authors-align", center)
      let authors-par = optional("authors-par", ())
      let authors-block = optional("authors-block", ())
      let authors-text = optional("authors-text", (size: 14pt))

      // If there are only 2 authors use "and" otherwise use ",".
      if names.len() == 2 {
        authors-join = SPACE + "and" + SPACE
        // If two authors share same affiliation combine them.
        if affil-indices.at(0) == affil-indices.at(1) {
          affil-indices.at(0) = none
        }
      }

      let authors-strs = ()
      let indices-str = ""
      for i in range(names.len()) {
        if affil-indices.at(i) != none {
          indices-str = join-indices(affil-indices.at(i), authors-numbering)
          authors-strs.push(names.at(i) + super(GAP + indices-str))
        } else {
          authors-strs.push(names.at(i))
        }
      }

      {
        set align(authors-align)
        set par(..authors-par)
        set block(..authors-block)
        block(text(..authors-text, authors-strs.join(authors-join)))
      }

      // Affiliations
      let affil-label-numbering = optional("affil-label-numbering", "1.")
      let affil-label-style = optional("affil-label-style", x => super(emph(x)))
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
          affil-label = affil-label-style(numbering(affil-label-numbering, i + 1))
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
    } else {
      assert("Parameter \"Authors\" is" + "either an array of strings" + "or an array of dictionaries.")
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