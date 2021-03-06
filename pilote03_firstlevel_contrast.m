clear
clc

imgdir   = [ pwd filesep 'img'];
% stimdirs = [ pwd filesep 'stim'];
load('exarr_stim.mat')

regex_dfonc    = 'SOMA_.*[^AP]$';
regex_dfonc_op =          'AP$';

statdir = get_subdir_regex(examArray.toJob,'stat');
SOMA_dir = get_subdir_regex(statdir,'SOMA');
fspm = get_subdir_regex_files(SOMA_dir,'SPM',1);

par.delete_previous=1;
par.run = 1;
par.display = 0;
par.sessrep = 'none';


%% Define contrasts

% Tap

rp = [0 0 0 0 0 0];

% 2 conditions for each run
null    = [0 0 rp];
rest    = [1 0 rp];
action  = [0 1 rp];
% T-contrast

contrast(1).names_T = {
    
'MOUTH_AIR     : action-rest'
'TOE_AIR       : action-rest'
'TOE_MEMEBRANE : action-rest'

'TOE           : action-rest'

}';

contrast(1).values_T = {
    
[action-rest null null] 
[null action-rest  null] 
[null null action-rest ] 

[null action-rest action-rest]

}';

contrast(1).types_T = cat(1,repmat({'T'},[1 length(contrast(1).names_T)]));

% F-contrast
contrast(1).names_F = {}';
contrast(1).values_F = {}';
contrast(1).types_F = cat(1,repmat({'F'},[1 length(contrast(1).names_F)]));

% Combine F and T
contrast(1).names = [contrast(1).names_T contrast(1).names_F];
contrast(1).values = [contrast(1).values_T contrast(1).values_F];
contrast(1).types = [contrast(1).types_T contrast(1).types_F];



%% Estimate contrast

par.sessrep = 'none';

j_contrast = job_first_level_contrast(fspm,contrast,par);


%% Show results

matlabbatch{1}.spm.stats.results.spmmat = fspm(1);
matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'FWE';
matlabbatch{1}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{1}.spm.stats.results.conspec.extent = 10;
matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{1}.spm.stats.results.units = 1;
matlabbatch{1}.spm.stats.results.print = false;
matlabbatch{1}.spm.stats.results.write.none = 1;

spm_jobman('run',matlabbatch)
