private type json = RPC.Json.json0(json)
private type link = {json body, string href, string alt}

module Markup {

    private function json markdown_to_json(string markdown) {
        [ "pandoc"
        , "-f", "markdown"
        , "-t", "json"
        , "--smart"
        ]
        |> String.concat(" ", _)
        |> System.exec(_, markdown)
        |> Json.deserialize
        |> Option.get
    }

    private function xhtml json_to_html(json json) {
        [ "pandoc"
        , "-f", "json"
        , "-t", "html5"
        , "--mathml"
        ]
        |> String.concat(" ", _)
        |> System.exec(_, Json.serialize(json))
        |> Xhtml.of_string_unsafe
    }

    private function option(link) destruct_link(json json) {
        match(json) {
        case { Record:
               [ ("Link",
                 { List:
                   [ body,
                     { List: [
                         { String: href },
                         { String: alt }
                     ]}]})]
             }:
            Option.some(~{body, href, alt})
        default: Option.none
        }
    }

    private function json construct_link(link link) {
        { Record:
          [ ("Link",
            { List:
              [ link.body,
                { List: [
                    { String: link.href },
                    { String: link.alt }
                ]}]})]
        }
    }

    private function json apply_to_children(
        /* TODO: how to specify its type? */ f, json json
    ) {
        match(json) {
        case { List: children }:
            { List: List.map(f, children) }
        case { Record: children }:
            { Record: List.map(
                function((name, json)) {
                    (name, f(json))
                },
                children
            )}
        default: json
        }
    }

    private function json add_wiki_links(json json) {
        match(destruct_link(json)) {
        case { some:
               { body: ({ List: body_list } as body),
                 href: "",
                 alt: ""
               } }:
            /* FIXME: when the wiki link contains two or more consecutive spaces, we have no way to know */
            link = List.map(
                function(x){
                    match(x) {
                    case {Record: [("Str", {String: str})]}: str
                    case {String: "Space"}: " "
                    default: "" /* FIXME: log error */
                    }
                },
                body_list
            ) |> String.concat("", _)
            construct_link({~body, href:("/" + link), alt:""})
        default:
            apply_to_children(add_wiki_links, json)
        }
    }

    function xhtml render(string markdown) {
        markdown
        |> markdown_to_json
        |> add_wiki_links
        |> json_to_html
    }

}