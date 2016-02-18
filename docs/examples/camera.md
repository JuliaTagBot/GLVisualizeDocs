# Billiard

<video  width="600" autoplay loop><source src="../../media/billiard.webm"> Your browser does not support the video tag. </video>

```Julia
#=
For this example you need to checkout this package:
Pkg.clone("https://github.com/dpsanders/BilliardModels.jl")
Pkg.checkout("BilliardModels", "time_step")
=#
using GLAbstraction, MeshIO, Colors
using GLVisualize, GeometryTypes, Reactive, ColorTypes
window = glscreen()
const interactive_example = true

using BilliardModels

# create the billiard table
const table = Sinai_billiard(0.1)
const max_particles = 8_000

# function that steps through the simulation
function BilliardModels.step!(particles, table, _)
	for particle in particles
 		BilliardModels.step!(particle, table, 0.01)
 	end
 	particles
end

# convert a particle to a point
function to_points(data, particles)
	@inbounds for (i,p) in enumerate(particles)
		data[i] = to_points(p)
	end
	data
end
to_points(p::BilliardModels.Particle) = Point3f0(p.x.x*2pi, p.x.y*2pi, atan2(p.v.x, p.v.y))

# color lookup table
const colorramp = map(RGBA{Float32}, colormap("RdBu", 100))
function to_color(p::BilliardModels.Particle)
	l = (atan2(p.v.x, p.v.y) + pi) / 2pi
	colorramp[round(Int, clamp(l, 0, 1) * (length(colorramp)-1))+1]
end
function to_color(data, particles)
	@inbounds for (i,p) in enumerate(particles)
		data[i] = to_color(p)
	end
	data
end

cubecamera(window)

x0 				= Vector2D(0.3, 0.1)
particles 		= [BilliardModels.Particle(x0, Vector2D(1.0, 0.001*i)) for i=1:max_particles]
colors 			= RGBA{Float32}[RGBA{Float32}(1., 0.1, clamp(0.001*i, 0.0, 1.0), 1.0) for i=1:max_particles]
particle_stream = const_lift(BilliardModels.step!, particles, table, bounce(1:10))
v0              = map(to_points, particles)
vc0             = map(to_color, particles)
colors          = const_lift(to_color, vc0, particle_stream)
pointstream     = const_lift(to_points, v0, particle_stream)
primitive 	    = Circle(Point2f0(0), 0.05f0)

# we know that the particles will only be in this range
boundingbox     = AABB{Float32}(Vec3f0(-pi), Vec3f0(2pi))
particles = visualize(
	(primitive, pointstream),
    color=colors, # set color array. This is per particle
    billboard=true, # set billboard to true, making the particles always face the camera
    boundingbox=Signal(boundingbox) # set boundingbox, to avoid bb re-calculation when particles update( is expensive)
)

# visualize the boundingbox
boundingbox = visualize(boundingbox, :lines)
# view them (add them to the windows render list)
view(particles, window, camera=:perspective)
view(boundingbox, window, camera=:perspective)


renderloop(window)

```

# Camera2



```Julia
using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive

w = glscreen()

robj         = visualize(rand(Float32, 32,32), :surface)
bb           = boundingbox(robj).value
bb_width     = widths(bb)
lower_corner = minimum(bb)
middle       = lower_corner + (bb_width/2f0)
lookatvec    = Signal(Vec3f0(0))
eyeposition  = Signal(Vec3f0(2))

ideal_eyepos = middle + (norm(bb_width)*Vec3f0(2,0,2))


theta, translation = GLAbstraction.default_camera_control(
    w.inputs, Signal(0.1f0), Signal(0.01f0)
)
upvector     = Signal(Vec3f0(0,0,1))

cam = PerspectiveCamera(
    theta,
    translation,
    lookatvec,
    eyeposition,
    upvector,
    w.inputs[:window_area],

    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0) # Max distance (clip distance)
)

w.cameras[:my_cam] = cam

view(robj, camera=:my_cam)

@async renderloop(w)

```

# Camera

