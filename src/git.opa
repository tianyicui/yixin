type repo = { string path }

private type Repo.t = repo

private module Repo {

    function exec(Repo.t t, command, args, input) {
        error("not implemented")
    }

    function Commit.t head(Repo.t t) {
        error("not implemented")
    }

    function Tree.t tree(Repo.t t) {
        Commit.tree(head(t))
    }

}

private type Commit.t = { Repo.t repo, string commit }

private module Commit {

    function tree(Commit.t t) {
        error("not implemented")
    }

}

private type Tree.t = { Repo.t repo, string tree }

private type entry = {Tree.t tree} or {Blob.t blob}

private module Tree {

    function list(entry) entries(Tree.t t) {
        error("not implemented")
    }

}

private type Blob.t = { Repo.t repo, string blob }

private module Blob {

    function string content(Blob.t t) {
        error("not implemented")
    }

}

module Git {

    function string read_file(repo repo, list(string) path) {
        /* mocked */
        path = String.concat("/", [repo.path | path])
        File.read(path) |> string_of_binary
    }

    function write_file(repo repo, list(string) path, string commit_msg) {
        error("not implemented")
    }

}