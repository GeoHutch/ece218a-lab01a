include("../ads_text_reader.jl")

using Plots
using DSP
using SavitzkyGolay
using LaTeXStrings

l=0.13

trl_3mm=read_two_port("text_data/3mm.txt")
trl_5mm=read_two_port("text_data/5mm.txt")
trl_10mm=read_two_port("text_data/10mm.txt")

S12 = vcat(transpose.([trl_3mm.S12, trl_5mm.S12, trl_10mm.S12])...)
wss = 2pi .* trl_3mm.fs
wstep = wss[2] - wss[1]
N = length(wss[1])
phases = unwrap(angle.(S12);dims=2)
phases_aug = hcat(phases,zeros(3))
#  phases_aug = [cat(phase,phase[end] .+ zeros(1); dims=1) for phase in phases]
#  diff = remez(10,[(0.01,0.99) => (f -> f/2, f -> 1/f)];neg=true,Hz=10.0)
#  dphidws = [filt(diff,phase) for phase in phases]
dphidws = diff(phases_aug;dims=2) ./ wstep

vphs = -l ./ dphidws
vphs_smooth = vcat([savitzky_golay(vphs[i,:], 45, 3).y for i in 1:3])

plot(xlabel=L"\omega")
plot!(wss, vphs_smooth[1,:], label=L"v_{3\mathrm{mm}}(\omega)")
plot!(wss, vphs_smooth[2,:], label=L"v_{5\mathrm{mm}}(\omega)")
plot!(wss, vphs_smooth[3,:], label=L"v_{10\mathrm{mm}}(\omega)")

savefig("figures/build/phase_vel.pdf")

