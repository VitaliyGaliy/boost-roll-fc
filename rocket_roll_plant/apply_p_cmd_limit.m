function apply_p_cmd_limit()
%APPLY_P_CMD_LIMIT Saturate p_cmd after K_phi: |p_cmd| <= p_max.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/p_cmd_limit") ~= -1
        disp("p_cmd_limit already present.");
        open_system(mdl);
        return;
    end
    if getSimulinkBlockHandle(mdl + "/K_phi") == -1
        error("apply_p_cmd_limit:NeedAngleP", "Run apply_angle_P first.");
    end

    delete_line(mdl, "K_phi/1", "rate_error/1");
    add_block("simulink/Discontinuities/Saturation", mdl + "/p_cmd_limit", ...
        "UpperLimit", "p_max", "LowerLimit", "-p_max", ...
        "Position", [305 308 365 342]);
    add_line(mdl, "K_phi/1", "p_cmd_limit/1");
    add_line(mdl, "p_cmd_limit/1", "rate_error/1");

    save_system(mdl);
    open_system(mdl);
    disp("p_cmd = sat(K_phi*(phi_cmd-phi), +/- p_max).");
end
