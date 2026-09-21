function apply_delta_scope()
%APPLY_DELTA_SCOPE Overlay delta_cmd and delta_actual on one Scope.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/Servo_Dynamics") == -1
        error("apply_delta_scope:NeedServo", "Run apply_servo first.");
    end

    if getSimulinkBlockHandle(mdl + "/delta_mux") == -1
        if getSimulinkBlockHandle(mdl + "/Delta_Scope") ~= -1
            try
                delete_line(mdl, "delta_cmd_limit/1", "Delta_Scope/1");
            catch
            end
            try
                delete_line(mdl, "Servo_Dynamics/1", "Delta_Scope/2");
            catch
            end
        else
            add_block("simulink/Sinks/Scope", mdl + "/Delta_Scope", ...
                "Position", [670 318 700 352]);
        end
        add_block("simulink/Signal Routing/Mux", mdl + "/delta_mux", ...
            "Inputs", "2", "Position", [545 318 550 352]);
        add_line(mdl, "delta_cmd_limit/1", "delta_mux/1");
        add_line(mdl, "Servo_Dynamics/1", "delta_mux/2");
        set_param(mdl + "/Delta_Scope", "NumInputPorts", "1");
        add_line(mdl, "delta_mux/1", "Delta_Scope/1");
    end

    set_param(get_param(mdl + "/delta_cmd_limit", "LineHandles").Outport, ...
        "Name", "delta_cmd");
    set_param(get_param(mdl + "/Servo_Dynamics", "LineHandles").Outport, ...
        "Name", "delta_actual");
    set_param(mdl + "/Delta_Scope", "OpenAtSimulationStart", "on");

    save_system(mdl);
    open_system(mdl);
    open_system(mdl + "/Delta_Scope");
    disp("Delta_Scope: overlay delta_cmd (in1) and delta_actual (in2).");
end
