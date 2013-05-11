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

    private function xhtml get_wiki_page(config, page_path) {
        rev_page_path = page_path |> String.explode("/", _) |> List.rev
        title = List.head(rev_page_path)
        path = List.tail(rev_page_path) |> List.rev
        match(Model.read_page(config, path, title)) {
        case {none}:
            uri = Uri.of_string("/"+page_path) |> Option.get
            <p class=text-error>
               Page <a href={uri}>{page_path}</a> isn't created yet
            </p>
        case {some: page}:
            content = Markup.render(page.content)
            Xhtml.add_onready(function(_){include_page(config)}, content)
        }
    }

    private function void include_page(config) {
        Dom.select_class("yixin-include-page") |> Dom.iter(
            function (dom dom) {
                page_path =
                    Dom.get_attribute(dom, "yixin-include-page") |> Option.get
                page = get_wiki_page(config, page_path)
                Dom.set_html_unsafe(dom, Xhtml.to_string(page))
                Dom.remove_class(dom, "yixin-include-page")
            },
            _
        )
    }

    function display(config, path, title) {
        match(Model.read_page(config, path, title)) {
        case {none}:
            html = <>Page Not Found</>
            Resource.error_page(title, html, {wrong_address})
        case {some: page}:
            content =
              <div class=container>
                <h1>{title}</h1>
                {Markup.render(page.content)}
              </div>
            content = Xhtml.add_onready(function(_){include_page(config)}, content)
            page_template(title, content)
        }
    }

}
