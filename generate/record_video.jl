using GLVisualize

include(GLVisualize.dir("examples", "ExampleRunner.jl"))
using ExampleRunner
import ExampleRunner: flatten_paths
doc_root = Pkg.dir("GLVisualizeDocs", "docs")
screencapture_root = joinpath(doc_root, "media")

gui = readdir(GLVisualize.dir("examples", "gui"))
interactive = readdir(GLVisualize.dir("examples", "gui"))
files = vcat(
    map(x-> GLVisualize.dir("examples", "gui", x), gui),
    map(x-> GLVisualize.dir("examples", "interactive", x), interactive),
)

files = union(files, flatten_paths(GLVisualize.dir("examples")))
# Create an examplerunner, that displays all examples in the example folder, plus
# a runtest specific summary.
config = ExampleRunner.RunnerConfig(
    screencast_folder = screencapture_root,
    record = true,
    files = files,
    interactive_time = 3.0,
    number_of_frames = 360,
    resolution = (210, 210),
    thumbnail = false
)

ExampleRunner.run(config)

while isopen(window)
    if !isempty(Reactive.messages)
        poll_reactive()
        render(window)
    end
    yield()
end
# on the other side of the glvisualize universe

write_directly_to_gpu_mem()
Reactive.post_empty()# render frame, since it won't render without any event
