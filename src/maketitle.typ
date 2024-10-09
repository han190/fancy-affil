#import "showdate.typ": showdate
#let SPACE = " "

#let parse-authors(authors: ()) = {
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

#let push-indices(indices: (), start: 0, end: 0) = {
  if start == end {
    indices.push(str(start))
  } else if end == start + 1 {
    indices.push(str(start) + "," + str(end))
  } else {
    indices.push(str(start) + "-" + str(end))
  }
  // Return
  indices
}

#let join-indices(indices: ()) = {
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
      )
      (start, end) = (indices.at(i), indices.at(i))
    }
  }

  // Concatenate the last pair
  indices-strings = push-indices(
    indices: indices-strings,
    start: start,
    end: end,
  )
  // Return
  indices-strings.join(",")
}

#let maketitle(
  title: none,
  authors: (),
  date: none,
  abstract: none,
  keywords: none,
  title-txt-paras: (size: 18pt, weight: "bold"),
  title-par-paras: (leading: 0.5em),
  title-blk-paras: (),
  title-aln-para: center,
  authors-txt-paras: (size: 14pt),
  authors-par-paras: (),
  authors-blk-paras: (),
  authors-aln-para: center,
  affil-txt-paras: (size: 10pt, style: "italic"),
  affil-par-paras: (),
  affil-blk-paras: (),
  affil-aln-para: center,
  date-txt-paras: (size: 12pt),
  date-par-paras: (),
  date-blk-paras: (),
  date-aln-para: center,
  body,
) = {
  // Local constant
  let GAP = h(1pt)
  // Title
  assert(title != none, message: "Invalid title.")
  {
    set align(title-aln-para)
    set par(..title-par-paras)
    block(..title-blk-paras, text(..title-txt-paras, title))
  }

  // Authors and affiliations
  if authors.len() >= 1 {
    let (names, affil-array, affil-indices) = parse-authors(authors: authors)
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

    for i in range(names.len()) {
      let auth = names.at(i)
      if affil-indices.at(i) != none {
        let indices = join-indices(indices: affil-indices.at(i))
        auth-texts.push(auth + super(GAP + indices))
      } else {
        auth-texts.push(auth)
      }
    }

    // Author block
    let authors-text = auth-texts.join(join-script)
    {
      set align(authors-aln-para)
      set par(..authors-par-paras)
      block(..authors-blk-paras, text(..authors-txt-paras, authors-text))
    }

    let affil-texts = ()
    for i in range(affil-array.len()) {
      if affil-array.at(i) != none {
        let affil = affil-array.at(i)
        affil-texts.push(super(str(i + 1) + GAP) + affil)
      }
    }

    // Affiliation block
    let affil-text = affil-texts.join("," + SPACE)
    {
      set align(affil-aln-para)
      set par(..affil-par-paras)
      block(..affil-blk-paras, text(..affil-txt-paras, affil-text))
    }
  }

  // Date
  if date != none {
    let date-text = ""
    if type(date) == dictionary {
      if "option" in date {
        let _date = date.remove("date")
        date-text = showdate(_date, ..date)
      } else {
        date-text = showdate(date.date)
      }
    } else if type(date) == datetime {
      date-text = showdate(date)
    } else if type(date) == str {
      date-text = date
    } else {
      assert("Invalid datetime.")
    }

    // Date block
    {
      set align(date-aln-para)
      set par(..date-par-paras)
      block(..date-blk-paras, text(..date-txt-paras, date-text))
    }
  }

  // Return
  [#body]
}