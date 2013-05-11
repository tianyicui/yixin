module View {

    function page_template(title, content) {
        html =
          <div class="navbar navbar-fixed-top">
            <div class=navbar-inner>
              <div class=container>
                <a class=brand href="/">Yixin</>
              </div>
            </div>
          </div>
          <div id=#main class=container-fluid>
            <div class=container>
              {content}
            </div>
          </div>
        Resource.page(title, html)
    }

    function display(config, path, title) {
        match(Model.read_page(config, path, title)) {
        case {none}:
            html = <>Page Not Found</>
            Resource.error_page(title, html, {wrong_address})
        case {some: page}:
            content = <h1>{title}</h1> <+> Markup.render(page.content)
            page_template(title, content)
        }
    }

}
