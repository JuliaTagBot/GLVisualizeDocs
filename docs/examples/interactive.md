# Color Edit



```Julia
# using GLVisualize, Colors, ModernGL, GeometryTypes, GLAbstraction, GLWindow, FileIO
# w = glscreen()
# v, colortex = vizzedit(map(RGBA{U8}, colormap("blues", 7)), w)

# function screen(robj, w)
# 	bb = boundingbox(robj)
# 	area = const_lift(bb) do b
# 		m = Vec{2,Int}(b.minimum)
# 		SimpleRectangle{Int}(m..., (Vec{2,Int}(b.maximum+30)-m)...)
# 	end
# 	s = Screen(w, area=area)
# 	transformation(robj, translationmatrix(Vec3f0(15,15,0)))
# 	view(robj, s, camera=:fixed_pixel)
# 	s
# end

# screen(v, w)
# view(visualize(rand(Float32, 28,92), color=colortex, color_norm=Vec2f0(0,1)))
# renderloop()

```

# Graph Editing

<video  width="600" autoplay loop>
  <source src="../../media/graph_editing.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GeometryTypes, GLVisualize, GLAbstraction, Reactive, GLWindow, GLFW

window = glscreen()

n = 50
n_connections = 100
a = rand(Point2f0, n)*1000f0
points = visualize((Circle(Point2f0(0), 15f0), a))

const point_robj = points.children[] # temporary way of getting the render object. Shouldn't stay like this
 # best way to get the gpu object. One could also start by creating a gpu array oneself.
 # this is a bit tricky, since not there are three different types.
 # for points and lines you need a GLBuffer. e.g gpu_position = GLBuffer(rand(Point2f0, 50)*1000f0)
const gpu_position = point_robj[:position]
# now the lines and points share the same gpu object
# for linesegments, you can pass indices, which needs to be of some 32bit int type
lines  = visualize(gpu_position, :linesegment, indices=rand(1:n, n_connections))

# current tuple of renderobject id and index into the gpu array
const m2id = GLWindow.mouse2id(window)
isoverpoint = const_lift(is_same_id, m2id, point_robj)

# inputs are a dict, materialize gets the keys out of it (equivalent to mouseposition = window.inputs[:mouseposition])
@materialize mouse_buttons_pressed, mouseposition = window.inputs

# single left mousekey pressed (while no other mouse key is pressed)
key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
# dragg while key_pressed. Drag only starts if isoverpoint is true
mousedragg  = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)

# use mousedrag and mouseid + index to actually change the gpu array with the positions
preserve(foldp((value(m2id)..., Point2f0(0)), mousedragg) do v0, dragg
    if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
        id, index = value(m2id)
        if id==point_robj.id && length(gpu_position) >= index
            p0 = gpu_position[index]
        else
            p0 = v0[3]
        end
    else
        id, index, p0 = v0
        if id==point_robj.id && length(gpu_position) >= index
            gpu_position[index] = Point2f0(p0) + Point2f0(dragg)
        end

    end
    return id, index, p0
end)
# view it!
view(lines, window, camera=:fixed_pixel)
view(points, window, camera=:fixed_pixel)

renderloop(window)

```

# Image Processing

<video  width="600" autoplay loop>
  <source src="../../media/image_processing.webm">
      Your browser does not support the video tag.
</video>


```Julia
using Images, Colors, GeometryTypes
using Reactive, FileIO, GLVisualize
using GLAbstraction, GeometryTypes, GLWindow

window = glscreen()

# loadasset loads data from the GLVisualize asset folder and is defined as
# FileIO.load(assetpath(name))
doge = loadasset("doge.png")
# Convert to RGBA{Float32}. Float for filtering and 32 because it fits the GPU better
img = map(RGBA{Float32}, doge)
# create a slider that goes from 1-20 in 0.1 steps
slider_s, slider = vizzedit(1f0:0.1f0:20f0, window)

# performant conversion to RGBAU8, implemted with a functor
# in 0.5 anonymous functions offer the same speed, so this wouldn't be needed
immutable ClampRGBAU8 end
call(::ClampRGBAU8, x) = RGBA{U8}(clamp(comp1(x), 0,1), clamp(comp2(x), 0,1), clamp(comp3(x), 0,1), clamp(alpha(x), 0,1))

"""
Applies a gaussian filter to `img` and converts it to RGBA{U8}
"""
function myfilter(img, sigma)
	img = Images.imfilter_gaussian(img, [sigma, sigma])
	map(ClampRGBAU8(), img).data
