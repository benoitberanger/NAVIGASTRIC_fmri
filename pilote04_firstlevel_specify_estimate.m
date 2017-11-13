clear
clc

imgdir   = [ pwd filesep 'img'];
stimdirs = [ pwd filesep 'stim'];
pilote04dir = get_subdir_regex(stimdirs,'Pilote04');
load('exarr_stim.mat')


regex_dfonc    = '(EBA|MOTOR)$';
regex_dfonc_op = 'AP$';
regex_dfonall  = '(EBA)|(MOTOR)';


%% prepare first level : groupe 8

statdir=r_mkdir(examArray.toJob,'stat');

EBA_dir = r_mkdir(statdir,'EBA');
MOTOR_dir = r_mkdir(statdir,'MOTOR');
do_delete(EBA_dir,0)
do_delete(MOTOR_dir,0)
EBA_dir = r_mkdir(statdir,'EBA');
MOTOR_dir = r_mkdir(statdir,'MOTOR');


par.file_reg = '^swutrf.*nii';
par.TR=2.000;
par.delete_previous=1;
par.rp = 1; % realignment paramters : movement regressors
par.run = 1;
par.display = 0;


%% Specify model : prepare list of (run,stimfile)

 % EBA
dfunc_EBA = examArray.getSerie('EBA$').toJob;
filename = get_subdir_regex_files(pilote04dir,'Pilot_EBA_data_04_clean');
load(char(filename))
onset_EBA{1}(1).name = 'hand'  ; onset_EBA{1}(1).onset = EXP.onsets.onset_hand;  onset_EBA{1}(1).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_EBA{1}(2).name = 'trunk'  ; onset_EBA{1}(2).onset = EXP.onsets.onset_blink;  onset_EBA{1}(2).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_EBA{1}(3).name = 'mouth'  ; onset_EBA{1}(3).onset = EXP.onsets.onset_mouth;  onset_EBA{1}(3).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_EBA{1}(4).name = 'feet'  ; onset_EBA{1}(4).onset = EXP.onsets.onset_feet;  onset_EBA{1}(4).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_EBA{1}(5).name = 'chair'  ; onset_EBA{1}(5).onset = EXP.onsets.onset_chair;  onset_EBA{1}(5).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_EBA{1}(6).name = 'body'  ; onset_EBA{1}(6).onset = EXP.onsets.onset_body;  onset_EBA{1}(6).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>

 % MORTOR
dfunc_MOTOR = examArray.getSerie('MOTOR$').toJob;
filename = get_subdir_regex_files(pilote04dir,'Pilot_MOTOR_subject04_clean');
load(char(filename))
onset_MOTOR{1}(1).name = 'hand'  ; onset_MOTOR{1}(1).onset = EXP.onsets.onset_hand;  onset_MOTOR{1}(1).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_MOTOR{1}(2).name = 'rest'  ; onset_MOTOR{1}(2).onset = EXP.onsets.onset_blink;  onset_MOTOR{1}(2).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_MOTOR{1}(3).name = 'mouth'  ; onset_MOTOR{1}(3).onset = EXP.onsets.onset_mouth;  onset_MOTOR{1}(3).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>
onset_MOTOR{1}(4).name = 'feet'  ; onset_MOTOR{1}(4).onset = EXP.onsets.onset_feet;  onset_MOTOR{1}(4).duration = repmat(2,[1 length(EXP.onsets.onset_hand)]); %#ok<*SAGROW>

%% Specify model : job spm

j_specify_1 = job_first_level_specify(dfunc_EBA,EBA_dir,onset_EBA,par);
j_specify_2 = job_first_level_specify(dfunc_MOTOR,MOTOR_dir,onset_MOTOR,par);


%% Estimate model

fspm_EBA = get_subdir_regex_files(EBA_dir,'SPM',1);
j_estimate_1 = job_first_level_estimate(fspm_EBA,par);

fspm_MOTOR = get_subdir_regex_files(MOTOR_dir,'SPM',1);
j_estimate_2 = job_first_level_estimate(fspm_MOTOR,par);
