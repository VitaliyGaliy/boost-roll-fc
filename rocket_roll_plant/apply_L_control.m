function apply_L_control()
%APPLY_L_CONTROL Add L_control + L_net to rocket_roll_plant (once).
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    load_system(mdl);
    if getSimulinkBlockHandle(mdl + "/L_net") ~= -1
        disp("L_net already present.");
        open_system(mdl);
        return;
    end
    delete_line(mdl, "L_dist/1", "1_Ix/1");
    add_block("simulink/Sources/Constant", mdl + "/L_control", ...
        "Value", "L_control", "Position", [385 255 445 285]);
    add_block("simulink/Math Operations/Sum", mdl + "/L_net", ...
        "Inputs", "++", "IconShape", "round", ...
        "Position", [445 187 475 233]);
    add_line(mdl, "L_dist/1", "L_net/1");
    add_line(mdl, "L_control/1", "L_net/2");
    add_line(mdl, "L_net/1", "1_Ix/1");
    save_system(mdl);
    open_system(mdl);
    disp("Added L_control and L_net.");
end
