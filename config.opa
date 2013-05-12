import-plugin unix

module Config {

    private env = %%BslSys.get_env_var%%

    config config =
        { title: "MindRepoNG"
        , repo : { path: (env("HOME") |> Option.get) + "/mindrepo" }
        , front_page: "Front Page"
        , page_extension: ".page"
        , default_metadata: void
        }

}