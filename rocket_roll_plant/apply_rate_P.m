function apply_rate_P()
%APPLY_RATE_P Close the loop: delta = Kp*(p_cmd - p), then K_delta.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/K_delta") == -1
        apply_delta_to_moment;
        load_system(mdl);
    end

    if getSimulinkBlockHandle(mdl + "/Kp") ~= -1
        disp("Rate P already present.");
        open_system(mdl);
        return;
    end

    if getSimulinkBlockHandle(mdl + "/delta") ~= -1
        delete_line(mdl, "delta/1", "K_delta/1");
        delete_block(mdl + "/delta");
    end

    add_block("simulink/Sources/Constant", mdl + "/p_cmd", ...
        "Value", "p_cmd", "Position", [80 250 140 280]);
    add_block("simulink/Math Operations/Sum", mdl + "/rate_error", ...
        "Inputs", "+-", "IconShape", "round", ...
        "Position", [175 248 205 282]);
    add_block("simulink/Math Operations/Gain", mdl + "/Kp", ...
        "Gain", "Kp", "Position", [230 250 290 280]);

    add_line(mdl, "p_cmd/1", "rate_error/1");
    add_line(mdl, "Roll_Rate_p/1", "rate_error/2");
    add_line(mdl, "rate_error/1", "Kp/1");
    add_line(mdl, "Kp/1", "K_delta/1");

    save_system(mdl);
    open_system(mdl);
    disp("Closed loop: delta = Kp*(p_cmd - p).");
end
