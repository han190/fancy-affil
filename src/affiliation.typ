#let SPACE = " "

/*
Check if all elements in an array belong to one type.

Parameters
----------
array: an array

Return
------
consistent: bool
first-type: type
*/
#let is-consistent(array) = {
  let element-type = type(array.at(0))
  let consistent = true
  for element in array.slice(1) {
    if type(element) != element-type {
      consistent = false
      break
    }
  }
  (consistent, element-type) // Return
}

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
#let argument-type(authors) = {
  let arg-type = -1
  let type-table = (str: 0, dictionary: 1)
  if type(authors) == array {
    let (consistent, element-type) = is-consistent(authors)
    assert(
      consistent,
      message: "Inconsistent elements.",
    )
    assert(
      element-type in (str, dictionary),
      message: "Invalid elements.",
    )
    if element-type == str {
      arg-type = 0
    } else if element-type == dictionary {
      arg-type = 1
    }
  } else if type(authors) == str {
    arg-type = 2
  } else if type(authors) == dictionary {
    arg-type = 3
  }
  assert(
    arg-type != -1,
    message: "Invalid arguments.",
  )
  arg-type // Return
}

/* Find location of an element*/
#let findloc(array, element) = {
  let loc = array.position(x => { x == element })
  loc // Return
}

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
  indices // Return
}

/*
Join affiliation indices.
For example, [1, 2, 3, 5, 6, 7] -> "1-3,5-7".

Parameters
----------
indices: array of integers
format: numbering format

Return
------
results: string
*/
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
  results.join(",") // Return
}

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
emails: an array of strings
*/
#let parse-dict-arr(authors, authors-numbering) = {
  let (names, affils, affil-indices, emails, orcids) = ((), (), (), (), ())
  let orcid-domain = "https://orcid.org/"

  for author in authors {
    assert("name" in author, message: "Invalid author.")
    names.push(author.name)

    if not "email" in author {
      emails.push(none)
    } else if type(author.email) == str {
      emails.push(author.email)
    }

    if not "orcid" in author {
      orcids.push(none)
    } else if type(author.orcid) == str {
      if not orcid-domain in author.orcid {
        author.orcid = orcid-domain + author.orcid
      }
      orcids.push(author.orcid)
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

  // Assemble affiliation indices
  let temp = ()
  for i in range(names.len()) {
    if affil-indices.at(i) != none {
      temp.push(join-indices(affil-indices.at(i), authors-numbering))
    } else { temp.push(none) }
  }
  affil-indices = temp

  // The output is a dictionary where
  // each element is an array of strings.
  let output-dict = (
    "name": names,
    "affil-index": affil-indices,
    "email": emails,
    "orcid": orcids,
    "affil": affils,
  )
  output-dict // Return
}

/* Initialize optional argument with a default value */
#let optional-argument(parameters-dict, argument, default) = {
  let result = default
  if argument in parameters-dict {
    result = parameters-dict.at(argument)
  }
  result // Return
}

/* Default author function */
#let default-authors-func(authors-text) = {
  set align(center)
  block(text(size: 12pt, authors-text))
}

/* Default affiliation function */
#let default-affil-func(affil-text) = {
  set align(center)
  set par(justify: false)
  set block(width: 95%)
  block(text(size: 10pt, affil-text))
}

/*
Generate authors and affiliations based on authors' information.

Parameters
----------
authors: an array of string or dictionary
authors-join: (default: ", ") join script for authors
authors-numbering: (defualt: "1") authors numbering
authors-func: (default: default-authors-func) authors style function
affil-label-numbering: (default: "1.") affiliation numbering
affil-label-style: (default: ) affiliation label style
affil-join: (default: ", ") join script for affiliations
affil-func: (default: default-affil-func) affiliation style function
email-symbol: (default: "🖂") email symbol

Return
------
an array of two blocks: authors' block and affiliations' block.
*/
#let get-authors(authors, ..parameters) = {
  // Local constant and functions
  let GAP = h(1pt)
  let optional = optional-argument.with(parameters.named())

  let authors-type = argument-type(authors)
  assert(authors-type in (0, 1), message: "Invalid authors.")
  let authors-join = optional("authors-join", "," + SPACE)
  let authors-join-2 = optional("authors-join-2", SPACE + "and" + SPACE)
  let authors-func = optional("authors-func", default-authors-func)

  let authors-block = none
  let affiliations-block = none

  // If authors is an array of strings.
  if authors-type == 0 {
    // If there are only 2 authors use "and" otherwise use ",".
    if authors.len() == 2 { authors-join = authors-join-2 }
    authors-block = authors-func(authors.join(authors-join))
    // If authors is an array of dictionaries.
  } else if authors-type == 1 {
    let authors-numbering = optional("authors-numbering", "1")
    let authors-info = parse-dict-arr(authors, authors-numbering)

    // Deal with authors
    if authors-info.name.len() == 2 {
      authors-join = authors-join-2
      // If two authors share same affiliation combine them.
      if affil-indices.at(0) == affil-indices.at(1) { affil-indices.at(0) = none }
    }

    let orcid-logo-size = optional("orcid-logo-size", 9pt)
    let orcid-logo = box(image("../data/ORCID_iD.svg", height: orcid-logo-size))
    let email-symbol = optional("email-symbol", symbol("🖂"))

    let authors-order = optional("authors-order", ("name", "orcid", "email", "affil-index"))
    let name-style = optional("name-style", x => x)
    let orcid-style = optional("orcid-style", x => link(x, orcid-logo))
    let email-style = optional("email-style", x => link(x, email-symbol))
    let affil-indices-style = optional("affil-indices-style", x => super(x))
    let style-funcs = (
      name: name-style,
      orcid: orcid-style,
      email: email-style,
      affil-index: affil-indices-style,
    )
    let authors-box-join = optional("authors-box-join", GAP)

    let (current-box, current-boxes) = (none, none)
    let authors-boxes = ()
    for i in range(authors-info.name.len()) {
      current-boxes = ()
      for key in authors-order {
        current-box = authors-info.at(key).at(i)
        if current-box != none { current-boxes.push(style-funcs.at(key)(current-box)) }
      }
      authors-boxes.push(current-boxes.join(authors-box-join))
    }
    authors-block = authors-func(authors-boxes.join(authors-join))

    let affil-label-numbering = optional("affil-label-numbering", "1")
    let affil-label-style = optional("affil-label-style", x => super(x))
    let affil-style = optional("affil-style", x => x)

    let affil-join = optional("affil-join", "," + SPACE)
    let affil-box-join = optional("affil-box-join", GAP)
    let affil-func = optional("affil-func", default-affil-func)
    let affil-order = optional("affil-order", ("number", "affil"))

    let affil-boxes = ()
    let (affil-label, affil) = ("", "")
    for i in range(authors-info.affil.len()) {
      affil-label = affil-label-style(numbering(affil-label-numbering, i + 1))
      affil = affil-style(authors-info.affil.at(i))

      if affil-order == ("number", "affil") {
        current-boxes = (affil-label, affil)
      } else if affil-order == ("affil", "number") {
        current-boxes = (affil, affil-label)
      }
      affil-boxes.push(current-boxes.join(affil-box-join))
    }
    affiliations-block = affil-func(affil-boxes.join(affil-join))
  }
  (authors-block, affiliations-block) // Return
}
