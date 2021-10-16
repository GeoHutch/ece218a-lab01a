using PGFPlots
using DSP
using LaTeXStrings

include("../ads_text_reader.jl")

data_leaded = read_one_port("text_data/passive_cap100pf.txt")
data_smt = read_one_port("text_data/passive_chipcap100pf.txt")

Z0 = 50

function first_at_least(xs,n)
  i=1
  while (xs[i] < n)
    i += 1
  end
  return xs[i]
end

Z(Gamma) = (1 + Gamma)/(1 - Gamma)

ws_meas = data_smt.fs .* 2pi
S11_meas_leaded = data_leaded.S11
S11_meas_smt = data_smt.S11
S11_interp_leaded = resample(S11_meas_leaded, 4)
S11_interp_smt = resample(S11_meas_smt, 4)

S11_theory(w) = 1-(1-0.865)/2 + (1-0.865)/2*exp(im*w)
S11 = S11_theory.(ws_meas)

#  r_crossing_idx_leaded = first_at_least(findall(x->x>0.5, diff(sign.(imag.(S11_interp_leaded)))),10)
#  r_crossing_idx_smt = first_at_least(findall(x->x>0.5, diff(sign.(imag.(S11_interp_smt)))),10)
#  markpoint_leaded = S11_interp_leaded[r_crossing_idx_leaded]
#  markpoint_smt = S11_interp_smt[r_crossing_idx_smt]
#  Zcross_leaded = Z(markpoint_leaded)
#  Zcross_smt = Z(markpoint_smt)

fig = SmithAxis([
                 PGFPlots.SmithData(Z.(S11_interp_leaded[5:end-5]), style="blue", mark="none", legendentry="100pF capacitor (leaded)"),
                 PGFPlots.SmithData(Z.(S11_interp_smt[5:end-5]), style="red", mark="none", legendentry="100pF capacitor (surface-mount)"),
                 #  PGFPlots.SmithData([Zcross], style="cyan", mark="square", legendentry="Z=$(Z0*real(Zcross))"),
                 #  PGFPlots.SmithCircle(1-(1-0.865)/2,0.0,(1-0.865)/2; style="red", texlabel="5mm Wire (Theory)")
                 #  PGFPlots.SmithData(Z.(S11), style="red", mark="none", legendentry="5mm Wire (Theory)"),
])

save("figures/build/smith_cap.pdf",fig)

