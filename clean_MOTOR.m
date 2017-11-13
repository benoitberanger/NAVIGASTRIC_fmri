clear
clc

% original = load('/mnt/data/benoit/Protocol/NAVIGASTRIC/fmri/stim/2017_11_13_NAVIGASTRIC_Pilote04/Pilot_MOTOR_subject04.mat')
load('/mnt/data/benoit/Protocol/NAVIGASTRIC/fmri/stim/2017_11_13_NAVIGASTRIC_Pilote04/Pilot_MOTOR_subject04.mat')

limit = EXP.onsets.onsetTrial(141);

for name = {'onset_hand', 'onset_blink', 'onset_mouth', 'onset_feet',}

idx = EXP.onsets.(name{1}) > limit;
EXP.onsets.(name{1})(idx) = EXP.onsets.(name{1})(idx) + abs(EXP.timeafterpause);

end

save('/mnt/data/benoit/Protocol/NAVIGASTRIC/fmri/stim/2017_11_13_NAVIGASTRIC_Pilote04/Pilot_MOTOR_subject04_clean.mat')