<video  width="600" autoplay loop><source src="../../media/camera.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive, GLWindow, Colors

window = glscreen()
timesignal = bounce(linspace(0f0,1f0,360))
const interactive_example = true

"""
functions to halve some rectangle
"""
xhalf(r)  = SimpleRectangle(r.x, r.y, r.w÷2, r.h)
xhalf2(r) = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)

"""
Makes a spiral
"""
function spiral(i, start_radius, offset)
	Point3f0(sin(i), cos(i), i/10f0) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
curve_data(i, N) = Point3f0[spiral(i+x/20f0, 1, (i/20)+1) for x=1:N]
# create a spiraling camera path
const camera_path  = curve_data(1f0, 360)

# create first screen for the camera
camera_screen = Screen(
	window, name=:camera_screen,
	area=const_lift(xhalf2, window.area)
)
# create second screen to view the scene
scene_screen = Screen(
	window, name=:scene_screen,
	area=const_lift(xhalf, window.area)
)

# create an camera eyeposition signal, which follows the path
eyeposition = map(timesignal) do t
    len = length(camera_path)
    index = round(Int, (t*(len-1))+1) # mod1, just to be on the save side
    Vec3f0(camera_path[index])
end

# create the camera lookat and up vector
lookatposition = Signal(Vec3f0(0))
upvector = Signal(Vec3f0(0,0,1))

# create a camera from these
cam = PerspectiveCamera(camera_screen.area, eyeposition, lookatposition, upvector)

"""
Simple visualization of a camera (this could be moved to GLVisualize)
"""
function GLVisualize.visualize(cam::PerspectiveCamera, style, keyword_args)
    lookvec, posvec, upvec = map(f->cam.(f), (:lookat, :eyeposition, :up))
    positions = map((a,b) -> Point3f0[a,b], lookvec, posvec)
    lines = map(lookvec, posvec, upvec) do l,p,u
        dir = p-l
        right = normalize(cross(dir,u))
        Point3f0[
            l,p,
            p, p+u,
            p, p+right
        ]
    end
    colors = RGBA{Float32}[
        RGBA{Float32}(1,0,0,1),
        RGBA{Float32}(1,0,0,1),

        RGBA{Float32}(0,1,0,1),
        RGBA{Float32}(0,1,0,1),

        RGBA{Float32}(0,0,1,1),
        RGBA{Float32}(0,0,1,1),
    ]
    poses = visualize((Sphere(Point3f0(0), 0.05f0), positions))
    lines = visualize(lines, :linesegment, color=colors)
    Context(poses, lines)
end

# add the camera to the camera screen as the perspective camera
camera_screen.cameras[:perspective] = cam

# something to look at
cat = visualize(GLNormalMesh(loadasset("cat.obj")))

# visualize the camera path
camera_points = visualize(
    (Circle(Point2f0(0), 0.03f0), camera_path),
    color=RGBA{Float32}((Vec3f0(0,206,209)/256)..., 1f0), billboard=true
)
camera_path_line = visualize(camera_path, :lines)

"""
Copy function for a context. We only need to copy the uniform dict
"""
function copy(c::GLAbstraction.Context)
    a = c.children[]
    uniforms = Dict{Symbol, Any}([k=>v for (k,v) in a.uniforms])
    robj = RenderObject(
        a.main,
        uniforms,
        a.vertexarray,
        a.prerenderfunctions,
        a.postrenderfunctions,
        a.id,
        a.boundingbox,
    )
    Context(robj)
end

# view everything on the appropriate screen.
# we need to copy the cat, because view inserts the camera into the
# actual render object. this is sub optimal and will get changed!
# Note, that this is a shallow copy, so the actual data won't be copied,
# just the data structure that holds the camera
view(copy(cat), camera_screen, camera=:perspective)

view(copy(cat), scene_screen, camera=:perspective)

view(visualize(cam), scene_screen, camera=:perspective)

view(camera_points, scene_screen, camera=:perspective)
view(camera_path_line, scene_screen, camera=:perspective)



renderloop(window)

```

