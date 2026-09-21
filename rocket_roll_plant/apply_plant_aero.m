function apply_plant_aero()
%APPLY_PLANT_AERO Add L_aero = -b*p and L_control *= (V/V0)^2. Controller unchanged.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/q_scale") == -1
        delete_line(mdl, "Servo_Dynamics/1", "K_delta/1");
        add_block("simulink/Math Operations/Gain", mdl + "/q_scale", ...
            "Gain", "(V/V0)^2", "Position", [428 255 448 285]);
        add_line(mdl, "Servo_Dynamics/1", "q_scale/1");
        add_line(mdl, "q_scale/1", "K_delta/1");
    end

    if getSimulinkBlockHandle(mdl + "/L_aero") == -1
        add_block("simulink/Math Operations/Gain", mdl + "/L_aero", ...
            "Gain", "-b", "Position", [345 95 405 125]);
        set_param(mdl + "/L_net", "Inputs", "+++");
        add_line(mdl, "Roll_Rate_p/1", "L_aero/1");
        add_line(mdl, "L_aero/1", "L_net/3");
    end

    save_system(mdl);
    open_system(mdl);
    disp("Plant: L_net = L_dist + (V/V0)^2*K_delta*delta_actual - b*p");
end
