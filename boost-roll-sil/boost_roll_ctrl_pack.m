function u = boost_roll_ctrl_pack(x_roll)
%BOOST_ROLL_CTRL_PACK ArduPlane-style roll PID, 50 Hz, for Simulink.
%   x_roll = [phi; p]

    persistent mem g nextCtrl uHold t
    dt_plant = 1 / 400;

    if isempty(g)
        g = evalin("base", "boost_g");
        mem = [];
        nextCtrl = 0;
        uHold = 0;
        t = 0;
    end

    if t + 1e-12 >= nextCtrl
        [uHold, mem] = plane_roll_pid(x_roll(1), x_roll(2), 0, 1 / g.ctrl_hz, g, mem);
        nextCtrl = nextCtrl + 1 / g.ctrl_hz;
    end
    t = t + dt_plant;
    u = uHold;
end
