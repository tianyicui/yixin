type config =
    { string title
    , repo repo
    , string front_page
    , string page_extension
    }

type page =
    { list(string) path
    , string title
    , metadata metadata
    , string content
    }

type metadata = void

module Model {

    function read_page(config, path, title) {
        error("not implemented")
    }

    function write_page(config, path, title, commit_msg) {
        error("not implemented")
    }

}
