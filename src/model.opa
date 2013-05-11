module Model {

    private config = Config.config

    private function page_file_path(path, title) {
        [config.repo.path] ++ path ++ [title + config.page_extension]
        |> String.concat("/", _)
    }

    function option(page) read_page(path, title) {
        page_file_path(path, title)
        |> File.read_opt
        |> Option.map(function(file) {
            { ~path
            , ~title
            , metadata: config.default_metadata
            , content: string_of_binary(file)
            }
        }, _)
    }

    function write_page(_path, _title, _commit_msg) {
        error("not implemented")
    }

}
