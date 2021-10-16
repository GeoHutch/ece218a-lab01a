using PGFPlots
using DSP

include("../ads_text_reader.jl")

data = read_two_port("text_data/5mm.txt")

Z0 = 50

Z(Gamma) = (1 + Gamma)/(1 - Gamma)

ws_meas = data.fs .* 2pi
S21_meas = data.S21
S21_interp = resample(S21_meas, 4)

r_crossing_idx = findall(x->abs(x)>0.5, diff(sign.(imag.(S21_interp))))[1]
markpoint = S21_interp[r_crossing_idx]
Zcross = Z(markpoint)

fig = SmithAxis([
                 PGFPlots.SmithData(Z.(S21_interp), style="blue", mark="none", legendentry="5mm Wire"),
                 PGFPlots.SmithData([Zcross], style="blue", mark="square", legendentry="Z=$(Zcross)"),
    #  PGFPlots.SmithData(ZC.(ws), style="thick", mark="none", legendentry="Capacitor"),
])

save("figures/build/smith_5mm.svd",fig)

