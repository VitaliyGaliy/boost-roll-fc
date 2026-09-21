function write_plane_roll_parm(out_path)
%WRITE_PLANE_ROLL_PARM Write Mission Planner .parm from params_ardupilot.
    here = fileparts(mfilename("fullpath"));
    addpath(fileparts(here));
    g = params_ardupilot();
    if nargin < 1 || isempty(out_path)
        out_path = fullfile(here, "plane_roll_boost.parm");
    end

    rmax_deg = rad2deg(g.RMAX);
    imax_cdeg = 4500 * g.IMAX;  % Plane IMAX is often centi-deg of surface; keep modest

    lines = [
        "# ESTIMATE file — do NOT load this whole file onto Matek."
        "# Bench bring-up is matek_h743_fbwa_bringup.parm (no RLL2SRV_* from here)."
        "# Firmware: ArduPlane MatekH743 (not Copter ATC_RAT_RLL_*)."
        "# Map canards to Aileron (SERVOx_FUNCTION = 4) after mount."
        sprintf("RLL2SRV_TCONST,%.2f", g.TCONST)
        sprintf("RLL2SRV_RMAX,%.0f", rmax_deg)
        "# No pitot, no GPS (gyro/AHRS only)."
        "ARSPD_TYPE,0"
        "ARSPD_USE,0"
        "ARSPD_AUTOCAL,0"
        "GPS1_TYPE,0"
        "GPS2_TYPE,0"
        "AHRS_GPS_USE,0"
        "ARMING_NEED_LOC,0"
        "ARMING_SKIPCHK,260"
        "EK3_SRC1_POSXY,0"
        "EK3_SRC1_VELXY,0"
        "EK3_SRC1_VELZ,0"
        sprintf("RLL2SRV_P,%.3f", g.P)
        sprintf("RLL2SRV_I,%.3f", g.I)
        sprintf("RLL2SRV_D,%.3f", g.D)
        sprintf("RLL2SRV_FF,%.3f", g.FF)
        sprintf("RLL2SRV_IMAX,%.0f", imax_cdeg)
        sprintf("RLL_RATE_P,%.3f", g.P)
        sprintf("RLL_RATE_I,%.3f", g.I)
        sprintf("RLL_RATE_D,%.3f", g.D)
        sprintf("RLL_RATE_FF,%.3f", g.FF)
        "SCALING_SPEED,15"
        "AIRSPEED_MIN,15"
        "AIRSPEED_MAX,15"
        "LIM_ROLL_CD,4500"
        "KFF_RDDRMIX,0"
        "FLTMODE1,5"
        "# FLTMODE1=5 is FBWA. AIRSPEED_MIN=SCALING_SPEED keeps scaler ~1 without IAS."
        ];

    fid = fopen(out_path, "w");
    if fid < 0
        error("write_plane_roll_parm:OpenFailed", "Cannot write %s", out_path);
    end
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, "%s\n", lines);
    fprintf("Wrote %s\n", out_path);
end
