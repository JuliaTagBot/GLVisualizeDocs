# Arrows3d

<video  width="600" autoplay loop>
  <source src="../../media/arrows3d.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))
# let the visualization rotate later on
rotation = map(rotationmatrix_z, const_lift(*, timesignal, 2f0*pi))
# create some random 3D vectors
vectors3d = rand(Vec3f0, 5,5,5)
# this is not the best way to use 2D sprites, but this will space them on
# a 3D grid and use the rotation from `vectors3d` and the length of them
# to look up the a color from the optional keyword argument `color_map`.
arrows = visualize(('➤', vectors3d), scale=Vec2f0(0.1), model=rotation)

view(arrows, camera=:perspective)

renderloop(window)

```

# Arrows

<video  width="600" autoplay loop>
  <source src="../../media/arrows.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive

window = glscreen()
timesignal = bounce(linspace(0,1,360))
N = 20
# generate some rotations
function rotation_func(t)
    t = (t == 0f0 ? 0.01f0 : t)
    Vec2f0[(sin(x/t), cos(y/(t/2f0))) for x=1:N, y=1:N]
end

# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, timesignal)

# create a visualisation
vis = visualize(flow, ranges=(50:800,50:500))
view(vis, window, camera=:orthographic_pixel)

renderloop(window)

```

# Billboard

<video  width="600" autoplay loop>
  <source src="../../media/billboard.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, GLAbstraction, ModernGL, FileIO, Reactive

window = glscreen()
timesignal = loop(linspace(0f0, 1f0, 360))

let
rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

const b = Point3f0[(rand(Point3f0)*2)-1 for i=1:64]

sprites = visualize(
	(SimpleRectangle(0f0,0f0,0.5f0, 0.5f0), b),
	billboard=true, image=loadasset("doge.png"),
	model=rotation
)

view(sprites, window, camera=:perspective)
end

renderloop(window)

```

# Bouncy

<video  width="600" autoplay loop>
  <source src="../../media/bouncy.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, GLAbstraction
using Colors, Reactive, FileIO
window = glscreen()
timesignal = bounce(linspace(0,1,50))
n = 30
const border = 50f0
function bounce_particles(pos_velo, _)
    positions, velocity = pos_velo
    dt = 0.1f0
    @inbounds for i=1:length(positions)
        pos,velo = positions[i], velocity[i]
        positions[i] = Point2f0(pos[1], pos[2] + velo*dt)
        if pos[2] <= border
            velocity[i] = abs(velo)
        else
            velocity[i] = velo - 9.8*dt
        end
    end
    positions, velocity
end
start_position = (rand(Point2f0, n)*700f0) + border
position_velocity = foldp(bounce_particles,
    (start_position, zeros(Float32, n)),
    timesignal
)
circle = HyperSphere(Point2f0(0), 40f0)
vis = visualize((circle, map(first, position_velocity)),
    image=loadasset("doge.png"),
    stroke_width=3f0,
    stroke_color=RGBA{Float32}(0.91,0.91,0.91,1)
)
view(vis, window, camera=:orthographic_pixel)

renderloop(window)

```

# Distancefield

<video  width="600" autoplay loop>
  <source src="../../media/distancefield.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

window = glscreen()
timesignal = loop(linspace(0f0, 1f0, 360))
const n1 = 30
positions = rand(Point2f0, n1).*1000f0


xy_data(x,y,i) = Float32(sin(y/2f0/i)+cos(i*x))
const n2 = 128
# a distance field is a Matrix{Float32} array, which encodes the distance to
# the border of a filled shape. Positive numbers are inside the shape, 0 is the
# border and negative number are outside.
# this is basically how we render text, since you can do anti aliasing very
# nicely when you know the distance to the border.
# For text we use one big texture and specify uv coordinates into this big texture
# for every particle. How this is done can be seen in example
# partices/sprites/image_texture_atlas.jl

dfield = map(timesignal) do t
    tpi = (2pi*t)+0.2
    Float32[xy_data(x,y,tpi)+0.5f0 for x=1:n2, y=1:n2]
end
Base.rand(m::MersenneTwister, ::Type{U8}) = U8(rand(m, UInt8))
Base.rand{T <: Colorant}(m::MersenneTwister, ::Type{T}) = T(ntuple(x->rand(m, eltype(T)), Val{length(T)})...)

distfield = visualize((DISTANCEFIELD, positions),
    stroke_width=4f0,
    scale=Vec2f0(120),
    stroke_color=rand(RGBA{Float32}, n1),
    color=rand(RGBA{Float32}, n1),
    distancefield=dfield
)
view(distfield, window)


renderloop(window)

