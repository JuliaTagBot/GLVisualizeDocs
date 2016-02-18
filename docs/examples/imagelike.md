# Contourf

<video  width="600" autoplay loop><source src="../../media/contourf.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GeometryTypes

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

# use the performance tips to speed this up
# (http://docs.julialang.org/en/release-0.4/manual/performance-tips/)
# the array is 512x512 after all
const N = 512
const range = linspace(-5f0, 5f0, N)

function contour_inner(i, x, y)
    Intensity{1,Float32}(sin(1.3*x*i)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x))
end
const data = zeros(Intensity{1,Float32}, N, N)

function contourdata(t)
    for i=1:size(data, 1)
        @simd for j=1:size(data, 2)
            @inbounds data[i,j] = contour_inner(t, range[i], range[j])
        end
    end
    data
end

renderable = visualize(map(contourdata, timesignal))

view(renderable, window, camera=:orthographic_pixel)

renderloop(window)

```

# Imageio

<video  width="600" autoplay loop><source src="../../media/imageio.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
window = glscreen()

# a few helper functions to generate images
typealias NColor{N, T} Colorant{T, N}
fillcolor{T <: NColor{4}}(::Type{T}) = T(0,1,0,1)
fillcolor{T <: NColor{3}}(::Type{T}) = T(0,1,0)

# create different images with different color types (not an exhaustive list of supported types)
arrays = map((RGBA{U8}, RGBA{Float32}, RGB{U8}, RGB{Float32}, BGRA{U8}, BGR{Float32})) do C
     C[fillcolor(C) for x=1:45,y=1:45]
 end
# load a few images from the asset folder with FileIO.load (that's what loadasset calls)
loaded_imgs = map(x->loadasset("test_images", x), readdir(assetpath("test_images")))

# combine them all into one array and add an animated gif and a few other images
x = Any[
    arrays..., loaded_imgs...,
    loadasset("kittens-look.gif"),
    loadasset("mario", "stand", "right.png"),
    loadasset("mario", "jump", "left.gif"),
]

# visualize all images and convert the array to be a vector of element type context
# This shouldn't be necessary, but it seems map is not able to infer the type alone
images = convert(Vector{Context}, map(visualize, x))
# make it a grid
images = reshape(images, (4,4))
# GLVisualize offers a few helpers to visualize arrays of render objects
# spaced out as the underlying array. So this will create a grid whereas every
# item is 128x128x128 pixels big
img_vis = visualize(images, scale=Vec3f0(128))
view(img_vis, window)



renderloop(window)

```

# Parametric Fun

<video  width="600" autoplay loop><source src="../../media/parametric_fun.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GLAbstraction

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

# create a glsl fragment shader
parametric_func = frag"""
    uniform float arg1; // you can add arbitrary uniforms and supply them via the keyword args
    float function(float x) {
     return arg1*sin(1/tan(x));
   }
"""
# view the function on a 1700x800 pixel plane
paremetric = visualize(parametric_func, arg1=timesignal, dimensions=(1700, 800))
view(paremetric, window, camera=:orthographic_pixel)

renderloop(window)

```

