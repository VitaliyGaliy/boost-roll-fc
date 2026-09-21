%COMPUTE_L_VS_SPEED  L_control at fixed delta for several airspeeds.
%   Does not change the Simulink model. All geometry numbers are ESTIMATES.

rho = 1.225;                 % kg/m^3, sea-level ESTIMATE
S_ctrl = 0.04;               % m^2, fin area ESTIMATE
roll_lever = 0.10;           % m, ESTIMATE
CL_delta = 0.8;              % 1/rad, ESTIMATE
delta_deg = 5;               % fixed fin angle
delta = deg2rad(delta_deg);

V_list = [10, 20, 40];       % m/s

fprintf("Fixed delta = %.1f deg = %.4f rad\n", delta_deg, delta);
fprintf("L_control = (1/2 rho V^2) * S * d * CL_delta * delta\n\n");
fprintf("   V (m/s)    q (Pa)     L_control (N*m)    vs V=10\n");

L10 = NaN;
for V = V_list
    q = 0.5 * rho * V^2;
    L = q * S_ctrl * roll_lever * CL_delta * delta;
    if V == 10
        L10 = L;
    end
    fprintf("%8.0f  %8.1f  %16.5f  %8.2f x\n", V, q, L, L / L10);
end
