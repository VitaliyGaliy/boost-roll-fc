function [m, T] = mass_thrust(t, p)
    if t < p.burn_time_s
        T = p.thrust_n;
        m = p.mass_wet_kg - p.mass_dot_kgps * t;
    else
        T = 0;
        m = p.mass_dry_kg;
    end
    m = max(m, 0.5 * p.mass_dry_kg);
end