end


startvalue = myfilter(img, value(slider_s))
# Use Reactive.async_map, to filter the image without blocking the main process
task, imgsig = async_map(myfilter, startvalue, Signal(img), slider_s)
# visualize the image signal
image_renderable = visualize(imgsig, model=translationmatrix(Vec3f0(50,100,0)))
view(image_renderable)

vec2i(a,b,x...) = Vec{2,Int}(round(Int, a), round(Int, b))
vec2i(vec::Vec) = vec2i(vec...)
"""
creates a rectangle around `robj`
"""
function screen(robj)
	bb = value(boundingbox(robj))
	m  = vec2i(minimum(bb))
	area = SimpleRectangle{Float32}(0,0, ((vec2i(maximum(bb))-m)+30)...)

	view(visualize((area, [Point2f0(0)]),
        color=RGBA{Float32}(0,0,0,0), stroke_color=RGBA{Float32}(0,0,0,0.7),
        stroke_width=2f0),
        camera=:fixed_pixel
    )
	robj.children[][:model] = translationmatrix(Vec3f0(15,15,0)-minimum(bb))
	view(robj, camera=:fixed_pixel)
end
screen(slider)

renderloop(window)

```

# Mario Game

<video  width="600" autoplay loop>
  <source src="../../media/mario_game.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GeometryTypes, GLVisualize, GLAbstraction, ImageMagick
using FileIO, ColorTypes, Reactive

window = glscreen()

type Mario{T}
    x 			::T
    y 			::T
    vx 			::T
    vy 			::T
    direction 	::Symbol
end



gravity(dt, mario) = (mario.vy = (mario.y > 0.0 ? mario.vy - (dt/4.0) : 0.0); mario)

function physics(dt, mario)
    mario.x = mario.x + dt * mario.vx
    mario.y	= max(0.0, mario.y + dt * mario.vy)
    mario
end

function walk(keys, mario)
    mario.vx = keys[1]
    mario.direction = keys[1] < 0.0 ? :left : keys[1] > 0.0 ? :right : mario.direction
    mario
end

function jump(keys, mario)
    if keys[2] > 0.0 && mario.vy == 0.0
    	mario.vy = 6.0
    end
	mario
end

function update(dt, keys, mario)
    mario = gravity(dt, mario)
    mario = jump(keys, 	mario)
    mario = walk(keys, 	mario)
    mario = physics(dt, mario)
    mario
end



mario2model(mario) = translationmatrix(Vec3f0(mario.x, mario.y, 0f0))*scalematrix(Vec3f0(5f0))

const mario_images = Dict()


function play(x::Vector)
	const_lift(getindex, x, loop(1:length(x)))
end

function read_sequence(path)
    if isdir(path)
        return map(load, sort(map(x->joinpath(path, x), readdir(path))))
    else
        return fill(load(path), 1)
    end
end

for verb in ["jump", "walk", "stand"], dir in ["left", "right"]
    pic = dir
    if verb != "walk" # not a sequemce
        pic *= ".png"
    end
    path = assetpath("mario", verb, pic)
    sequence = read_sequence(path)
	gif = map(img->map(RGBA{U8}, img), sequence)
	mario_images[verb*dir] = play(gif)
end
function mario2image(mario, images=mario_images)
	verb = mario.y > 0.0 ? "jump" : mario.vx != 0.0 ? "walk" : "stand"
	mario_images[verb*string(mario.direction)].value # is a signal of pictures itself (animation), so .value samples the current image
end
function arrows2vec(direction)
	direction == :up 	&& return Vec2f0( 0.0,  1.0)
	direction == :down 	&& return Vec2f0( 0.0, -1.0)
	direction == :right && return Vec2f0( 3.0,  0.0)
	direction == :left 	&& return Vec2f0(-3.0,  0.0)
	Vec2f0(0.0)
end

# Put everything together
arrows 			= sampleon(bounce(1:10), window.inputs[:arrow_navigation])
keys 			= const_lift(arrows2vec, arrows)
mario_signal 	= const_lift(update, 8.0, keys, Mario(0.0, 0.0, 0.0, 0.0, :right))
image_stream 	= const_lift(mario2image, mario_signal)
modelmatrix 	= const_lift(mario2model, mario_signal)

mario = visualize(image_stream, model=modelmatrix)

view(mario, window, camera=:fixed_pixel)

renderloop(window)

```

