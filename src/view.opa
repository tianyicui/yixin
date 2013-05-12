module View {

    private config = Config.config

    private function page_template(title, content) {
        html =
          <div class="navbar navbar-fixed-top">
            <div class=navbar-inner>
              <div class=container>
                <a class=brand href="/" alt="Powered by Yixin">{config.title}</>
              </div>
            </div>
          </div>
          <div id=#main class=container-fluid>
            {content}
          </div>
          Resource.page("{title} - {config.title}", html)
    }

    private exposed function xhtml get_wiki_page(page_path) {
        rev_page_path = page_path |> String.explode("/", _) |> List.rev
        title = List.head(rev_page_path)
        path = List.tail(rev_page_path) |> List.rev
        match(Model.read_page(path, title)) {
        case {none}:
            uri = Uri.of_string("/"+page_path) |> Option.get
            <p class=text-error>
               Page <a href={uri}>{page_path}</a> isn't created yet
            </p>
        case {some: page}:
            id = Dom.fresh_id()
            content =
              <div id={id}>{Markup.render(page.content)}</>
            Xhtml.add_onready(function(_){include_page(id)}, content)
        }
    }

    private client function void include_page(string id) {
        Dom.select_class(INCLUDE_PAGE) |>
        Dom.select_inside(#{id}, _) |> Dom.iter(
            function (dom dom) {
                Dom.remove_class(dom, INCLUDE_PAGE)
                page_path = Dom.get_attribute(dom, INCLUDE_PAGE) |> Option.get
                /* FIXME: It seems this call is not async */
                page = get_wiki_page(page_path)
                /* FIXME: There might be a better way than set_html_unsafe */
                Dom.set_html_unsafe(dom, Xhtml.to_string(page))
            },
            _
        )
    }

    function display(path, title) {
        match(Model.read_page(path, title)) {
        case {none}:
            html = <>Page Not Found</>
            Resource.error_page(title, html, {wrong_address})
        case {some: page}:
            content =
              <div id=#wiki-page class=container>
                <h1>{title}</h1>
                {Markup.render(page.content)}
              </div>
              content = Xhtml.add_onready(
                  function(_){include_page("wiki-page")},
                  content)
            page_template(title, content)
        }
    }

}
