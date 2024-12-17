#let SPACE = " "
#let argument-type(authors) = {
  /*
    Check type of input argument.

    Parameters
    ----------
    argument: any

    Return
    ------
    type-num: int

    The return value is:
    0 if argument is an array of strings.
    1 if argument is an array of dictionaries.
    2 if argument is a string.
    3 if argument is a dictionary.
  */
  let type-num = -1
  if type(authors) == array {
    let type-num0 = -1
    if type(authors.at(0)) == str {
      type-num0 = 0
    } else if type(authors.at(0)) == dictionary {
      type-num0 = 1
    }
    assert(type-num0 in (0, 1), message: "Invalid arguments.")

    for authors-element in authors {
      if type(authors-element) == str {
        type-num = 0
      } else if type(authors-element) == dictionary {
        type-num = 1
      } else {
        type-num = -1
      }
      assert(type-num0 == type-num, message: "Inconsistent element.")
    }
  } else if type(authors) == str {
    type-num = 2
  } else if type(authors) == dictionary {
    type-num = 3
  }
  assert(
    type-num in (0, 1, 2, 3),
    message: "Invalid arguments. type-num=" + str(type-num),
  )
  type-num // Return
}

#let findloc(array, element) = {
  /* Find location of an element*/
  let loc = array.position(x => { x == element })
  loc // Return
}

#let parse-dict-arr(authors) = {
  /*
    Parse authors, which is an array of dictionaries to:
    1. Names of authors.
    2. Names of affiliations.
    3. An array of integer arrays that represents the affiliation(s)

    Parameters
    ----------
    authors: an array of dictionaries

    Return
    ------
    names: an array of strings
    affils: an array of strings
    affil-indices: an array of integer arrays
  */
  let (names, affils, affil-indices, emails) = ((), (), (), ())

  for author in authors {
    assert("name" in author, message: "Invalid author.")
    names.push(author.name)

    if not "email" in author {
      emails.push(none)
    } else if type(author.email) == str {
      emails.push(author.email)
    }

    if not "affiliation" in author {
      affil-indices.push(none)
      affils.push(none)
      continue
    }

    let affil-local = ()
    let affil-type = argument-type(author.affiliation)

    assert(affil-type in (0, 2), message: "Invalid affiliation.")
    if affil-type == 0 {
      affil-local = author.affiliation
    } else if affil-type = 2 {
      affil-local.push(author.affiliation)
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
  (names, affils, affil-indices, emails) // Return
}

#let push-indices(indices, start-end, format) = {
  /*
    Push indices (inner function of join-indices)
    Given an indices: [a0, a1, a2, a3, ..., an]
    Output a string:
    1. "a0,a1,a2,a3".
    2. "a0-an" if the array is consective.
    3. "a0" if the element is the same.

    Parameters
    ----------
    indices:
    start-end: 2-element array
    format: numbering format
  */
  let start-str = numbering(format, start-end.at(0))
  let end-str = numbering(format, start-end.at(1))

  if start-end.at(1) == start-end.at(0) {
    indices.push(start-str)
  } else if start-end.at(1) == start-end.at(0) + 1 {
    indices.push(start-str + "," + end-str)
  } else {
    indices.push(start-str + "-" + end-str)
  }
  indices // Return
}

#let join-indices(indices, format) = {
  /*
    Parameters
    ----------
    indices: array of integers
    format: numbering format

    Return
    ------
    results: string
  */
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
  results.join(",") // Return
}

#let optional-argument(parameters-dict, argument, default) = {
  /* Initialize optional argument with a default value */
  let result = default
  if argument in parameters-dict {
    result = parameters-dict.at(argument)
  }
  result // Return
}

#let default-authors-func(authors-text) = {
  /* Default author function */
  set align(center)
  block(text(size: 12pt, authors-text))
}

#let default-affil-func(affil-text) = {
  /* Default affiliation function */
  set align(center)
  set par(justify: false)
  set block(width: 85%)
  block(text(size: 10pt, style: "italic", affil-text))
}

#let get-affiliations(authors, ..parameters) = {
  /*
    Generate authors and affiliations based on authors' information.

    Parameters
    ----------
    authors: an array of string or dictionary
    authors-join: (optional, default: ", ") join script for authors
    authors-numbering: (optional, defualt: "1") authors numbering
    authors-func: (optional, default: default-authors-func) authors style function
    affil-label-numbering: (optional, default: "1.") affiliation numbering
    affil-label-style: (optional, default: ) affiliation label style
    affil-join: (optional, default: ", ") join script for affiliations
    affil-func: (optional, default: default-affil-func) affiliation style function

    Return
    ------
    an array of two blocks: authors' block and affiliations' block.
  */
  // Local constant and functions
  let GAP = h(1pt)
  let optional = optional-argument.with(parameters.named())

  let authors-type = argument-type(authors)
  assert(authors-type in (0, 1), message: "Invalid authors.")
  let authors-join = optional("authors-join", "," + SPACE)
  let authors-func = optional("authors-func", default-authors-func)

  let authors-block = none
  let affiliations-block = none

  // If authors is an array of strings.
  if authors-type == 0 {
    // If there are only 2 authors use "and" otherwise use ",".
    if authors.len() == 2 { authors-join = SPACE + "and" + SPACE }
    authors-block = authors-func(authors.join(authors-join))
    // If authors is an array of dictionaries.
  } else if authors-type == 1 {
    // Deal with authors
    let (names, affil-array, affil-indices, emails) = parse-dict-arr(authors)

    let authors-numbering = optional("authors-numbering", "1")
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
    authors-block = authors-func(authors-strs.join(authors-join))

    // Deal with affiliations
    let affil-label-numbering = optional("affil-label-numbering", "1.")
    let affil-label-style = optional("affil-label-style", x => super(emph(x)))
    let affil-join = optional("affil-join", "," + SPACE)
    // let affil-func = optional("affil-func", default-affil-func)

    let affil-strs = ()
    let affil-label = ""
    let affil-str = ""
    for i in range(affil-array.len()) {
      if affil-array.at(i) != none {
        affil-label = affil-label-style(numbering(affil-label-numbering, i + 1))
        affil-strs.push(affil-label + affil-array.at(i))
      }
    }
    affiliations-block = (affil-strs.join(affil-join))
  }
  (authors-block, affiliations-block) // Return
}