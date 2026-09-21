function apply_discrete_controller()
%APPLY_DISCRETE_CONTROLLER Sample p,phi at Ts; hold delta_cmd into continuous servo.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/p_sample") == -1
        delete_line(mdl, "Roll_Rate_p/1", "rate_error/2");
        add_block("simulink/Discrete/Zero-Order Hold", mdl + "/p_sample", ...
            "SampleTime", "Ts", "Position", [130 268 160 298]);
        add_line(mdl, "Roll_Rate_p/1", "p_sample/1");
        add_line(mdl, "p_sample/1", "rate_error/2");
    end

    if getSimulinkBlockHandle(mdl + "/phi_sample") == -1
        delete_line(mdl, "Roll_Angle_phi/1", "phi_error/2");
        add_block("simulink/Discrete/Zero-Order Hold", mdl + "/phi_sample", ...
            "SampleTime", "Ts", "Position", [130 328 160 358]);
        add_line(mdl, "Roll_Angle_phi/1", "phi_sample/1");
        add_line(mdl, "phi_sample/1", "phi_error/2");
    end

    ctrl = ["phi_cmd", "phi_error", "K_phi", "p_cmd_limit", ...
        "rate_error", "Kp", "delta_cmd_limit"];
    for k = 1:numel(ctrl)
        set_param(mdl + "/" + ctrl(k), "SampleTime", "Ts");
    end

    if getSimulinkBlockHandle(mdl + "/delta_cmd_zoh") == -1
        delete_line(mdl, "delta_cmd_limit/1", "Servo_Dynamics/1");
        if getSimulinkBlockHandle(mdl + "/delta_mux") ~= -1
            try
                delete_line(mdl, "delta_cmd_limit/1", "delta_mux/1");
            catch
            end
        end
        add_block("simulink/Signal Attributes/Rate Transition", ...
            mdl + "/delta_cmd_zoh", ...
            "OutPortSampleTime", "0", ...
            "Position", [342 258 352 282]);
        add_line(mdl, "delta_cmd_limit/1", "delta_cmd_zoh/1");
        add_line(mdl, "delta_cmd_zoh/1", "Servo_Dynamics/1");
        if getSimulinkBlockHandle(mdl + "/delta_mux") ~= -1
            add_line(mdl, "delta_cmd_zoh/1", "delta_mux/1");
        end
    end

    save_system(mdl);
    open_system(mdl);
    disp("Controller at Ts; ZOH sample p/phi; Rate Transition holds delta_cmd.");
end
