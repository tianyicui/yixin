type repo = { string path }

type config =
    { string title
    , repo repo
    , string front_page
    , string page_extension
    , metadata default_metadata
    }

type page =
    { list(string) path
    , string title
    , metadata metadata
    , string content
    }

type metadata = void

module Model {

    private function page_file_path(config, path, title) {
        [config.repo.path] ++ path ++ [title + config.page_extension]
        |> String.concat("/", _)
    }

    function read_page(config, path, title) {
        filepath = page_file_path(config, path, title)
        content = File.read(filepath) |> string_of_binary
        metadata = config.default_metadata
        ~{ path, title, metadata, content }
    }

    function write_page(config, path, title, commit_msg) {
        error("not implemented")
    }

}
