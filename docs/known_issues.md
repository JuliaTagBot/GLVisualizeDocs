# Known Issues
Please refer to the [Github issues](https://github.com/JuliaGL/GLVisualize.jl/issues)

* It's known that the camera is a bit odd, fixing is high up on the priority list.

* Boundingboxes are not always correct
* On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on some tested machines (needed to checkout master and then rebuild)
* GLFW needs cmake and xorg-dev libglu1-mesa-dev on linux (can be installed via sudo apt-get install xorg-dev libglu1-mesa-dev).
* VideoIO and FreeType seem to be also problematic on some platforms. There isn't a fix for all situations. If these package fail, try Pk.update();Pkg.build("FailedPackage"). If this still fails, report an issue on Github!

