function p = params_vehicle()
%PARAMS_VEHICLE Physical parameters for coaxial booster + airframe stack.
%   Numbers marked ESTIMATE are placeholders. Replace with CAD / weigh-in.

    p = struct();

    %% Mass and propulsion (ESTIMATE)
    p.mass_wet_kg = 8.0;              % drone + booster, before burn
    p.mass_propellant_kg = 1.5;
    p.thrust_n = 250;                 % axial, along fuselage
    p.burn_time_s = 3.0;
    p.g = 9.81;

    %% Inertia about roll axis (ESTIMATE)
    p.Ixx_kgm2 = 0.12;

    %% Geometry
    p.diameter_m = 0.12;
    p.S_ref_m2 = pi * (p.diameter_m / 2)^2;
    p.launch_pitch_rad = deg2rad(45); % body axis above horizontal
    p.rail_length_m = 3.0;            % roll locked until this distance (ESTIMATE)

    %% Roll effector: canards / ailerons (ESTIMATE)
    % Motors are unused during boost. Roll moment = q * S_ctrl * d * CL_delta * delta.
    p.S_ctrl_m2 = 0.04;               % total canard / aileron area
    p.CL_delta_per_rad = 0.8;
    p.roll_lever_m = 0.10;
    p.delta_max_rad = deg2rad(15);
    p.servo_tau_s = 0.05;             % first-order servo
    p.aero_roll_damp = 0.04;          % N*m / (rad/s), ESTIMATE

    %% Disturbance: equivalent thrust roll lever (ESTIMATE)
    % True axial offset of a nozzle makes pitch/yaw, not roll.
    % This term is "how much rolling moment per newton of thrust".
    p.thrust_roll_lever_m = 5e-4;     % small; raise this to stress the PID

    %% Atmosphere (sea-level, constant)
    p.rho_kgm3 = 1.225;

    %% Optional pitch-off (C_Na). Off by default: pitch stays at 45 deg.
    p.free_pitch = false;
    p.CNa_per_rad = 8;                % body normal-force slope, ESTIMATE
    p.static_margin_m = 0.15;         % x_cp - x_cg, positive = restoring
    p.Iyy_kgm2 = 1.8;

    %% Derived
    p.mass_dot_kgps = p.mass_propellant_kg / p.burn_time_s;
    p.mass_dry_kg = p.mass_wet_kg - p.mass_propellant_kg;
end
