/* FIXME: these two imports are temporary hack */
import yixin.model
import yixin.config

private type json = RPC.Json.json0(json)
private type link = {json body, string href, string alt}

module Markup {

    private function json markdown_to_json(string markdown) {
        [ "pandoc"
        , "-f", "markdown"
        , "-t", "json"
        , "--smart"
        , "--base-header-level=2"
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

    private function option((link, string)) destruct_link(json json) {
        match(json) {
        case { Record:
               [ ("Link",
                 { List:
                   [ ({ List: body_list } as body),
                     { List: [
                         { String: href },
                         { String: alt }
                     ]}]})]
             }:
            /* FIXME: when the wiki link contains two or more consecutive spaces, we have no way to know */
            text = List.map(
                function(x){
                    match(x) {
                    case {Record: [("Str", {String: str})]}: str
                    case {String: "Space"}: " "
                    default: "" /* FIXME: log error */
                    }
                },
                body_list
            ) |> String.concat("", _)
            Option.some((~{body, href, alt}, text))
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

    private function json apply_to_children((json -> json) f, json json) {
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
        case { some: ({ ~body, href: "", alt: "" }, link_text) }:
            construct_link({~body, href:("/" + link_text), alt:""})
        default:
            apply_to_children(add_wiki_links, json)
        }
    }

    private function json subst_pages(json json) {
        match(destruct_link(json)) {
        case { some: ({ body:_, href: "!subst", alt: "" }, "") }:
            /* TODO: log error */
            error("what page to substitute with?")
        case { some: ({ ~body, href: "!subst", alt: "" }, link_text) }:
            rev_page_path = link_text |> String.explode("/", _) |> List.rev
            title = List.head(rev_page_path)
            path = List.tail(rev_page_path) |> List.rev
            match(Model.read_page(Config.config, path, title)) {
            case {none}:
                construct_link({~body, href:("/" + link_text), alt:"!subst"})
            case {some: page}:
                html = page.content |> render |> Xhtml.to_string
                { Record: [("RawInline",
                            {List: [
                                {String: "html"},
                                {String: html}
                            ]}
                           )]}
            }
        default:
            apply_to_children(subst_pages, json)
        }
    }

    private function json json_passes(json json) {
        json |> add_wiki_links |> subst_pages
    }

    function xhtml render(string markdown) {
        markdown
        |> markdown_to_json
        |> json_passes
        |> json_to_html
    }

}