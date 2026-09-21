function log = run_boost_roll(stopTime)
%RUN_BOOST_ROLL Configure, simulate, plot, print ArduPilot mapping.
%
%   log = run_boost_roll
%   log = run_boost_roll(8)

    if nargin < 1 || isempty(stopTime)
        stopTime = 8;
    end

    root = fileparts(mfilename("fullpath"));
    addpath(root);
    addpath(fullfile(root, "control"));
    addpath(fullfile(root, "plant"));
    addpath(fullfile(root, "sim"));
    addpath(fullfile(root, "plot"));

    p = params_vehicle();
    g = params_ardupilot();
    log = simulate_boost(p, g, stopTime);
    plot_boost_roll(log);
    print_ardupilot_map(g, log);
end

function print_ardupilot_map(g, log)
    iBurn = log.t <= log.vehicle.burn_time_s;
    phiPeak = max(abs(log.phi_deg(iBurn)));
    fprintf("\nBoost roll SIL  (placeholders in params_vehicle.m)\n");
    fprintf("  peak |phi| during burn : %.2f deg\n", phiPeak);
    fprintf("  max |delta|            : %.2f deg\n", max(abs(log.delta_deg)));
    fprintf("  V at burnout           : %.1f m/s\n", log.V(find(iBurn, 1, "last")));
    fprintf("\nPut these into ArduPlane (motors off, SERVO_FUNCTION = aileron):\n");
    fprintf("  RLL2SRV_TCONST = %.2f\n", g.TCONST);
    fprintf("  RLL2SRV_P      = %.2f\n", g.P);
    fprintf("  RLL2SRV_I      = %.2f\n", g.I);
    fprintf("  RLL2SRV_D      = %.2f\n", g.D);
    fprintf("  RLL2SRV_FF     = %.2f\n", g.FF);
    fprintf("  RLL2SRV_RMAX   = %.0f\n", rad2deg(g.RMAX));
    fprintf("  RLL2SRV_IMAX   = %.0f\n", 1000 * g.IMAX);
end
