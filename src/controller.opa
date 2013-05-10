module Controller {

    private config = Config.config

    function dispatch(url) {
        match(url) {
        case {path:["favicon.ico"] ...} :
            @static_resource("resources/favicon.ico")
        case {path:[] ...} :
            View.display(config, [], config.front_page)
        case {~path ...} :
            rev_path = List.rev(path)
            title = List.head(rev_path)
            path = List.rev(List.tail(rev_path))
            View.display(config, path, title)
        }
    }

}

resources = @static_resource_directory("resources")

Server.start(Server.http, [
    { register:
      [ { doctype: { html5 } },
        { css: [ "/resources/style.css"] }
      ]
    },
    { ~resources },
    { dispatch: Controller.dispatch}
])
