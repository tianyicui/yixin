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
        path = path ++ [title + config.page_extension]
        Git.read_file(config.repo, path)
    }

    function write_page(config, path, title, commit_msg) {
        path = path ++ [title + config.page_extension]
        Git.write_file(config.repo, path, commit_msg)
    }

}
