# Maximum Intensity Projection

<video  width="600" autoplay loop><source src="../../media/maximum_intensity_projection.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GLWindow, GLAbstraction

function volume_data(N)
	volume 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
end

window = glscreen()
timesignal = bounce(linspace(0f0,1f0,360))
volumedata = volume_data(128)
using NIfTI
volumedata = niread(assetpath("brain.nii")).raw

volume = visualize(volumedata, :mip)

view(volume, window)


renderloop(window)

```

# Volume

<video  width="600" autoplay loop><source src="../../media/volume.webm"> Your browser does not support the video tag. </video>

```Julia
using GLVisualize, GLWindow

window = glscreen()
timesignal = bounce(linspace(0f0,1f0,360))

function volume_data(N)
	vol 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max 	= maximum(vol)
	min 	= minimum(vol)
	vol 	= (vol .- min) ./ (max .- min)
end

vol = visualize(volume_data(128), :iso, isovalue=timesignal)
view(vol, window)


renderloop(window)

```

