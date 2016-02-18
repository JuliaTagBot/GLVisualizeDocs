# Performance tips for GLVisualize

GLVisualize doesn't optimize drawing many RenderObjects objects very well yet. We would need some better OpenGL draw call optimization for that.
So if you need to draw many objects, make sure that you use the particle system or merge meshes whenever possible.
For animations, make sure to pass a static boundingbox via the keyword arguments.

E.g:

Julia
visualize(x, boundingbox=nothing) # Or AABB{Float32}(Vec3f0(0),Vec3f0(0))
Otherwise the boundinbox will be calculated every time the signal updates which can be very expensive.

Here is a [blog post](http://randomfantasies.com/2015/05/glvisualize-benchmark/) about the performance of GLVisualize. It's a bit outdated but should still be accurate.
