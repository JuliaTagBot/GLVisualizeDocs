# Bars

<video  width="600" autoplay loop>
  <source src="../../media/bars.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, Colors, GeometryTypes, GLAbstraction, Reactive

window = glscreen()
 timesignal = loop(linspace(0f0, 1f0, 360))
const N = 87
const range = linspace(-5f0, 5f0, N)

function contour_inner(i, x, y)
    Float32(sin(1.3*x*i)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x))
end
const data = zeros(Float32, N, N)

function contourdata(t)
    for i=1:size(data, 1)
        @simd for j=1:size(data, 2)
            @inbounds data[i,j] = contour_inner(t, range[i], range[j])
        end
    end
    data
end

heightfield = map(contourdata, timesignal)
mini = Vec3f0(first(range), first(range), minimum(value(heightfield)))
maxi = Vec3f0(last(range), last(range), maximum(value(heightfield)))
barsvis = visualize(
    heightfield,
    scale_x = 0.07,
    scale_y = 0.07,
    color_map=map(RGBA{U8}, colormap("Blues")),
    color_norm=Vec2f0(0,1),
    ranges=(range, range),
    boundingbox=Signal(AABB{Float32}(mini, maxi))
)
view(barsvis, window)

renderloop(window)

```

# Cubicles

<video  width="600" autoplay loop>
  <source src="../../media/cubicles.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, FileIO
using GLAbstraction, Colors, Reactive

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

cube = HyperRectangle(Vec3f0(0), Vec3f0(0.05))
n = 20
const wx,wy,wz = widths(cube)

mesh = GLNormalMesh(cube)

timepi = const_lift(*, timesignal, 2f0*pi)
function position(t, x, y)
    pos = Point3f0(x*(sqrt(wx^2+wy^2)), -y*wy, y*wz)
    dir = Point3f0(0, wy, wz)
    pos = pos + sin(t)*dir
end
position_signal = map(timepi) do t
    vec(Point3f0[position(t,x,y) for x=1:n, y=1:n])
end

rotation = map(timepi) do t
    vec(Vec3f0[Vec3f0(cos(t+(x/7)),sin(t+(y/7)), 1) for x=1:20, y=1:20])
end

cubes = visualize(
    (mesh, position_signal),
    rotation=rotation,
    color_map=GLVisualize.default(Vector{RGBA}),
    color_norm=Vec2f0(1,1.8)
    # intensity that will define the color sampled from color_map will fallback
    # to the length of the rotation vector.
    # you could also supply it via intensity = Vector{Float32}
)

# we create our own camera to better adjust to what we want to see.
camera = PerspectiveCamera(
    Signal(Vec3f0(0)), # theta (rotate by x around cam xyz axis)
    Signal(Vec3f0(0)), # translation (translate by translation in the direction of the cam xyz axis)
    Signal(Vec3f0(wx*n+4wx,wy*n,wz*n)/2), # lookat. We want to look at the middle of the cubes
    Signal(Vec3f0(((wx*n+4wx)/2),1.2*wy*n,(wz*n)/2)), # camera position. We want to be on the same height, but further away in y
    Signal(Vec3f0(0,0,1)), #upvector
    window.area, # window area

    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0), # Max distance (clip distance)
    Signal(GLAbstraction.ORTHOGRAPHIC)
)
view(cubes, window, camera=camera)


renderloop(window)

```

# Flow3D

<video  width="600" autoplay loop>
  <source src="../../media/flow3D.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive

 window = glscreen()
 timesignal = bounce(linspace(0,1,360))
N = 7
# generate some rotations
function rotation_func(t)
    t = (t == 0f0 ? 0.01f0 : t)
    Vec3f0[(sin(x/t), cos(y/(t/2f0)), sqrt(t+z^2)) for x=1:N, y=1:N, z=1:N]
end

# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, timesignal)

# create a visualisation
vis = visualize(flow)
view(vis, window)

 renderloop(window)

```

# Particles

<video  width="600" autoplay loop>
  <source src="../../media/particles.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, GLAbstraction
using Colors, Reactive, FileIO
window = glscreen()
timesignal = bounce(linspace(0f0, 1f0, 360))

cat    = GLNormalMesh(loadasset("cat.obj"))
sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 12)

function scale_gen(v0, nv)
	l = length(v0)
	@inbounds for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i))/2
	end
	v0
end
function color_gen(v0, t)
	l = length(v0)
	@inbounds for x=1:l
		v0[x] = RGBA{U8}(x/l,(cos(t)+1)/2,(sin(x/l/3)+1)/2.,1.)
	end
	v0
end

t      		 = const_lift(x->x+0.1, timesignal)
ps 			 = sphere.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale 		 = foldp(scale_gen, scale_start, t)
colorstart 	 = color_gen(zeros(RGBA{U8}, length(ps)), value(t))
color  		 = foldp(color_gen, colorstart, t)
rotation 	 = -sphere.normals

cats = visualize((cat, ps), scale=scale, color=color, rotation=rotation)

view(cats, window)

renderloop(window)

```

# Sinfun

<video  width="600" autoplay loop>
  <source src="../../media/sinfun.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Colors, GLAbstraction

window = glscreen()
timesignal = bounce(linspace(0f0,1f0,360))

t = const_lift(*, timesignal, 20pi)
n = 50
const yrange = linspace(0.03, 0.3, n)
trange = linspace(0, 10pi, 200)

function gen_points(timesignal, y)
    x = sin(timesignal+(y*60*pi*y)+y)*y*5
    z = cos((timesignal+pi)+(y*60*pi*y)+y)*y*5
    Point3f0(x,y*60f0,z)
end
function gen_points(timesignal)
    Point3f0[gen_points(timesignal, y) for y in yrange]
end

positions = map(gen_points, t)
scale     = map(Vec3f0, linspace(0.05, 0.6, n))
primitive = centered(Sphere)
color     = map(RGB{Float32}, colormap("RdBu", n))
points 	  = visualize((primitive, positions), scale=scale, color=color)

view(points, window)

renderloop(window)

```

# Sphere1Drange

<video  width="600" autoplay loop>
  <source src="../../media/sphere1Drange.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GeometryTypes, Reactive, GLAbstraction

 window = glscreen()
 timesignal = bounce(linspace(0f0, 1f0,360))
# last argument can be used to control the granularity of the resulting mesh
sphere = GLNormalMesh(Sphere(Point3f0(0.5), 0.5f0), 24)
c = collect(linspace(0.1f0,1.0f0,10f0))
rotation = map(rotationmatrix_z, const_lift(*, timesignal, 2f0*pi))
# create a visualisation
vis = visualize((sphere, c), model=rotation, scale_y=0.1f0)
view(vis, window)

 renderloop(window)

```

