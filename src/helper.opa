module Helper {

    private function string escape_for_shell(string string) {
        string
        |> String.replace("\\", "\\\\", _)
        |> String.replace("'", "\\'", _)
        |> function(s) { "'{s}'" }
    }

    function string exec(list(string) command_line, string stdin) {
        command_line
        |> List.map(escape_for_shell, _)
        |> String.concat(" ", _)
        |> System.exec(_, stdin)
    }

}