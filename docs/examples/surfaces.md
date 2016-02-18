# Dirac Belt

<video  width="600" autoplay loop>
  <source src="../../media/dirac_belt.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GeometryTypes, Quaternions, GLVisualize, Reactive, GLAbstraction

function Quaternions.qrotation{T<:Real}(axis::Quaternion{T}, theta::T)
    ax = Vec{3,T}(axis.v1, axis.v2, axis.v3)
    qrotation(ax, theta)
end

function Quaternions.qrotation{T<:Real}(axis::Quaternion{T}, z::Quaternion{T}, theta::T)
    q = qrotation(axis, theta)
    q*z*conj(q)
end

function quaternion_belt_trick(timesignal)

    rad1 = 1f0 # outer circle
    rad2 = 0.2f0 # inner circle

    center1 = Point2f0(rad1,rad1) # left
    center2 = Point2f0(rad1+2f0,rad1) # right

    u1234 = Quaternion(0f0,0f0,1f0,0f0) # gets rotated
    axis  = Quaternion(0f0,0f0,0f0,1f0) # axis of qrotationdd
    mi  = 80
    mj  = 10
    rxs = zeros(Float32, mi+1,mj+1)
    rys = zeros(Float32, mi+1,mj+1)
    rzs = zeros(Float32, mi+1,mj+1)

    max_frames = 96
    dphi = 2*pi/(max_frames-1) # include both ends

    u1234_s = foldp(u1234, timesignal) do v0, _
        qrotation(axis, v0, Float32(dphi))
    end
    xyz = const_lift(plot_belts, rxs, rys, rzs, u1234_s, center1, center2, rad1, rad2)
    x = const_lift(getindex, xyz, 1)
    y = const_lift(getindex, xyz, 2)
    z = const_lift(getindex, xyz, 3)
    (x,y,z)
end

function plot_belts(rxs, rys, rzs, u1234, center1, center2, rad1, rad2)
    mi  = 80
    mj  = 10
    iis = 1f0:(mi+1f0)
    rs  = rad1-((rad1-rad2)*(iis-1f0)/mi)
    for ii=1:(mi+1)
        jjs   = 1f0:(mj+1f0)
        xs    = (rad2/mj)*((jjs-1f0)-(mj/2f0))
        ys    = sqrt(rs[ii]*rs[ii]-xs.*xs)
        theta = Float32(2*pi*(ii-1)/mi)

        for jj=1:(mj+1)
            efgh    = Quaternion(0f0, xs[jj], ys[jj], 0f0)
            wxyz    = qrotation(efgh, u1234, theta)
            rxs[ii,jj] = center1[1]+wxyz.v1
            rys[ii,jj] = center1[2]+wxyz.v2
            rzs[ii,jj] = wxyz.v3
        end
    end
    rxs, rys, rzs
end

window = glscreen()
timesignal = loop(linspace(0f0, 1f0, 360))

xyz = quaternion_belt_trick(timesignal)
view(visualize(xyz, :surface), window)

renderloop(window)

```

# Juliaset

<video  width="600" autoplay loop>
  <source src="../../media/juliaset.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GLAbstraction

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

function juliadata(max_iterations, imgx, imgy)
    scalex, scaley = 4.0/imgx, 4.0/imgy

    # initialize our Float32 heightfield
    heightfield = zeros(Float32, imgx, imgy)

    # do julia set magic!
    for x=1:imgx, y=1:imgy
        cy = y * scaley - 2.0
        cx = x * scalex - 2.0
        z = Complex(cx, cy)
        c = Complex(-0.4, 0.6)
        i = 0
        for t in 0:max_iterations
            if norm(z) > 2.0
                break
            end
            z = z * z + c
            i = t
        end
        heightfield[x,y] = -(i/512f0)
    end
    heightfield
end

let

rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

heightfield = juliadata(256, 700, 700)

# visualize the heightfield as a surface
vis = visualize(
    heightfield, :surface,
    model=rotation
)

# display it on the window
view(vis, window)

end

renderloop(window) # render!

```

# Mesh

<video  width="600" autoplay loop>
  <source src="../../media/mesh.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GLAbstraction, GeometryTypes, Reactive

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

function mgrid(dim1, dim2)
    X = [i for i in dim1, j in dim2]
    Y = [j for i in dim1, j in dim2]
    return X,Y
end

let

rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

dphi, dtheta = pi/200.0f0, pi/200.0f0

phi,theta = mgrid(0f0:dphi:(pi+dphi*1.5f0), 0f0:dtheta:(2f0*pi+dtheta*1.5f0));
m0 = 4f0; m1 = 3f0; m2 = 2f0; m3 = 3f0; m4 = 6f0; m5 = 2f0; m6 = 6f0; m7 = 4f0;
a = sin(m0*phi).^m1;
b = cos(m2*phi).^m3;
c = sin(m4*theta).^m5;
d = cos(m6*theta).^m7;
r = a + b + c + d;
x = r.*sin(phi).*cos(theta);
y = r.*cos(phi);
z = r.*sin(phi).*sin(theta);


surface = visualize((x,y,z), :surface, model=rotation)
view(surface, window)

end

renderloop(window)

```

# Surface

<video  width="600" autoplay loop>
  <source src="../../media/surface.webm">
      Your browser does not support the video tag.
</video>


```Julia
using GLVisualize, GLAbstraction, Colors, Reactive, GeometryTypes

window = glscreen()
timesignal = loop(linspace(0f0,1f0,360))

# generate some pretty data
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end

surf(i, N) = Float32[xy_data(x, y, i, N) for x=1:N, y=1:N]

t = map(t->(t*30f0)+20f0, timesignal)

bb = Signal(AABB{Float32}(Vec3f0(0), Vec3f0(1)))

view(visualize(const_lift(surf, t, 400), :surface, boundingbox=bb))

renderloop(window)

```

