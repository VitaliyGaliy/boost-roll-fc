function xdot = boost_roll_deriv(x, delta, p)
%BOOST_ROLL_DERIV State: [px pz vx vz theta phi p delta]
%   px, pz : m, z up; theta pitch from horizontal; phi roll; p roll rate.

    px = x(1); %#ok<NASGU>
    pz = x(2);
    vx = x(3);
    vz = x(4);
    theta = x(5);
    phi = x(6); %#ok<NASGU>
    p_rate = x(7);
    delta_state = x(8);

    t_dummy = 0; %#ok<NASGU>
    % mass/thrust applied by caller via p.T_now, p.m_now
    m = p.m_now;
    T = p.T_now;

    V = hypot(vx, vz);
    qbar = 0.5 * p.rho_kgm3 * V^2;

    ax = (T / m) * cos(theta);
    az = (T / m) * sin(theta) - p.g;

    if p.free_pitch && V > 1
        gamma = atan2(vz, vx);
        alpha = wrap_pi(theta - gamma);
        FN = qbar * p.S_ref_m2 * p.CNa_per_rad * alpha;
        M_pitch = -FN * p.static_margin_m;
        q_pitch = x(9);
        thetadot = q_pitch;
        qdot = M_pitch / p.Iyy_kgm2;
    else
        thetadot = 0;
        qdot = 0;
    end

    CL = p.CL_delta_per_rad * delta_state;
    M_aero = qbar * p.S_ctrl_m2 * p.roll_lever_m * CL;
    M_dist = T * p.thrust_roll_lever_m;
    M_damp = -p.aero_roll_damp * p_rate;
    pdot = (M_aero + M_dist + M_damp) / p.Ixx_kgm2;

    delta_dot = (delta - delta_state) / max(p.servo_tau_s, 1e-3);

    if p.free_pitch
        xdot = [vx; vz; ax; az; thetadot; p_rate; pdot; delta_dot; qdot];
    else
        xdot = [vx; vz; ax; az; thetadot; p_rate; pdot; delta_dot];
    end

    if pz <= 0 && vz < 0
        xdot(2) = 0;
        xdot(4) = 0;
    end
end
