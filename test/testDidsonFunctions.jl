# test sonar functions directly
using RoME, TransformUtils, IncrementalInference



using KernelDensityEstimate


meas = LinearRangeBearingElevation((3.0,3e-4),(0.2,3e-4))
# LinearRangeBearingElevation(Distributions.Normal{Float64}(μ=0.2, σ=0.001),Distributions.Normal{Float64}(μ=3.0, σ=0.001),Distributions.Uniform{Float64}(a=-0.25133, b=0.25133))
X, pts = 0.01*randn(6,200), zeros(3,200);
# X[1:3,:] = 0.1*randn(3,200)
for i in 1:200
	project!(meas, X, pts, i)
end
p1 = kde!(pts);

pts, L = 0.01*randn(6,200), zeros(3,200);
L[1,:] += 3.0
L[2,:] += 0.65

# X = rand(6,200)
for i in 1:200
	backprojectRandomized!(meas, L, pts, i)
end
p2 = kde!(pts);







#  visualization

#
# using Gadfly
#
# axis = [[1.5;3.5]';[-1.25;1.25]';[-1.0;1.0]']
# draw( PDF("/home/dehann/Desktop/test.pdf",30cm,20cm),
#       plotKDE( p1, dimLbls=["x";"y";"z"], axis=axis)  )
#
#
# axis = [[-2.5;2.5]';[-2.5;2.5]';[-2.5;2.5]';[-2pi;2pi]';[-2pi;2pi]';[-2pi;2pi]']
# draw( PDF("/home/dehann/Desktop/test.pdf",30cm,20cm),
#       plotKDE( p2, dimLbls=["x";"y";"z"; "roll"; "pitch"; "yaw"], axis=axis)  )



# do test directly in factor graph
fg = initfg()
N = 200

initCov = eye(6)
[initCov[i,i] = 0.01 for i in 4:6];
odoCov = deepcopy(initCov)

println("Adding PriorPose3 to graph...")
X, pts = 0.01*randn(6,N), zeros(3,N);

v1 = addNode!(fg,"x1",  X,  N=N)
initPosePrior = PriorPose3(SE3(0), initCov)
f1  = addFactor!(fg,[v1], initPosePrior)


println("Adding LinearRangeBearingElevation to graph...")
meas = LinearRangeBearingElevation((3.0,3e-4),(0.2,3e-4))
for i in 1:N
	project!(meas, X, pts, i)
end
v2 = addNode!(fg,"l2",  pts, N=N)
addFactor!(fg,[v1;v2],meas)


tree = wipeBuildNewTree!(fg)
inferOverTreeR!(fg, tree)
inferOverTree!(fg, tree)
