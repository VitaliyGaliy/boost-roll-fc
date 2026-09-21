function figs = plot_boost_roll(log)
%PLOT_BOOST_ROLL Time histories for boost-phase roll SIL.

    figs.main = figure("Name", "Boost roll SIL", "Color", "w");
    t = log.t;
    tiledlayout(3, 2, "Padding", "compact", "TileSpacing", "compact");

    nexttile;
    plot(t, log.phi_deg, "LineWidth", 1.2);
    yline(0, "k:");
    grid on;
    ylabel("\phi (deg)");
    title("Roll angle");

    nexttile;
    plot(t, log.roll_rate_degs, "LineWidth", 1.2);
    grid on;
    ylabel("p (deg/s)");
    title("Roll rate");

    nexttile;
    plot(t, log.delta_deg, "LineWidth", 1.2);
    grid on;
    ylabel("\delta (deg)");
    title("Canard / aileron");

    nexttile;
    plot(t, log.u, "LineWidth", 1.2);
    grid on;
    ylabel("u (-1..1)");
    title("Normalized PID output");

    nexttile;
    plot(t, log.V, "LineWidth", 1.2);
    grid on;
    ylabel("V (m/s)");
    xlabel("t (s)");
    title("Airspeed");

    nexttile;
    plot(t, log.alt, "LineWidth", 1.2);
    hold on;
    plot(t, rad2deg(log.theta), "LineWidth", 1.2);
    grid on;
    legend("alt (m)", "\theta (deg)", "Location", "best");
    xlabel("t (s)");
    title("Altitude and pitch");
end
