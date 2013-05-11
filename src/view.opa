module View {

    private function page_template(title, content) {
        html =
          <div class="navbar navbar-fixed-top">
            <div class=navbar-inner>
              <div class=container>
                <a class=brand href="/">Yixin</>
              </div>
            </div>
          </div>
          <div id=#main class=container-fluid>
            {content}
          </div>
        Resource.page(title, html)
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
            content = Markup.render(page.content)
            Xhtml.add_onready(function(_){include_page()}, content)
        }
    }

    private client function void include_page() {
        Dom.select_class(INCLUDE_PAGE) |> Dom.iter(
            function (dom dom) {
                Dom.remove_class(dom, INCLUDE_PAGE)
                page_path =
                    Dom.get_attribute(dom, INCLUDE_PAGE) |> Option.get
                page = get_wiki_page(page_path)
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
              <div class=container>
                <h1>{title}</h1>
                {Markup.render(page.content)}
              </div>
            content = Xhtml.add_onready(function(_){include_page()}, content)
            page_template(title, content)
        }
    }

}
