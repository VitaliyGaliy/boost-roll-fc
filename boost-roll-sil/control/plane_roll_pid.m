function [u, mem] = plane_roll_pid(phi, p, phi_ref, dt, g, mem)
%PLANE_ROLL_PID ArduPlane-style cascade: angle error -> rate demand -> PID.
%   phi, p, phi_ref : rad, rad/s
%   u               : normalized aileron/canard command in [-1, 1]

    if isempty(mem)
        mem.integ = 0;
        mem.rate_err_prev = 0;
    end

    tau = max(g.TCONST, 0.05);
    angle_err = wrap_pi(phi_ref - phi);
    p_des = angle_err / tau;
    p_des = max(min(p_des, g.RMAX), -g.RMAX);

    rate_err = p_des - p;
    d_term = 0;
    if dt > 0
        d_term = (rate_err - mem.rate_err_prev) / dt;
    end

    mem.integ = mem.integ + rate_err * g.I * dt;
    mem.integ = max(min(mem.integ, g.IMAX), -g.IMAX);

    u = g.P * rate_err + mem.integ + g.D * d_term + g.FF * p_des;
    u = max(min(u, 1), -1);

    mem.rate_err_prev = rate_err;
    mem.p_des = p_des;
end
