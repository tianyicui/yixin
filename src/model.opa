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

    function option(page) read_page(config, path, title) {
        page_file_path(config, path, title)
        |> File.read_opt
        |> Option.map(function(file) {
            { ~path
            , ~title
            , metadata: config.default_metadata
            , content: string_of_binary(file)
            }
        }, _)
    }

    function write_page(config, path, title, commit_msg) {
        error("not implemented")
    }

}
