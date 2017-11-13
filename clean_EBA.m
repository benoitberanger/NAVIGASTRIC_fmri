clear
clc

load('/mnt/data/benoit/Protocol/NAVIGASTRIC/fmri/stim/2017_11_13_NAVIGASTRIC_Pilote04/Pilot_EBA_data_04.mat')

limit = EXP.onsets.onsetTrial(181);

for name = {'onset_hand', 'onset_blink', 'onset_mouth', 'onset_feet', 'onset_chair', 'onset_body'}

idx = EXP.onsets.(name{1}) > limit;
EXP.onsets.(name{1})(idx) = EXP.onsets.(name{1})(idx) + abs(EXP.timeafterpause);

end

save('/mnt/data/benoit/Protocol/NAVIGASTRIC/fmri/stim/2017_11_13_NAVIGASTRIC_Pilote04/Pilot_EBA_data_04_clean.mat')
