function y = boost_roll_plant_pack(delta_cmd)
%BOOST_ROLL_PLANT_PACK One 400 Hz plant step for Simulink (vector out).
%   y = [phi; p; delta; V; alt]

    persistent x p t
    dt = 1 / 400;

    if isempty(x)
        p = evalin("base", "boost_p");
        x = zeros(8, 1);
        x(5) = p.launch_pitch_rad;
        x(2) = 0.01;
        t = 0;
    end

    [m, T] = mass_thrust(t, p);
    p.m_now = m;
    p.T_now = T;

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
    x(5) = p.launch_pitch_rad;
    x(6) = wrap_pi(x(6));
    x(8) = max(min(x(8), p.delta_max_rad), -p.delta_max_rad);

    V = hypot(x(3), x(4));
    t = t + dt;
    y = [x(6); x(7); x(8); V; x(2)];
end
