# Performance tips for GLVisualize

GLVisualize doesn't optimize drawing many RenderObjects objects well yet.
Better OpenGL draw call optimization would be needed for that.
So if you need to draw many objects, make sure that you use the particle system or merge meshes whenever possible.

For animations, make sure to pass a static boundingbox via the keyword arguments.

E.g:
```Julia
visualize(x, boundingbox=nothing) # Or AABB{Float32}(Vec3f0(0),Vec3f0(0))
```
Otherwise the boundinbox will be calculated every time the signal updates which can be very expensive.


If you want to find out a bit more about the genral performance of GLVisualize, you can
read this [blog post](http://randomfantasies.com/2015/05/glvisualize-benchmark/).
It's a bit outdated but should still be accurate.

