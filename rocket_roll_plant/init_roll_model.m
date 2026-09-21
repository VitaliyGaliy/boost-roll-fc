%% rocket_roll_plant — one parameter set for FC transfer (ArduPlane mapping later)
% Plant aero beyond K_delta and the existing placeholders is NOT modeled.

%% Plant (physical). Do not invent new aero coefficients.
Ix = 0.003606              % kg*m^2, ESTIMATE (bifilar / SolidWorks later)
K_delta = 0.1              % N*m/rad at V0, PLACEHOLDER fin/canard effectiveness
tau_s = 0.05               % s, ESTIMATE first-order servo
delta_max = 10*pi/180      % rad, |delta_cmd| stop

% Existing placeholders only (not identified, no new aero):
V0 = 20                    % m/s, airspeed where K_delta is defined (PLACEHOLDER)
V = 20                     % m/s, constant airspeed in this model (PLACEHOLDER)
b = 0.004                  % N*m/(rad/s), L_aero=-b*p (PLACEHOLDER)
L_dist_pulse = 0.01        % N*m, disturbance pulse 1..3 s

%% Flight computer timing
Ts = 0.01                  % s, controller sample time (100 Hz)

%% Outer angle loop → p_cmd  (keep cascade; map later to RLL2SRV_TCONST)
phi_cmd = 0                % rad
K_phi = 0.5                % 1/s, p_cmd = K_phi*(phi_cmd - phi_used)
p_max = 0.2                % rad/s, |p_cmd| limit (RLL2SRV_RMAX analog)

%% Inner rate PID+FF  (map later to RLL_RATE_* / RLL2SRV_P,I,D,FF)
% I/D/FF start at 0 so the frozen model matches the previous P-only inner loop
% until you set them from a real ArduPlane tune — not from plane_roll_boost.parm.
Rate_P = 0.5               % was Kp
Rate_I = 0
Rate_D = 0
Rate_FF = 0
Rate_Imax = 0.05           % rad, I-term clamp (anti-windup limit)
Kp = Rate_P                %#ok<NASGU>  legacy alias

p_ss = L_dist_pulse / (K_delta * Rate_P);

fprintf("Ts=%.3f s  K_phi=%.2f  p_max=%.2f  delta_max=%.1f deg  tau_s=%.3f\n", ...
    Ts, K_phi, p_max, delta_max*180/pi, tau_s);
fprintf("Rate PID+FF: P=%.3f I=%.3f D=%.3f FF=%.3f Imax=%.3f\n", ...
    Rate_P, Rate_I, Rate_D, Rate_FF, Rate_Imax);
fprintf("Plant placeholders: Ix=%.5f  K_delta=%.3f  V/V0=%.1f/%.1f  b=%.4f\n", ...
    Ix, K_delta, V, V0, b);