```

# Image Texture Atlas

<video  width="600" autoplay loop>
  <source src="../../media/image_texture_atlas.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

window = glscreen()
timesignal = loop(linspace(0f0, 1f0, 360))

# this is just one big texture
texture_atlas = loadasset("doge.png")
w, h = size(texture_atlas)
const n = 40
xrange = linspace(0, w, n)
yrange = linspace(0, h, n)
scale  = Vec2f0(step(xrange), step(yrange))

# position in a grid
positions = map(timesignal) do t
    vec(Point2f0[(x+(sin(t*2*pi)*400),y+(sin(0+y*t*0.01)*200)+(cos(t*2*pi)*200)) for x=xrange, y=yrange])
end

# uv coordinates are normalized coordinates into the texture_atlas
# they need the start point and the width of each rectangle (sprites are rectangles)
# so you will not actually index with the circle primitive, but rather with
# with the quad of the particle (the rest of the quad is transparent)
# note, that for uv coordinates, the origin is on the top left corner
uv_offset_width = vec(Vec4f0[(x,y,x+(1/n),y+(1/n)) for x=linspace(0, 1, n), y=linspace(1, 0, n)])

# when position and scale are defined, We can leave the middle and radius of
# Circle undefined, so just passing the type.
distfield = visualize((Circle, positions),
    scale=scale,
    stroke_width=1f0,
    uv_offset_width=uv_offset_width,
    stroke_color = RGBA{Float32}(0.9,0.9,0.9,1.0),
    image=texture_atlas
)
view(distfield, window)


renderloop(window)

```

# Letitsnow

<video  width="600" autoplay loop>
  <source src="../../media/letitsnow.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

window = glscreen()
timesignal = loop(linspace(0f0,1f0, 360))

const S = -5f0
const W = 10f0
const N = 1000
const ps = (rand(Point3f0, N)*W)+S
const velocity = rand(Vec3f0, N)*0.01f0
const gravity  = Vec3f0(0,0,-0.04)

upper_bound(x) = x>S+W
lower_bound(x) = x<S
function let_it_snow(position, t)
    @inbounds for i=1:length(ps)
        pos = Vec(position[i])
        p = Point3f0(pos+gravity+velocity[i])
        if any(upper_bound, p) || any(lower_bound, p)
            position[i] = Point3f0(rand(linspace(S,S+W, 1000)),rand(linspace(S,S+W, 1000)), S+W)
            velocity[i] = Vec3f0(0)
        else
            position[i] = p
        end
    end
    position
end
particles       = foldp(let_it_snow, ps, timesignal)
rotation 		= map(rotationmatrix_z, const_lift(*, timesignal, 2f0*pi))
color_ramp      = colormap("Blues", 50)
colors          = RGBA{Float32}[color_ramp[rand(1:50)] for i=1:N]

snowflakes = visualize(
    ('❄', particles),
    color=colors,
    scale=Vec2f0(0.6), billboard=true, model=rotation
)

view(snowflakes, window, camera=:perspective)


renderloop(window)

```

# Moving Bars

<video  width="600" autoplay loop>
  <source src="../../media/moving_bars.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, FileIO
using GLAbstraction, Colors, Reactive
window = glscreen()
timesignal = bounce(0f0:0.1:1f0)

primitive = SimpleRectangle(0f0,-0.5f0,1f0,1f0)
positions = rand(10f0:0.01f0:200f0, 10)

function interpolate(a, positions, t)
    [ae+((be-ae)*t) for (ae, be) in zip(a,positions)]
end
t = const_lift(*, timesignal, 10f0)
interpolated = foldp((positions,positions,positions), t) do v0_v1_ip, td
    v0,v1,ip = v0_v1_ip
    pol = td%1
    if isapprox(pol, 0.0)
        v0 = v1
        v1 = map(x-> rand(linspace(-50f0, 60f0, 100)), v0)
    end
    v0, v1, interpolate(v0, v1, pol)
end
b_sig = map(last, interpolated)
bars = visualize(
    (RECTANGLE, b_sig),
    intensity=b_sig,
    ranges=linspace(0,600, 10),
    color_norm=Vec2f0(-40,200),
    color_map=GLVisualize.default(Vector{RGBA})
)
view(bars, window, camera=:orthographic_pixel)

renderloop(window)

```

# Moving Circles

<video  width="600" autoplay loop>
  <source src="../../media/moving_circles.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, GLAbstraction
using Colors, Reactive, FileIO


window = glscreen()
timesignal = bounce(linspace(0f0,1f0,360))
t 		   = const_lift(*, timesignal, 10f0)
radius     = 200f0
w,h 	   = widths(window)
middle     = Point2f0(w/2, h/2)
circle_pos = Point2f0[(Point2f0(sin(i), cos(i))*radius)+middle for i=linspace(0, 2pi, 20)]
rotation   = Vec2f0[normalize(Vec2f0(middle)-Vec2f0(p)) for p in circle_pos]
scales     = map(t) do t
    Vec2f0[Vec2f0(30, ((sin(i+t)+1)/2)*60) for i=linspace(0, 2pi, 20)]
end

circles = visualize(
	(CIRCLE, circle_pos),
	rotation=rotation, scale=scales,
)

view(circles, window)

renderloop(window)

```

# Particles2D

<video  width="600" autoplay loop>
  <source src="../../media/particles2D.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction

window = glscreen()
timesignal = bounce(linspace(0,1,360))


function spiral(i, start_radius, offset)
	Point2f0(sin(i), cos(i)) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
particle_data2D(i, N) = Point2f0[spiral(i+x, 3, 10) for x=1:N]
# stretch time a bit:
t = const_lift(*, timesignal, 30f0)

# the simplest of all, plain 2D particles.
# to make it a little more interesting, we animate the particles a bit!
particles = const_lift(particle_data2D, t, 256)

# create a visualisation with each particle being 15px wide
# if you omit the primitive, it defaults to a SimpleRectangle
vis = visualize(particles, scale=Vec2f0(15))
view(vis, window, camera=:orthographic_pixel)

renderloop(window)

```

