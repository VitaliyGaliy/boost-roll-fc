function apply_phi_integrator()
%APPLY_PHI_INTEGRATOR Add phi = int(p) dt and a Scope. No angle controller.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/Roll_Angle_phi") ~= -1
        disp("phi integrator already present.");
        open_system(mdl);
        return;
    end

    add_block("simulink/Continuous/Integrator", mdl + "/Roll_Angle_phi", ...
        "InitialCondition", "0", "Position", [575 250 605 280]);
    add_block("simulink/Sinks/Scope", mdl + "/Roll_Angle_Scope", ...
        "Position", [670 249 700 281]);

    add_line(mdl, "Roll_Rate_p/1", "Roll_Angle_phi/1");
    add_line(mdl, "Roll_Angle_phi/1", "Roll_Angle_Scope/1");

    save_system(mdl);
    open_system(mdl);
    disp("Added phi = int(p) dt and Roll_Angle_Scope. No angle loop.");
end
