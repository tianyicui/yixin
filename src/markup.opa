private type json = RPC.Json.json0(json)
private type link = {json body, string href, string alt}

module Markup {

    private exec_pandoc = Helper.exec("pandoc", _, _)

    private function json markdown_to_json(string markdown) {
        [ "-f", "markdown+autolink_bare_uris"
        , "-t", "json"
        , "--smart"
        , "--base-header-level=2"
        ]
        |> exec_pandoc(_, markdown)
        |> Json.deserialize
        |> Option.get
    }

    private function xhtml json_to_html(json json) {
        [ "-f", "json"
        , "-t", "html5"
        , "--mathml"
        , "--no-wrap"
        ]
        |> exec_pandoc( _, Json.serialize(json))
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

    private function option(json) add_wiki_links(json json) {
        match(destruct_link(json)) {
        case { some: ({ ~body, href: "", ~alt }, link_text) }:
            href = "/" + link_text
            {some: construct_link(~{body, href, alt})}
        default:
            {none}
        }
    }

    private function option(json) include_pages(json json) {
        match(destruct_link(json)) {
        case { some: ({ body:_, href: "!subst", alt: "" }, "") }:
            {none}
        case { some: ({ body:_, href: "!subst", alt: "" }, link_text) }:
            html =
              <div class={[INCLUDE_PAGE]}>
                <p class=text-info>Loading {link_text}...</p>
              </div>
              |> Xhtml.add_attribute_unsafe(INCLUDE_PAGE, link_text, _)
            {some: {Record:
                    [("RawInline",
                      {List: [
                          {String: "html"},
                          {String: html |> Xhtml.to_string}
                      ]}
                     )]}
            }
        default:
            {none}
        }
    }

    private function json json_passes(json json) {
        recursive function json apply_to_children(f, json) {
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
        all_passes = [add_wiki_links, include_pages]
        recursive function json do_json_passes(json, passes) {
            match(passes) {
            case []: apply_to_children(do_json_passes(_, all_passes), json)
            case [f | fs]:
                match(f(json)) {
                case {none}: do_json_passes(json, fs)
                case {some: json}: do_json_passes(json, all_passes)
                }
            }
        }
        do_json_passes(json, all_passes)
    }

    function xhtml render(string markdown) {
        markdown
        |> markdown_to_json
        |> json_passes
        |> json_to_html
    }

}
