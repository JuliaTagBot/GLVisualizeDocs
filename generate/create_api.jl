using Lexicon, GLVisualize

const api_directory = "api" # where to put the API-docs, relative to this file.
const modules = [GLVisualize]

cd(dirname(@__FILE__)) do



    # Generate and save the contents of docstrings as markdown files.
    index  = Index()
    for mod in modules
        update!(index, save(joinpath(api_directory, "$(mod).md"), mod))
    end
    save(joinpath(api_directory, "index.md"), index; md_subheader = :category)

    # Add a reminder not to edit the generated files.
    open(joinpath(api_directory, "README.md"), "w") do f
        print(f, """
        Files in this directory are generated using the `build.jl` script. Make
        all changes to the originating docstrings/files rather than these ones.
        Documentation should *only* be built directly on the `master` branch.
        Source links would otherwise become unavailable should a branch be
        deleted from the `origin`. This means potential pull request authors
        *should not* run the build script when filing a PR.
        """)
    end

    info("Adding all documentation changes in $(api_directory) to this commit.")
    success(`git add $(api_directory)`) || exit(1)
end
