type repo = { string path }

type page =
    { list(string) path
    , string title
    , metadata metadata
    , string content
    }

type metadata = void

type config =
    { string title
    , repo repo
    , string front_page
    , string page_extension
    , metadata default_metadata
    }
