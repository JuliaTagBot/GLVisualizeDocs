# Contourlines

<video  width="600" autoplay loop>
  <source src="../../media/contourlines.webm">
      Your browser does not support the video tag.
</video>


```Julia
using Contour, GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

window = glscreen()
timesignal = bounce(linspace(0.0, 1.0, 360))
# create a rotation from the time signal
rotation = map(timesignal) do t
    rotationmatrix_z(Float32(t*2pi)) # -> 4x4 Float32 rotation matrix
end

xrange = -5f0:0.02f0:5f0
yrange = -5f0:0.02f0:5f0

z = Float32[sin(1.3*x)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x) for x in xrange, y in yrange]
mini = minimum(z)
maxi = maximum(z)
color_ramp = map(x->RGBA{Float32}(x, 1.0), colormap("Blues"))
height2color(val, mini, maxi) = color_ramp[floor(Int, (((val-mini)/(maxi-mini))*(length(color_ramp)-1)))+1]

for h in mini:0.2f0:maxi
    c = contour(xrange, yrange, z, h)
    for elem in c.lines
        points = map(elem.vertices) do p
            Point3f0(p, h)
        end
        line_renderable = visualize(
            points, :lines,
            color=height2color(h, mini, maxi),
            model=rotation
        )
        view(line_renderable, window, camera=:perspective)
    end
end

renderloop(window)

```

# Lines2D

<video  width="600" autoplay loop>
  <source src="../../media/lines2D.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, GLAbstraction, Colors

window = glscreen()
timesignal = bounce(linspace(0.0, 1.0, 360))
const N = 2048
function spiral(i, start_radius, offset)
	Point2f0(sin(i), cos(i)) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
curve_data(i, N) = Point2f0[spiral(i+x/20f0, 1, (i/20)+1) for x=1:N]

t = const_lift(x-> (1f0-x)*100f0, timesignal)
color = map(RGBA{Float32}, colormap("Blues", N))
view(visualize(const_lift(curve_data, t, N), :lines, color=color))


renderloop(window)

```

# Lines3D

<video  width="600" autoplay loop>
  <source src="../../media/lines3D.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive

window = glscreen()
timesignal = bounce(linspace(0.0, 1.0, 360))

n = 400 # The number of points per line
nloops = 20 # The number of loops
# The scalar parameter for each line
TL = linspace(-2f0 * pi, 2f0 * pi, n)
# We create a list of positions and connections, each describing a line.
# We will collapse them in one array before plotting.
xyz    = Point3f0[]
colors = RGBA{Float32}[]

# creates some distinguishable colors from which we can sample for each line
base_colors1 = distinguishable_colors(nloops, RGB{Float64}(1,0,0))
# Create each line one after the other in a loop
for i=1:nloops
    append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .03 * i) * t)) for t in TL])
    unique_colors = base_colors1[i]
    hsv = HSV(unique_colors)
    color_palette = map(x->RGBA{Float32}(x, 1.0), sequential_palette(hsv.h, n, s=hsv.s))
    append!(colors, color_palette)
end

# map comes from Reactive.jl and allows you to map any Signal to another.
# In this case we create a rotation matrix from the timesignal signal.

rotation = map(timesignal) do t
    rotationmatrix_z(Float32(t*2pi)) # -> 4x4 Float32 rotation matrix
end

lines3d = visualize(xyz, :lines, color=colors, model=rotation)

view(lines3d, window, camera=:perspective)

renderloop(window)

```

# Linesegments3d

<video  width="600" autoplay loop>
  <source src="../../media/linesegments3d.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Colors
using Reactive, GLAbstraction

window = glscreen()
timesignal = loop(linspace(0f0, 1f0, 360))

large_sphere = HyperSphere(Point3f0(0), 1f0)
rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

positions = decompose(Point3f0, large_sphere)
indices = rand(range(Cuint(0), Cuint(length(positions))), 1000)

color = map(large_sphere->RGBA{Float32}(large_sphere, 0.9f0), colormap("Blues", length(positions)))
color2 = map(large_sphere->RGBA{Float32}(large_sphere, 1f0), colormap("Blues", length(positions)))

lines = visualize(
	positions, :linesegment, thickness=0.5f0,
	color=color, indices=indices, model=rotation
)
spheres = visualize(
	(Sphere{Float32}(Point3f0(0.0), 1f0), positions),
	color=color2, scale=Vec3f0(0.05), model=rotation
)
view(lines, window, camera=:perspective)
view(spheres, window, camera=:perspective)


renderloop(window)

```

