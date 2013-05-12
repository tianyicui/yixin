module Model {

    private config = Config.config

    private function string page_file_path(list(string) path, string title) {
        [config.repo.path] ++ path ++ [title + config.page_extension]
        |> String.concat("/", _)
    }

    function option(page) read_page(list(string) path, string title) {
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

    private function void exec_git(list(string) arguments) {
        [ "--git-dir={config.repo.path}/.git"
        , "--work-tree={config.repo.path}"
        | arguments
        ]
        |> Helper.exec("git", _, "")
        |> ignore /* FIXME: shouldn't ignore, but how to detect error? */
    }

    function void write_page(page page, string commit_msg) {
        commit_msg = if(String.is_empty(commit_msg)) {
            "update {page.title} via Yixin"
        }
        else {
            commit_msg
        }
        path = page_file_path(page.path, page.title)
        File.write(path, binary_of_string(page.content))
        exec_git(["commit", "-m", commit_msg, "--", path])
    }

}
