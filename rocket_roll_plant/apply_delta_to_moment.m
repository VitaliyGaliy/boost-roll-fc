function apply_delta_to_moment()
%APPLY_DELTA_TO_MOMENT Replace raw L_control constant with K_delta * delta.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/K_delta") ~= -1
        disp("K_delta already present.");
        open_system(mdl);
        return;
    end

    if getSimulinkBlockHandle(mdl + "/L_control") ~= -1
        delete_line(mdl, "L_control/1", "L_net/2");
        delete_block(mdl + "/L_control");
    end

    add_block("simulink/Sources/Constant", mdl + "/delta", ...
        "Value", "delta", "Position", [300 255 360 285]);
    add_block("simulink/Math Operations/Gain", mdl + "/K_delta", ...
        "Gain", "K_delta", "Position", [385 255 445 285]);
    add_line(mdl, "delta/1", "K_delta/1");
    add_line(mdl, "K_delta/1", "L_net/2");
    save_system(mdl);
    open_system(mdl);
    disp("Wired L_control = K_delta * delta.");
end
