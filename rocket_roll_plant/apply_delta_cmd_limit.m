function apply_delta_cmd_limit()
%APPLY_DELTA_CMD_LIMIT Saturate delta after Kp: |delta| <= delta_max.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/delta_cmd_limit") ~= -1
        disp("delta_cmd_limit already present.");
        open_system(mdl);
        return;
    end
    if getSimulinkBlockHandle(mdl + "/Kp") == -1
        error("apply_delta_cmd_limit:NeedRateP", "Run apply_rate_P first.");
    end

    delete_line(mdl, "Kp/1", "K_delta/1");
    add_block("simulink/Discontinuities/Saturation", mdl + "/delta_cmd_limit", ...
        "UpperLimit", "delta_max", "LowerLimit", "-delta_max", ...
        "Position", [312 253 338 287]);
    add_line(mdl, "Kp/1", "delta_cmd_limit/1");
    add_line(mdl, "delta_cmd_limit/1", "K_delta/1");

    save_system(mdl);
    open_system(mdl);
    disp("delta = sat(Kp*(p_cmd-p), +/- delta_max).");
end
