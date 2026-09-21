function apply_servo()
%APPLY_SERVO First-order servo: 1/(tau_s*s+1), plus Scope of cmd vs actual.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/delta_cmd_limit") == -1
        error("apply_servo:NeedDeltaSat", "Run apply_delta_cmd_limit first.");
    end

    if getSimulinkBlockHandle(mdl + "/Servo") ~= -1
        set_param(mdl + "/Servo", "Name", "Servo_Dynamics");
    end

    if getSimulinkBlockHandle(mdl + "/Servo_Dynamics") == -1
        delete_line(mdl, "delta_cmd_limit/1", "K_delta/1");
        add_block("simulink/Continuous/Transfer Fcn", mdl + "/Servo_Dynamics", ...
            "Numerator", "[1]", "Denominator", "[tau_s 1]", ...
            "Position", [355 248 425 292]);
        set_param(mdl + "/K_delta", "Position", [450 255 510 285]);
        add_line(mdl, "delta_cmd_limit/1", "Servo_Dynamics/1");
        add_line(mdl, "Servo_Dynamics/1", "K_delta/1");
    else
        set_param(mdl + "/Servo_Dynamics", ...
            "Numerator", "[1]", "Denominator", "[tau_s 1]");
    end

    if getSimulinkBlockHandle(mdl + "/Delta_Scope") == -1
        add_block("simulink/Sinks/Scope", mdl + "/Delta_Scope", ...
            "NumInputPorts", "2", "Position", [670 318 700 352]);
        add_line(mdl, "delta_cmd_limit/1", "Delta_Scope/1");
        add_line(mdl, "Servo_Dynamics/1", "Delta_Scope/2");
    end

    save_system(mdl);
    open_system(mdl);
    disp("Servo_Dynamics: 1/(tau_s*s+1); Delta_Scope shows cmd vs actual.");
end
