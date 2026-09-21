function apply_L_dist_pulse()
%APPLY_L_DIST_PULSE Replace lasting Step L_dist with a short pulse.
%   On for 2 s starting at t = 1 s, then zero until StopTime.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    load_system(mdl);
    blk = mdl + "/L_dist";
    if getSimulinkBlockHandle(blk) == -1
        error("apply_L_dist_pulse:MissingLdist", "Block L_dist not found.");
    end
    bt = get_param(blk, "BlockType");
    if bt ~= "Step"
        disp("L_dist is already not a Step (" + string(bt) + ").");
        open_system(mdl);
        return;
    end
    pos = get_param(blk, "Position");
    delete_block(blk);
    add_block("simulink/Sources/Pulse Generator", blk, "Position", pos);
    set_param(blk, ...
        "PulseType", "Time based", ...
        "Amplitude", "0.01", ...
        "Period", "10", ...
        "PulseWidth", "20", ...
        "PhaseDelay", "1");
    save_system(mdl);
    open_system(mdl);
    disp("L_dist is a pulse: 0.01 N*m from t=1 s to t=3 s, then 0.");
end
