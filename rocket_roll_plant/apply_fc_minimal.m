function apply_fc_minimal()
%APPLY_FC_MINIMAL Gyro p_meas path + ArduPlane-style rate PID+FF. Plant gains unchanged.
    here = fileparts(mfilename("fullpath"));
    cd(here);
    init_roll_model;
    mdl = "rocket_roll_plant";
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    load_system(mdl);

    if getSimulinkBlockHandle(mdl + "/p_sample") == -1
        error("apply_fc_minimal:NeedSample", "Need p_sample (discrete controller) first.");
    end

    %% 1) Gyro: p_true -> p_meas -> sample/delay (scopes/L_aero stay on p_true)
    if getSimulinkBlockHandle(mdl + "/Gyro") == -1
        delete_line(mdl, "Roll_Rate_p/1", "p_sample/1");
        add_block("simulink/Math Operations/Gain", mdl + "/Gyro", ...
            "Gain", "1", "Position", [95 268 125 298]);
        add_line(mdl, "Roll_Rate_p/1", "Gyro/1");
        add_line(mdl, "Gyro/1", "p_sample/1");
        set_param(get_param(mdl + "/Gyro", "LineHandles").Outport, "Name", "p_meas");
    end

    %% 2) Replace inner Kp with P+I+D+FF, output sat already at delta_cmd_limit
    if getSimulinkBlockHandle(mdl + "/Kp") ~= -1
        delete_line(mdl, "rate_error/1", "Kp/1");
        delete_line(mdl, "Kp/1", "delta_cmd_limit/1");
        delete_block(mdl + "/Kp");
    end

    if getSimulinkBlockHandle(mdl + "/Rate_P") == -1
        add_block("simulink/Math Operations/Gain", mdl + "/Rate_P", ...
            "Gain", "Rate_P", "SampleTime", "Ts", ...
            "Position", [215 218 255 242]);
        add_block("simulink/Math Operations/Gain", mdl + "/Rate_D", ...
            "Gain", "Rate_D/Ts", "SampleTime", "Ts", ...
            "Position", [255 248 305 272]);
        add_block("simulink/Discrete/Unit Delay", mdl + "/rate_e_z1", ...
            "SampleTime", "Ts", "InitialCondition", "0", ...
            "Position", [215 248 245 272]);
        add_block("simulink/Math Operations/Sum", mdl + "/rate_d_diff", ...
            "Inputs", "+-", "SampleTime", "Ts", ...
            "Position", [250 238 270 282]);
        add_block("simulink/Math Operations/Gain", mdl + "/Rate_I", ...
            "Gain", "Rate_I", "SampleTime", "Ts", ...
            "Position", [215 288 255 312]);
        add_block("simulink/Signal Routing/Switch", mdl + "/I_aw_switch", ...
            "Criteria", "u2 ~= 0", "InputSameDT", "off", ...
            "Position", [270 278 300 322]);
        add_block("simulink/Sources/Constant", mdl + "/I_aw_zero", ...
            "Value", "0", "SampleTime", "Ts", "Position", [215 318 245 342]);
        add_block("simulink/Discrete/Discrete-Time Integrator", mdl + "/Rate_I_acc", ...
            "SampleTime", "Ts", "gainval", "1", ...
            "LimitOutput", "on", ...
            "UpperSaturationLimit", "Rate_Imax", ...
            "LowerSaturationLimit", "-Rate_Imax", ...
            "Position", [315 288 345 318]);
        add_block("simulink/Math Operations/Gain", mdl + "/Rate_FF", ...
            "Gain", "Rate_FF", "SampleTime", "Ts", ...
            "Position", [215 188 255 212]);
        add_block("simulink/Math Operations/Sum", mdl + "/rate_u", ...
            "Inputs", "++++", "SampleTime", "Ts", ...
            "Position", [365 220 395 310]);
        add_block("simulink/Math Operations/Abs", mdl + "/u_abs", ...
            "SampleTime", "Ts", "Position", [410 330 430 350]);
        add_block("simulink/Logic and Bit Operations/Compare To Constant", ...
            mdl + "/u_at_stop", "relop", ">=", "const", "delta_max", ...
            "Position", [445 328 490 352]);
        add_block("simulink/Discrete/Unit Delay", mdl + "/aw_hold", ...
            "SampleTime", "Ts", "InitialCondition", "0", ...
            "Position", [505 328 535 352]);

        add_line(mdl, "rate_error/1", "Rate_P/1");
        add_line(mdl, "rate_error/1", "rate_e_z1/1");
        add_line(mdl, "rate_error/1", "rate_d_diff/1");
        add_line(mdl, "rate_e_z1/1", "rate_d_diff/2");
        add_line(mdl, "rate_d_diff/1", "Rate_D/1");
        add_line(mdl, "rate_error/1", "Rate_I/1");
        add_line(mdl, "Rate_I/1", "I_aw_switch/1");
        add_line(mdl, "aw_hold/1", "I_aw_switch/2");
        add_line(mdl, "I_aw_zero/1", "I_aw_switch/3");
        add_line(mdl, "I_aw_switch/1", "Rate_I_acc/1");
        add_line(mdl, "p_cmd_limit/1", "Rate_FF/1");
        add_line(mdl, "Rate_P/1", "rate_u/1");
        add_line(mdl, "Rate_I_acc/1", "rate_u/2");
        add_line(mdl, "Rate_D/1", "rate_u/3");
        add_line(mdl, "Rate_FF/1", "rate_u/4");
        add_line(mdl, "rate_u/1", "delta_cmd_limit/1");
        add_line(mdl, "rate_u/1", "u_abs/1");
        add_line(mdl, "u_abs/1", "u_at_stop/1");
        add_line(mdl, "u_at_stop/1", "aw_hold/1");
    end

    save_system(mdl);
    open_system(mdl);
    disp("FC freeze: Gyro p_meas; inner Rate P+I+D+FF + I clamp/AW; plant coeffs unchanged.");
end
