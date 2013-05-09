private module Pandoc {

    function xhtml markdown_to_xhtml(string markdown) {
        [ "pandoc"
        , "-f", "markdown"
        , "-t", "html5"
        , "--smart"
        , "--mathml"
        ]
        |> String.concat(" ", _)
        |> System.exec(_, markdown)
        |> Xhtml.of_string_unsafe
    }

}

module Markup {

    function xhtml render(string markdown) {
        Pandoc.markdown_to_xhtml(markdown)
    }

}