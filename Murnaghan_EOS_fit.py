import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# ---------- Murnaghan EOS Function ----------
def murnaghan(V, E0, B0, BP, V0):
    E = E0 + B0*V/BP * (((V0/V)**BP)/(BP - 1) + 1) - B0*V0/(BP - 1)
    return E

# ---------- Load Data from EvsV.dat ----------
data = np.loadtxt('EvsV.dat')
volumes = data[:, 0]
energies = data[:, 1]

# ---------- Initial Guess ----------
initial_guess = [min(energies), 1.0, 4.0, volumes[np.argmin(energies)]]

# ---------- Curve Fit ----------
params, _ = curve_fit(murnaghan, volumes, energies, p0=initial_guess)
E0, B0, BP, V0 = params

# ---------- Fit Curve ----------
V_fit = np.linspace(min(volumes), max(volumes), 200)
E_fit = murnaghan(V_fit, *params)

# ---------- Plot ----------
plt.figure(figsize=(8, 6))
plt.plot(volumes, energies, 'ro', label='SIESTA Data')
plt.plot(V_fit, E_fit, 'b-', label='Murnaghan Fit')
plt.xlabel('Volume (Å³)', fontsize=12)
plt.ylabel('Total Energy (eV)', fontsize=12)
plt.title('Murnaghan Equation of State Fit', fontsize=14)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("EvsV_Murnaghan_Fit.png", dpi=300)
plt.show()

# ---------- Output Results ----------
print(f"Equilibrium Energy (E0): {E0:.6f} eV")
print(f"Equilibrium Volume (V0): {V0:.6f} Å³")
print(f"Bulk Modulus (B0): {B0:.6f} eV/Å³ = {B0*160.2177:.2f} GPa")
print(f"Bulk Modulus Derivative (B0'): {BP:.6f}")

