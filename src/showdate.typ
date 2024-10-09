#let MONTHS = (
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
)

#let showdate(date, prefix: none, suffix: none, gap: 1pt, option: "US") = {
  let rem = calc.rem(date.day(), 10)

  let ordinal = ""
  if rem == 1 {
    ordinal = super("st")
  } else if rem == 2 {
    ordinal = super("nd")
  } else if rem == 3 {
    ordinal = super("rd")
  } else {
    ordinal = super("th")
  }

  let month = MONTHS.at(date.month() - 1)
  let day = str(date.day()) + h(gap) + ordinal
  let year = str(date.year())

  let texts = ()
  if option == "US" {
    texts = (month, day, year)
  } else if option == "EU" {
    texts = (day, month, year)
  }

  if prefix != none {
    texts.insert(0, prefix)
  }
  if suffix != none {
    texts.push(suffix)
  }
  [#texts.join(" ")]
}