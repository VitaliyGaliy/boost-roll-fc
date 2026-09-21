function apply_angle_P()
%APPLY_ANGLE_P Outer P: p_cmd = K_phi * (phi_cmd - phi). Inner rate loop unchanged.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);  % discard unsaved in-memory edits; keep disk file
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/K_phi") ~= -1
        disp("Angle P already present.");
        open_system(mdl);
        return;
    end
    if getSimulinkBlockHandle(mdl + "/Roll_Angle_phi") == -1
        error("apply_angle_P:NeedPhi", "Run apply_phi_integrator first.");
    end

    if getSimulinkBlockHandle(mdl + "/p_cmd") ~= -1
        delete_line(mdl, "p_cmd/1", "rate_error/1");
        delete_block(mdl + "/p_cmd");
    end

    add_block("simulink/Sources/Constant", mdl + "/phi_cmd", ...
        "Value", "phi_cmd", "Position", [75 310 135 340]);
    add_block("simulink/Math Operations/Sum", mdl + "/phi_error", ...
        "Inputs", "+-", "IconShape", "round", ...
        "Position", [175 308 205 342]);
    add_block("simulink/Math Operations/Gain", mdl + "/K_phi", ...
        "Gain", "K_phi", "Position", [230 310 290 340]);

    add_line(mdl, "phi_cmd/1", "phi_error/1");
    add_line(mdl, "Roll_Angle_phi/1", "phi_error/2");
    add_line(mdl, "phi_error/1", "K_phi/1");
    add_line(mdl, "K_phi/1", "rate_error/1");

    save_system(mdl);
    open_system(mdl);
    disp("Outer angle P: p_cmd = K_phi*(phi_cmd - phi).");
end
