using PGFPlots
using DSP
using LaTeXStrings

include("../ads_text_reader.jl")

data = read_two_port("text_data/5mm.txt")

Z0 = 50

function first_at_least(xs,n)
  i=1
  while (xs[i] < n)
    i += 1
  end
  return xs[i]
end

Z(Gamma) = (1 + Gamma)/(1 - Gamma)

ws_meas = data.fs .* 2pi
S11_meas = data.S11
S11_interp = resample(S11_meas, 4)

S11_theory(w) = 1-(1-0.865)/2 + (1-0.865)/2*exp(im*w)
S11 = S11_theory.(ws_meas)

r_crossing_idx = first_at_least(findall(x->x>0.5, diff(sign.(imag.(S11_interp)))),10)
markpoint = S11_interp[r_crossing_idx]
Zcross = Z(markpoint)

fig = SmithAxis([
                 PGFPlots.SmithData(Z.(S11_interp), style="blue", mark="none", legendentry="5mm Wire (Measured)"),
                 PGFPlots.SmithData([Zcross], style="cyan", mark="square", legendentry="Z=$(Z0*real(Zcross))"),
                 PGFPlots.SmithCircle(1-(1-0.865)/2,0.0,(1-0.865)/2; style="red", texlabel="5mm Wire (Theory)")
                 #  PGFPlots.SmithData(Z.(S11), style="red", mark="none", legendentry="5mm Wire (Theory)"),
])

save("figures/build/smith_5mm.pdf",fig)

