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

    private exposed function xhtml html_of_page(page page){
        container_id = Dom.fresh_id()
        content_id = Dom.fresh_id()
        editor_id = Dom.fresh_id()
        textarea_id = Dom.fresh_id()
        commit_msg_id = Dom.fresh_id()

        function void edit_page(_) {
            Dom.set_value(#{textarea_id}, page.content)
            Dom.get_width(#{content_id})
                |> Dom.set_width(#{editor_id}, _)
            min(Dom.get_height(#{content_id}), 1200)
                |> Dom.set_height(#{textarea_id}, _)
            Dom.hide(#{content_id})
            Dom.show(#{editor_id})
            Dom.give_focus(#{textarea_id})
        }

        function void save_page(_) {
            content = Dom.get_value(#{textarea_id})
            if(String.equals(content, page.content)) {
                Dom.hide(#{editor_id})
                Dom.show(#{content_id})
            } else {
                page = { page with ~content }
                commit_msg = Dom.get_value(#{commit_msg_id})
                Model.write_page(page, commit_msg)
                /* FIXME: temporary hack because I don't know how to
                          replace DOM elements...
                 */
                Client.do_reload(true)
            }
        }

        /* TODO: use widgets in stdlib for hintint and other improvement */
        Xhtml.add_onready(
            function(_){include_pages(content_id)},
            <div id={container_id}>
              <div id={content_id}
                   ondblclick={edit_page}
                   options:ondblclick="stop_propagation" >
                {Markup.render(page.content)}
              </>
              <form id={editor_id} onsubmit={save_page} hidden>
                <textarea id={textarea_id} width="100%" />
                <input type=text id={commit_msg_id} style="width:100%" />
              </>
            </div>
        )
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
            html_of_page(page)
        }
    }

    private client function void include_pages(string id) {
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
                {html_of_page(page)}
              </div>
            page_template(title, content)
        }
    }

}
