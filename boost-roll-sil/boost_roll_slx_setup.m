function boost_roll_slx_setup()
%BOOST_ROLL_SLX_SETUP Path + base-workspace params for BoostRollSIL.slx

    root = fileparts(mfilename("fullpath"));
    addpath(root);
    addpath(fullfile(root, "control"));
    addpath(fullfile(root, "plant"));
    addpath(fullfile(root, "sim"));
    addpath(fullfile(root, "plot"));

    assignin("base", "boost_p", params_vehicle());
    assignin("base", "boost_g", params_ardupilot());
end
