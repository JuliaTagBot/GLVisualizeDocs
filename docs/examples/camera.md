# Billiard

<video  width="600" autoplay loop>
  <source src="../../media/billiard.webm">
      Your browser does not support the video tag.
</video>


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



```Julia
# if !isdefined(:runtests)
# using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive
# w = glscreen()
# end

# mesh         = loadasset("cat.obj")
# robj         = visualize(mesh)
# bb           = boundingbox(robj).value
# bb_width     = widths(bb)
# lower_corner = minimum(bb)
# middle       = lower_corner + (bb_width/2f0)
# lookatvec    = minimum(bb)
# eyeposition  = middle + (bb_width.*Vec3f0(2,0,2))

# theta = map(every(0.1)) do _
#     Vec3f0(0,0.1,0) # add one degree on the camera y axis per 0.1 seconds
# end

# translation = Signal(Vec3f0(0))
# zoom 		= Signal(0f0)

# w.cameras[:my_cam] = PerspectiveCamera(
#     w.inputs[:window_area],
#     eyeposition,
#     lookatvec,
#     theta,
#     translation,
#     Signal(41f0), # Field of View
#     Signal(1f0),  # Min distance (clip distance)
#     Signal(100f0) # Max distance (clip distance)
# )


# view(robj, camera=:my_cam)
# if !isdefined(:runtests)
# renderloop(w)
# end

```

