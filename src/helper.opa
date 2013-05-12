module Helper {

    private function string escape_for_shell(string string) {
        string
        |> String.replace("\\", "\\\\", _)
        |> String.replace("'", "\\'", _)
        |> function(s) { "'{s}'" }
    }

    function string exec(string executable, list(string) arguments, string stdin) {
        [ executable | arguments ]
        |> List.map(escape_for_shell, _)
        |> String.concat(" ", _)
        |> System.exec(_, stdin)
    }

}