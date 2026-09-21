function apply_meas_delay()
%APPLY_MEAS_DELAY One-sample Unit Delay after p_sample and phi_sample.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/p_sample") == -1 || ...
            getSimulinkBlockHandle(mdl + "/phi_sample") == -1
        error("apply_meas_delay:NeedSample", "Run apply_discrete_controller first.");
    end

    if getSimulinkBlockHandle(mdl + "/p_delay") == -1
        delete_line(mdl, "p_sample/1", "rate_error/2");
        add_block("simulink/Discrete/Unit Delay", mdl + "/p_delay", ...
            "SampleTime", "Ts", "InitialCondition", "0", ...
            "Position", [165 272 195 298]);
        add_line(mdl, "p_sample/1", "p_delay/1");
        add_line(mdl, "p_delay/1", "rate_error/2");
    end

    if getSimulinkBlockHandle(mdl + "/phi_delay") == -1
        delete_line(mdl, "phi_sample/1", "phi_error/2");
        add_block("simulink/Discrete/Unit Delay", mdl + "/phi_delay", ...
            "SampleTime", "Ts", "InitialCondition", "0", ...
            "Position", [165 332 195 358]);
        add_line(mdl, "phi_sample/1", "phi_delay/1");
        add_line(mdl, "phi_delay/1", "phi_error/2");
    end

    save_system(mdl);
    open_system(mdl);
    disp("Feedback: p_used=p[k-1], phi_used=phi[k-1] at Ts.");
end
