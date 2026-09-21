function g = params_ardupilot()
%PARAMS_ARDUPILOT Gains in the shape of ArduPlane RLL2SRV_*.
%   Output of the controller is normalized to +/- 1, then scaled to delta_max.
%
%   Map after a good run:
%     TCONST -> RLL2SRV_TCONST   (s)
%     P      -> RLL2SRV_P
%     I      -> RLL2SRV_I
%     D      -> RLL2SRV_D
%     FF     -> RLL2SRV_FF
%     RMAX   -> RLL2SRV_RMAX     (deg/s)  we store rad/s here
%     IMAX   -> RLL2SRV_IMAX     (normalized 0-1)

    g = struct();
    g.TCONST = 0.50;                  % s, desired roll-angle time constant
    g.P = 0.35;                       % conservative: no pitot, high-q boost
    g.I = 0.10;
    g.D = 0.02;
    g.FF = 0.15;
    g.RMAX = deg2rad(60);             % max demanded roll rate
    g.IMAX = 0.40;                    % integrator clamp on normalized output
    g.ctrl_hz = 50;                   % Plane surface loop is slower than IMU
end
