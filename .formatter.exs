# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,examples}/**/*.{ex,exs}"],
  line_length: 80,
  locals_without_parens: [
    let: :*,
    do_: :*
  ]
]
