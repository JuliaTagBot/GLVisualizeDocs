        ## This API documentation was generated automatically and is a work in progress.

        
## `sprites`
args: `(::Any, ::Any, ::Any)`

Main assemble functions for sprite particles. Sprites are anything like distance fields, images and simple geometries

---



## `projection_switch`
args: `(::Any, ::Any, ::Any)`

creates a button that can switch between orthographic and perspective projection

---



## `clicked`
args: `(::RenderObject, ::MouseButton, ::Screen)`

Returns two signals, one boolean signal if clicked over `robj` and another one that consists of the object clicked on and another argument indicating that it's the first click

---



## `to_indices`
args: `(::Union{Signal Int64})`

Converts index arrays to the OpenGL equivalent.

---

args: `(::Array)`

If already GLuint, we assume its 0 based (bad heuristic, should better be solved with some Index type)

---

args: `(::Array)`

For integers, we transform it to 0 based indices

---



## `cubecamera`
args: `(::Any)`

Creates a camera which is steered by a cube for `window`.

---



## `Grid`
args: `(::AbstractArray, ::Tuple)`

This constructor constructs a grid from ranges given as a tuple. Due to the approach, the tuple `ranges` can consist of NTuple(2, T) and all kind of range types. The constructor will make sure that all ranges match the size of the dimension of the array `a`.

---



## `is_hovering`
args: `(::RenderObject, ::Screen)`

Returns a boolean signal indicating if the mouse hovers over `robj`

---



## `play`
args: `(::Array, ::Integer, ::Integer)`

With play, you can slice a 3D array along `timedim` at time `t`. This can be used to treat a 3D array like a video and create an image stream from it.

---

args: `(::Image)`

Turns an Image into a video stream

---

args: `(::Array, ::Any, ::Any)`

Plays a video stream from VideoIO.jl. You need to supply the image `buffer`, which will be reused for better performance.

---



## `visualize`
args: `(::Tuple, ::Tuple)`

Creates a default visualization for any value. The defaults can be customized via the key word arguments and the style parameter. The style can change the the look completely (e.g points displayed as lines, or particles), while the key word arguments just alter the parameters of one visualization. Always returns a context, which can be displayed on a window via view(::Context, [display]).

---



## `meshparticle`
args: `(::Any, ::Any, ::Any)`

This is the main function to assemble particles with a GLNormalMesh as a primitive

---



## `dragged_on`
args: `(::RenderObject, ::MouseButton, ::Screen)`

Returns a signal with the difference from dragstart and current mouse position, and the index from the current ROBJ id.

---



## `_default`
args: `(::Union{Signal Array GPUArray}, ::Style, ::Dict)`

Vectors of n-dimensional points get ndimensional rectangles as default primitives. (Particles)

---

args: `(::Tuple, ::Style, ::Dict)`

Sprites primitives with a vector of floats are treated as something barplot like

---

args: `(::Tuple, ::Style, ::Dict)`

arrays of floats with any geometry primitive, will be spaced out on a grid defined by `ranges` and will use the floating points as the height for the primitives (`scale_z`)

---

args: `(::Union{Signal S}, ::Style, ::Dict)`

Transforms text into a particle system of sprites, by inferring the texture coordinates in the texture atlas, widths and positions of the characters.

---

args: `(::Union{Array Signal GPUArray}, ::Style, ::Dict)`

3D matrices of vectors are 3D vector field with a pyramid (arrow) like default primitive.

---

args: `(::Tuple, ::Style, ::Dict)`

Vectors with `Vec` as element type are treated as vectors of rotations. The position is assumed to be implicitely on the grid the vector defines (1D,2D,3D grid)

---

args: `(::Shader, ::Style, ::Dict)`

Takes a shader as a parametric function. The shader should contain a function stubb like this:

```GLSL
uniform float arg1; // you can add arbitrary uniforms and supply them via the keyword args
float function(float x) {
 return arg1*sin(1/tan(x));
}
```

---

args: `(::Union{Array GPUArray Signal}, ::Style, ::Dict)`

Float matrix with the style distancefield will be interpreted as a distancefield. A distancefield is describing a shape, with positive values denoting the inside of the shape, negative values the outside and 0 the border

---

args: `(::Image, ::Style, ::Dict)`

Takes a 3D image and decides if it is a volume or an animated Image.

---

args: `(::Union{Signal Array GPUArray}, ::Style, ::Dict)`

A matrix of Intensities will result in a contourf kind of plot

---

args: `(::Union{Array GPUArray Signal}, ::Style, ::Dict)`

Matrices of floats are represented as 3D barplots with cubes as primitive

---

args: `(::Union{G Signal}, ::Style, ::Dict)`

We plot simple Geometric primitives as particles with length one. At some point, this should all be appended to the same particle system to increase performance.

---

args: `(::Tuple, ::Style, ::Dict)`

arrays of floats with the sprite primitive type (2D geometry + picture like), will be spaced out on a grid defined by `ranges` and will use the floating points as the z position for the primitives.

---

args: `(::Union{GPUArray Array Signal}, ::Style, ::Dict)`

2D matrices of vectors are 2D vector field with a an unicode arrow as the default primitive.

---

args: `(::Union{GPUArray Signal Array}, ::Style, ::Dict)`

Vectors of floats are treated as barplots, so they get a HyperRectangle as default primitive.

---

args: `(::Union{Array GPUArray Signal}, ::Style, ::Dict)`

A matrix of colors is interpreted as an image

---

args: `(::Union{Array Signal GPUArray}, ::Style, ::Dict)`

This is the most primitive particle system, which uses simple points as primitives. This is supposed to be very fast!

---



