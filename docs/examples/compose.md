# Barplot

![Barplot](../../media/barplot.png)

```Julia
using Colors, GLVisualize
using GLVisualize.ComposeBackend, Gadfly, DataFrames, RDatasets

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)


p = plot(dataset("car", "SLID"), x="Wages", color="Language", Geom.histogram)

draw(composebackend, p)

renderloop(window)

```

# Catgraph

![Catgraph](../../media/catgraph.png)

```Julia
using Colors, GLVisualize
using Gadfly, GLVisualize.ComposeBackend

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)



p = plot(x=1:100, y=2.^rand(100),
     Scale.y_sqrt, Geom.point, Geom.smooth,
     Guide.xlabel("Stimulus"), Guide.ylabel("Response"), Guide.title("Cat Training"))

draw(composebackend, p)

renderloop(window)

```

# Compose



```Julia
using Colors, GLVisualize
using GLVisualize.ComposeBackend, Compose

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)

p = compose(context(0.0mm, 0.0mm, 200mm, 200mm),
    rectangle([0.25, 0.5, 0.75], [0.25, 0.5, 0.75], [0.1], [0.1]),
    fill([LCHab(92, 10, 77), LCHab(68, 74, 192), LCHab(78, 84, 29)]),
    stroke([LCHab(5, 0, 77),LCHab(5, 77, 77),LCHab(50, 0, 8)]),
    (context(), circle(), fill("bisque")),
    (context(), rectangle(), fill("tomato"))
)
draw(composebackend, p)

renderloop(window)

```

# Errorbar

![Errorbar](../../media/errorbar.png)

```Julia
using GLVisualize.ComposeBackend, Gadfly, Distributions
using Colors, GLVisualize

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)


sds = [1, 1/2, 1/4, 1/8, 1/16, 1/32]
n = 10
ys = [mean(rand(Distributions.Normal(0, sd), n)) for sd in sds]
ymins = ys .- (1.96 * sds / sqrt(n))
ymaxs = ys .+ (1.96 * sds / sqrt(n))

p = plot(x=1:length(sds), y=ys, ymin=ymins, ymax=ymaxs,
     Geom.point, Geom.errorbar)

draw(composebackend, p)

renderloop(window)

```

# Regression

![Regression](../../media/regression.png)

```Julia
using GLVisualize.ComposeBackend, Gadfly
using Colors, GLVisualize

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)



using Distributions
x1 = rand(40)
y1 = 4.*x1 .+ 2 .+randn(40)
x2 = rand(40)
y2 = -6.*x2 .+ 3 .+ randn(40)
x  = [x1;x2]
y  = [y1;y2]
col = [fill("Slope 4",40); fill("Slope -6",40)]
p = plot(x=x,y=y,colour=col, Geom.point, Geom.smooth(method=:lm))

draw(composebackend, p)

renderloop(window)

```

# Singraph

![Singraph](../../media/singraph.png)

```Julia
using Colors, GLVisualize
using Gadfly, GLVisualize.ComposeBackend

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)


p = plot([sin, cos], 0, 25)

draw(composebackend, p)
renderloop(window)

```

# Sin Dataframe

![Sin Dataframe](../../media/sin_dataframe.png)

```Julia
using Colors, GLVisualize
using DataFrames, Gadfly, GLVisualize.ComposeBackend

window = glscreen()
composebackend = ComposeBackend.GLVisualizeBackend(window)


xs = 0:0.1:20

df_cos = DataFrame(
    x=xs,
    y=cos(xs),
    ymin=cos(xs) .- 0.5,
    ymax=cos(xs) .+ 0.5,
    f="cos"
)
df_sin = DataFrame(
    x=xs,
    y=sin(xs),
    ymin=sin(xs) .- 0.5,
    ymax=sin(xs) .+ 0.5,
    f="sin"
)
df = vcat(df_cos, df_sin)
p = plot(df, x=:x, y=:y, ymin=:ymin, ymax=:ymax, color=:f, Geom.line, Geom.ribbon)


draw(composebackend, p)

renderloop(window)

```

