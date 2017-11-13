clear
clc

imgdir   = [ pwd filesep 'img'];
% stimdirs = [ pwd filesep 'stim'];
load('exarr_stim.mat')

regex_dfonc    = 'SOMA_.*[^AP]$';
regex_dfonc_op =          'AP$';


%% Fetch stim files

% examArray.getSerie(regex_dfonc).print
% examArray.getSerie('SEQ_run1$').addStim(stimdirs,'Motor_MRI_1_SPM','SEQ_run1',1)
% examArray.getSerie('SEQ_run2$').addStim(stimdirs,'Motor_MRI_2_SPM','SEQ_run2',1)

% save('exarr_stim','examArray') % work on this one

% examArray.explore

%% prepare first level : groupe 8

statdir=r_mkdir(examArray.toJob,'stat');

SOMA_dir = r_mkdir(statdir,'SOMA');
do_delete(SOMA_dir,0)
SOMA_dir = r_mkdir(statdir,'SOMA');


par.file_reg = '^swutrf.*nii';
par.TR=2.000;
par.delete_previous=1;
par.rp = 1; % realignment paramters : movement regressors
par.run = 1;
par.display = 0;


%% Specify model : prepare list of (run,stimfile)

for b = 1 : 3
    onset{b}(1).name = 'rest'  ; onset{b}(1).onset = 0:2*16:656;  onset{b}(1).duration = repmat(16,[1 21]); %#ok<*SAGROW>
    onset{b}(2).name = 'action'; onset{b}(2).onset = 16:2*16:640; onset{b}(2).duration = repmat(16,[1 20]);
end

dfunc_SOMA = examArray.getSerie(regex_dfonc).toJob;
% stim_SOMA  = examArray.getSerie('SEQ_run\d$').getStim.toJob;


%% Specify model : job spm

j_specify_1 = job_first_level_specify(dfunc_SOMA,SOMA_dir,onset,par);


%% Estimate model

fspm = get_subdir_regex_files(SOMA_dir,'SPM',1);
j_estimate = job_first_level_estimate(fspm,par);

