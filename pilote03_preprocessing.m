clear
clc

%% Prepare paths and regexp

mainPath = [ pwd filesep 'img'];

subjectDirs = get_subdir_regex(mainPath,'Pilote03');
% suj = get_subdir_regex(chemin);
%to see the content
% char(subjectDirs)

%functional and anatomic subdir
par.dfonc_reg='';
par.dfonc_reg_oposit_phase = '';
par.danat_reg='';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

% dfonc = get_subdir_regex_multi(suj,par.dfonc_reg) % ; char(dfonc{:})
% dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)% ; char(dfonc_op{:})
% dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })% ; char(dfoncall{:})
% anat = get_subdir_regex_one(suj,par.danat_reg)% ; char(anat) %should be no warning

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

examArray = exam(mainPath,'Pilote03');

% T1
examArray.addSerie('mprage_0_8iso_p2$','anat',1)
examArray.addVolume('anat','^s.*nii','s',1)

% SEQ
examArray.addSerie('SOMA_MOUTH_AIR$'      , 'SOMA_MOUTH_AIR'      ,1)
examArray.addSerie('SOMA_MOUTH_AIR_AP$'   , 'SOMA_MOUTH_AIR_AP'   ,1) % refAP
examArray.addSerie('SOMA_TOE_AIR$'        , 'SOMA_TOE_AIR'        ,1)
examArray.addSerie('SOMA_TOE_AIR_AP$'     , 'SOMA_TOE_AIR_AP'     ,1) % refAP
examArray.addSerie('SOMA_TOE_MEMBRANE$'   , 'SOMA_TOE_MEMBRANE'   ,1)
examArray.addSerie('SOMA_TOE_MEMBRANE_AP$', 'SOMA_TOE_MEMBRANE_AP',1) % refAP


% All func volumes
examArray.getSerie('SOMA').addVolume('^f.*nii','f',1)

% Unzip if necessary
examArray.unzipVolume

examArray.reorderSeries('name'); % mostly useful for topup, that requires pairs of (AP,PA)/(PA,AP) scans

examArray.explore

regex_dfonc    = 'SOMA_.*[^AP]$';
regex_dfonc_op =          'AP$';
dfonc    = examArray.getSerie(regex_dfonc   ).toJob
dfonc_op = examArray.getSerie(regex_dfonc_op).toJob
dfoncall = examArray.getSerie('SOMA'         ).toJob
anat     = examArray.getSerie('anat'        ).toJob(0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0 = tic;


%% Segment anat

% %anat segment
% % anat = get_subdir_regex(suj,par.danat_reg)
% fanat = get_subdir_regex_files(anat,par.anat_file_reg,1)
% 
% par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space dartel / import
% par.WM   = [0 0 1 0];
% j_segment = job_do_segment(fanat,par)
% 
% %apply normalize on anat
% fy = get_subdir_regex_files(anat,'^y',1)
% fanat = get_subdir_regex_files(anat,'^ms',1)
% j_apply_normalise=job_apply_normalize(fy,fanat,par)

%anat segment
fanat = examArray.getSerie('anat').getVolume('^s').toJob

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [0 0 1 0];
j_segment = job_do_segment(fanat,par)
fy    = examArray.getSerie('anat').addVolume('^y' ,'y' )
fanat = examArray.getSerie('anat').addVolume('^ms','ms')
fy_end    = examArray.getSerie('anat_end').addVolume('^y' ,'y' )
fanat_end = examArray.getSerie('anat_end').addVolume('^ms','ms')

%apply normalize on anat
j_apply_normalise=job_apply_normalize(fy,fanat,par)
examArray.getSerie('anat').addVolume('^wms','wms',1)


%% Brain extract

% ff=get_subdir_regex_files(anat,'^c[123]',3);
% fo=addsuffixtofilenames(anat,'/mask_brain');
% do_fsl_add(ff,fo)
% fm=get_subdir_regex_files(anat,'^mask_b',1); fanat=get_subdir_regex_files(anat,'^s.*nii',1);
% fo = addprefixtofilenames(fanat,'brain_');
% do_fsl_mult(concat_cell(fm,fanat),fo);

ff=examArray.getSerie('anat').addVolume('^c[123]','c',3)
fo=addsuffixtofilenames(anat{1}(1,:),'/mask_brain');
do_fsl_add(ff,fo)

fm=examArray.getSerie('anat').addVolume('^mask_b','mask_brain',1)
fanat=examArray.getSerie('anat').getVolume('^s').toJob
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);
examArray.getSerie('anat').addVolume('^brain_','brain_',1)


%% Preprocess fMRI runs

%realign and reslice
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice = job_realign(dfonc,par)
examArray.getSerie(regex_dfonc).addVolume('^rf','rf',1)

%realign and reslice opposite phase
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice_op = job_realign(dfonc_op,par)
examArray.getSerie(regex_dfonc_op).addVolume('^rf','rf',1)

%topup and unwarp
par.file_reg = {'^rf.*nii'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)
examArray.getSerie('SOMA').addVolume('^utmeanf','utmeanf',1)
examArray.getSerie('SOMA').addVolume('^utrf.*nii','utrf',1)

%coregister mean fonc on brain_anat
% fanat = get_subdir_regex_files(anat,'^s.*nii$',1) % raw anat
% fanat = get_subdir_regex_files(anat,'^ms.*nii$',1) % raw anat + signal bias correction
% fanat = get_subdir_regex_files(anat,'^brain_s.*nii$',1) % brain mask applied (not perfect, there are holes in the mask)
fanat = examArray.getSerie('anat').getVolume('^brain_').toJob

par.type = 'estimate';
for nbs=1:length(subjectDirs)
    fmean(nbs) = examArray.getSerie('SOMA_MOUTH_AIR$').getVolume('^utmeanf').toJob
end

fo = examArray.getSerie(regex_dfonc).getVolume('^utrf').toJob
j_coregister=job_coregister(fmean,fanat,fo,par)

%apply normalize
fy = examArray.getSerie('anat').getVolume('^y').toJob
j_apply_normalize=job_apply_normalize(fy,fo,par)

%smooth the data
ffonc = examArray.getSerie(regex_dfonc).addVolume('^wutrf','wutrf',1)
par.smooth = [8 8 8];
j_smooth=job_smooth(ffonc,par)
examArray.getSerie(regex_dfonc).addVolume('^swutrf','swutrf',1)

toc(t0)

save('exarr_orig','examArray') % always keep the original
save('exarr_stim','examArray') % work on this one

