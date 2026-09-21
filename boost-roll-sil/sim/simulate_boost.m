function log = simulate_boost(p, g, stopTime)
%SIMULATE_BOOST Fixed-step SIL: axial boost at launch pitch, roll PID on surfaces.

    if nargin < 3 || isempty(stopTime)
        stopTime = 8;
    end

    dt = 1 / 400;
    dt_ctrl = 1 / g.ctrl_hz;
    n = floor(stopTime / dt) + 1;

    usePitch = logical(p.free_pitch);
    if usePitch
        x = zeros(9, 1);
    else
        x = zeros(8, 1);
    end
    x(5) = p.launch_pitch_rad;        % theta
    x(2) = 0.01;                      % pz slightly off pad

    mem = [];
    u = 0;
    delta_cmd = 0;
    nextCtrl = 0;

    log.t = zeros(n, 1);
    log.phi = zeros(n, 1);
    log.roll_rate = zeros(n, 1);
    log.delta = zeros(n, 1);
    log.u = zeros(n, 1);
    log.V = zeros(n, 1);
    log.alt = zeros(n, 1);
    log.theta = zeros(n, 1);
    log.T = zeros(n, 1);
    log.qbar = zeros(n, 1);

    phi_ref = 0;
    t = 0;
    for k = 1:n
        [m, T] = mass_thrust(t, p);
        p.m_now = m;
        p.T_now = T;

        if t + 1e-12 >= nextCtrl
            [u, mem] = plane_roll_pid(x(6), x(7), phi_ref, dt_ctrl, g, mem);
            delta_cmd = u * p.delta_max_rad;
            nextCtrl = nextCtrl + dt_ctrl;
        end

        k1 = boost_roll_deriv(x, delta_cmd, p);
        k2 = boost_roll_deriv(x + 0.5 * dt * k1, delta_cmd, p);
        k3 = boost_roll_deriv(x + 0.5 * dt * k2, delta_cmd, p);
        k4 = boost_roll_deriv(x + dt * k3, delta_cmd, p);
        x = x + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4);

        if hypot(x(1), x(2)) < p.rail_length_m
            x(6) = 0;
            x(7) = 0;
            x(8) = 0;
        end

        if ~usePitch
            x(5) = p.launch_pitch_rad;
        end
        x(6) = wrap_pi(x(6));
        x(8) = max(min(x(8), p.delta_max_rad), -p.delta_max_rad);

        V = hypot(x(3), x(4));
        log.t(k) = t;
        log.phi(k) = x(6);
        log.roll_rate(k) = x(7);
        log.delta(k) = x(8);
        log.u(k) = u;
        log.V(k) = V;
        log.alt(k) = x(2);
        log.theta(k) = x(5);
        log.T(k) = T;
        log.qbar(k) = 0.5 * p.rho_kgm3 * V^2;

        t = t + dt;
    end

    log.vehicle = p;
    log.gains = g;
    log.phi_deg = rad2deg(log.phi);
    log.delta_deg = rad2deg(log.delta);
    log.roll_rate_degs = rad2deg(log.roll_rate);
end
