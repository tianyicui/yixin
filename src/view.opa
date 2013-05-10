module View {

    function page_template(title, content) {
        html =
          <div class="navbar navbar-fixed-top">
            <div class=navbar-inner>
              <div class=container>
                <a class=brand href="./index.html">yixin</>
              </div>
            </div>
          </div>
          <div id=#main class=container-fluid>
            {content}
          </div>
        Resource.page(title, html)
    }

    function display(config, path, title) {
        match(Model.read_page(config, path, title)) {
        case {none}:
            html = <>Page Not Found</>
            Resource.error_page(title, html, {wrong_address})
        case {some: page}:
            page_template(title, Markup.render(page.content))
        }
    }

}
