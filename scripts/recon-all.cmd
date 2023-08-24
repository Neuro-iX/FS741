

#---------------------------------
# New invocation of recon-all Fri Aug 18 12:09:54 EDT 2023 

 mri_convert /home/bverreman/Desktop/HCP_Files_BV_SB/101915/101915/T1w_acpc_dc_restore.nii.gz /home/bverreman/Desktop/test2_high_res/mri/orig/001.mgz 

#--------------------------------------------
#@# MotionCor Fri Aug 18 12:10:03 EDT 2023

 cp /home/bverreman/Desktop/test2_high_res/mri/orig/001.mgz /home/bverreman/Desktop/test2_high_res/mri/rawavg.mgz 


 mri_info /home/bverreman/Desktop/test2_high_res/mri/rawavg.mgz 


 mri_convert /home/bverreman/Desktop/test2_high_res/mri/rawavg.mgz /home/bverreman/Desktop/test2_high_res/mri/orig.mgz --conform_min 


 mri_add_xform_to_header -c /home/bverreman/Desktop/test2_high_res/mri/transforms/talairach.xfm /home/bverreman/Desktop/test2_high_res/mri/orig.mgz /home/bverreman/Desktop/test2_high_res/mri/orig.mgz 


 mri_info /home/bverreman/Desktop/test2_high_res/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Fri Aug 18 12:10:16 EDT 2023

 mri_nu_correct.mni --no-rescale --i orig.mgz --o orig_nu.mgz --ants-n4 --n 1 --proto-iters 1000 --distance 50 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 

talairach_avi log file is transforms/talairach_avi.log...

 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

lta_convert --src orig.mgz --trg /usr/local/freesurfer/7.4.1/average/mni305.cor.mgz --inxfm transforms/talairach.xfm --outlta transforms/talairach.xfm.lta --subject fsaverage --ltavox2vox
#--------------------------------------------
#@# Talairach Failure Detection Fri Aug 18 12:16:51 EDT 2023

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /usr/local/freesurfer/7.4.1/bin/extract_talairach_avi_QA.awk /home/bverreman/Desktop/test2_high_res/mri/transforms/talairach_avi.log 


 tal_QC_AZS /home/bverreman/Desktop/test2_high_res/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Fri Aug 18 12:16:51 EDT 2023

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --cm --n 2 --ants-n4 


 mri_add_xform_to_header -c /home/bverreman/Desktop/test2_high_res/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Fri Aug 18 12:23:15 EDT 2023

 mri_normalize -g 1 -seed 1234 -mprage -noconform nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Fri Aug 18 12:28:02 EDT 2023

 mri_em_register -skull nu.mgz /usr/local/freesurfer/7.4.1/average/RB_all_withskull_2020_01_02.gca transforms/talairach_with_skull.lta 


 mri_watershed -T1 -brain_atlas /usr/local/freesurfer/7.4.1/average/RB_all_withskull_2020_01_02.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Fri Aug 18 12:40:23 EDT 2023

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /usr/local/freesurfer/7.4.1/average/RB_all_2020-01-02.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Fri Aug 18 12:55:37 EDT 2023

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /usr/local/freesurfer/7.4.1/average/RB_all_2020-01-02.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Fri Aug 18 12:57:35 EDT 2023

 mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /usr/local/freesurfer/7.4.1/average/RB_all_2020-01-02.gca transforms/talairach.m3z 

#--------------------------------------
#@# SubCort Seg Fri Aug 18 14:49:42 EDT 2023

 mri_ca_label -relabel_unlikely 9 .3 -prior 0.5 -align norm.mgz transforms/talairach.m3z /usr/local/freesurfer/7.4.1/average/RB_all_2020-01-02.gca aseg.auto_noCCseg.mgz 

#--------------------------------------
#@# CC Seg Fri Aug 18 16:27:16 EDT 2023

 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /home/bverreman/Desktop/test2_high_res/mri/transforms/cc_up.lta test2_high_res 

#--------------------------------------
#@# Merge ASeg Fri Aug 18 16:28:13 EDT 2023

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Fri Aug 18 16:28:13 EDT 2023

 mri_normalize -seed 1234 -mprage -noconform -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Fri Aug 18 16:34:52 EDT 2023

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Fri Aug 18 16:34:55 EDT 2023

 AntsDenoiseImageFs -i brain.mgz -o antsdn.brain.mgz 


 mri_segment -wsizemm 13 -mprage antsdn.brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Fri Aug 18 16:41:03 EDT 2023

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.presurf.mgz -ctab /usr/local/freesurfer/7.4.1/SubCorticalMassLUT.txt wm.mgz filled.mgz 

 cp filled.mgz filled.auto.mgz
#--------------------------------------------
#@# Tessellate lh Fri Aug 18 16:43:35 EDT 2023

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix.predec 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix.predec ../surf/lh.orig.nofix.predec 


 mris_remesh --desired-face-area 0.5 --input ../surf/lh.orig.nofix.predec --output ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Fri Aug 18 16:44:12 EDT 2023

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix.predec 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix.predec ../surf/rh.orig.nofix.predec 


 mris_remesh --desired-face-area 0.5 --input ../surf/rh.orig.nofix.predec --output ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Fri Aug 18 16:44:46 EDT 2023

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Fri Aug 18 16:44:49 EDT 2023

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Fri Aug 18 16:44:53 EDT 2023

 mris_inflate -no-save-sulc -n 100 ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Fri Aug 18 16:50:45 EDT 2023

 mris_inflate -no-save-sulc -n 100 ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Fri Aug 18 16:56:24 EDT 2023

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Fri Aug 18 16:59:08 EDT 2023

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#@# Fix Topology lh Fri Aug 18 17:01:51 EDT 2023

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 test2_high_res lh 

#@# Fix Topology rh Fri Aug 18 17:04:14 EDT 2023

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 test2_high_res rh 


 mris_euler_number ../surf/lh.orig.premesh 


 mris_euler_number ../surf/rh.orig.premesh 


 mris_remesh --remesh --iters 3 --input /home/bverreman/Desktop/test2_high_res/surf/lh.orig.premesh --output /home/bverreman/Desktop/test2_high_res/surf/lh.orig 


 mris_remesh --remesh --iters 3 --input /home/bverreman/Desktop/test2_high_res/surf/rh.orig.premesh --output /home/bverreman/Desktop/test2_high_res/surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm -f ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm -f ../surf/rh.inflated 

#--------------------------------------------
#@# AutoDetGWStats lh Fri Aug 18 17:08:40 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.lh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/lh.orig.premesh
#--------------------------------------------
#@# AutoDetGWStats rh Fri Aug 18 17:08:49 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.rh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/rh.orig.premesh
#--------------------------------------------
#@# WhitePreAparc lh Fri Aug 18 17:08:58 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --wm wm.mgz --threads 1 --invol brain.finalsurfs.mgz --lh --i ../surf/lh.orig --o ../surf/lh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# WhitePreAparc rh Fri Aug 18 17:14:44 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --wm wm.mgz --threads 1 --invol brain.finalsurfs.mgz --rh --i ../surf/rh.orig --o ../surf/rh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# CortexLabel lh Fri Aug 18 17:20:38 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 0 ../label/lh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg lh Fri Aug 18 17:20:57 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 1 ../label/lh.cortex+hipamyg.label
#--------------------------------------------
#@# CortexLabel rh Fri Aug 18 17:21:15 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 0 ../label/rh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg rh Fri Aug 18 17:21:36 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 1 ../label/rh.cortex+hipamyg.label
#--------------------------------------------
#@# Smooth2 lh Fri Aug 18 17:21:55 EDT 2023

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Fri Aug 18 17:22:01 EDT 2023

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Fri Aug 18 17:22:06 EDT 2023

 mris_inflate -n 100 ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Fri Aug 18 17:23:00 EDT 2023

 mris_inflate -n 100 ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Fri Aug 18 17:23:53 EDT 2023

 mris_curvature -w -seed 1234 lh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Fri Aug 18 17:24:55 EDT 2023

 mris_curvature -w -seed 1234 rh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 

#--------------------------------------------
#@# Sphere lh Fri Aug 18 17:25:58 EDT 2023

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Mon Aug 21 10:20:06 EDT 2023

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Mon Aug 21 10:25:03 EDT 2023

 mris_register -curv ../surf/lh.sphere /usr/local/freesurfer/7.4.1/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 


 ln -sf lh.sphere.reg lh.fsaverage.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Mon Aug 21 10:34:26 EDT 2023

 mris_register -curv ../surf/rh.sphere /usr/local/freesurfer/7.4.1/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 


 ln -sf rh.sphere.reg rh.fsaverage.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Mon Aug 21 10:44:52 EDT 2023

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Mon Aug 21 10:44:54 EDT 2023

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Mon Aug 21 10:44:56 EDT 2023

 mrisp_paint -a 5 /usr/local/freesurfer/7.4.1/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Mon Aug 21 10:44:57 EDT 2023

 mrisp_paint -a 5 /usr/local/freesurfer/7.4.1/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Mon Aug 21 10:44:59 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Mon Aug 21 10:45:25 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# WhiteSurfs lh Mon Aug 21 10:45:42 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white.preaparc --o ../surf/lh.white --white --nsmooth 0 --rip-label ../label/lh.cortex.label --rip-bg --rip-surf ../surf/lh.white.preaparc --aparc ../label/lh.aparc.annot
#--------------------------------------------
#@# WhiteSurfs rh Mon Aug 21 10:50:22 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white.preaparc --o ../surf/rh.white --white --nsmooth 0 --rip-label ../label/rh.cortex.label --rip-bg --rip-surf ../surf/rh.white.preaparc --aparc ../label/rh.aparc.annot
#--------------------------------------------
#@# T1PialSurf lh Mon Aug 21 10:54:32 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white --o ../surf/lh.pial.T1 --pial --nsmooth 0 --rip-label ../label/lh.cortex+hipamyg.label --pin-medial-wall ../label/lh.cortex.label --aparc ../label/lh.aparc.annot --repulse-surf ../surf/lh.white --white-surf ../surf/lh.white
#--------------------------------------------
#@# T1PialSurf rh Mon Aug 21 10:59:30 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white --o ../surf/rh.pial.T1 --pial --nsmooth 0 --rip-label ../label/rh.cortex+hipamyg.label --pin-medial-wall ../label/rh.cortex.label --aparc ../label/rh.aparc.annot --repulse-surf ../surf/rh.white --white-surf ../surf/rh.white
#@# white curv lh Mon Aug 21 11:05:06 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --curv-map ../surf/lh.white 2 10 ../surf/lh.curv
#@# white area lh Mon Aug 21 11:05:10 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --area-map ../surf/lh.white ../surf/lh.area
#@# pial curv lh Mon Aug 21 11:05:11 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --curv-map ../surf/lh.pial 2 10 ../surf/lh.curv.pial
#@# pial area lh Mon Aug 21 11:05:15 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --area-map ../surf/lh.pial ../surf/lh.area.pial
#@# thickness lh Mon Aug 21 11:05:17 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# area and vertex vol lh Mon Aug 21 11:06:15 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# white curv rh Mon Aug 21 11:06:19 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --curv-map ../surf/rh.white 2 10 ../surf/rh.curv
#@# white area rh Mon Aug 21 11:06:22 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --area-map ../surf/rh.white ../surf/rh.area
#@# pial curv rh Mon Aug 21 11:06:24 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --curv-map ../surf/rh.pial 2 10 ../surf/rh.curv.pial
#@# pial area rh Mon Aug 21 11:06:28 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --area-map ../surf/rh.pial ../surf/rh.area.pial
#@# thickness rh Mon Aug 21 11:06:30 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness
#@# area and vertex vol rh Mon Aug 21 11:07:25 EDT 2023
cd /home/bverreman/Desktop/test2_high_res/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness

#-----------------------------------------
#@# Curvature Stats lh Mon Aug 21 11:07:29 EDT 2023

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm test2_high_res lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Mon Aug 21 11:07:33 EDT 2023

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm test2_high_res rh curv sulc 

#--------------------------------------------
#@# Cortical ribbon mask Mon Aug 21 11:07:37 EDT 2023

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon test2_high_res 

#-----------------------------------------
#@# Cortical Parc 2 lh Mon Aug 21 11:34:35 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Mon Aug 21 11:35:00 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 3 lh Mon Aug 21 11:35:23 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Mon Aug 21 11:35:39 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 test2_high_res rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# WM/GM Contrast lh Mon Aug 21 11:35:54 EDT 2023

 pctsurfcon --s test2_high_res --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Mon Aug 21 11:36:01 EDT 2023

 pctsurfcon --s test2_high_res --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Mon Aug 21 11:36:08 EDT 2023

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# APas-to-ASeg Mon Aug 21 11:36:49 EDT 2023

 mri_surf2volseg --o aseg.mgz --i aseg.presurf.hypos.mgz --fix-presurf-with-ribbon /home/bverreman/Desktop/test2_high_res/mri/ribbon.mgz --threads 1 --lh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/lh.cortex.label --lh-white /home/bverreman/Desktop/test2_high_res/surf/lh.white --lh-pial /home/bverreman/Desktop/test2_high_res/surf/lh.pial --rh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/rh.cortex.label --rh-white /home/bverreman/Desktop/test2_high_res/surf/rh.white --rh-pial /home/bverreman/Desktop/test2_high_res/surf/rh.pial 


 mri_brainvol_stats --subject test2_high_res 

#-----------------------------------------
#@# AParc-to-ASeg aparc Mon Aug 21 11:37:15 EDT 2023

 mri_surf2volseg --o aparc+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/test2_high_res/label/lh.aparc.annot 1000 --lh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/lh.cortex.label --lh-white /home/bverreman/Desktop/test2_high_res/surf/lh.white --lh-pial /home/bverreman/Desktop/test2_high_res/surf/lh.pial --rh-annot /home/bverreman/Desktop/test2_high_res/label/rh.aparc.annot 2000 --rh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/rh.cortex.label --rh-white /home/bverreman/Desktop/test2_high_res/surf/rh.white --rh-pial /home/bverreman/Desktop/test2_high_res/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.a2009s Mon Aug 21 11:45:49 EDT 2023

 mri_surf2volseg --o aparc.a2009s+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/test2_high_res/label/lh.aparc.a2009s.annot 11100 --lh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/lh.cortex.label --lh-white /home/bverreman/Desktop/test2_high_res/surf/lh.white --lh-pial /home/bverreman/Desktop/test2_high_res/surf/lh.pial --rh-annot /home/bverreman/Desktop/test2_high_res/label/rh.aparc.a2009s.annot 12100 --rh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/rh.cortex.label --rh-white /home/bverreman/Desktop/test2_high_res/surf/rh.white --rh-pial /home/bverreman/Desktop/test2_high_res/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.DKTatlas Mon Aug 21 11:54:17 EDT 2023

 mri_surf2volseg --o aparc.DKTatlas+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/test2_high_res/label/lh.aparc.DKTatlas.annot 1000 --lh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/lh.cortex.label --lh-white /home/bverreman/Desktop/test2_high_res/surf/lh.white --lh-pial /home/bverreman/Desktop/test2_high_res/surf/lh.pial --rh-annot /home/bverreman/Desktop/test2_high_res/label/rh.aparc.DKTatlas.annot 2000 --rh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/rh.cortex.label --rh-white /home/bverreman/Desktop/test2_high_res/surf/rh.white --rh-pial /home/bverreman/Desktop/test2_high_res/surf/rh.pial 

#-----------------------------------------
#@# WMParc Mon Aug 21 12:03:16 EDT 2023

 mri_surf2volseg --o wmparc.mgz --label-wm --i aparc+aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/test2_high_res/label/lh.aparc.annot 3000 --lh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/lh.cortex.label --lh-white /home/bverreman/Desktop/test2_high_res/surf/lh.white --lh-pial /home/bverreman/Desktop/test2_high_res/surf/lh.pial --rh-annot /home/bverreman/Desktop/test2_high_res/label/rh.aparc.annot 4000 --rh-cortex-mask /home/bverreman/Desktop/test2_high_res/label/rh.cortex.label --rh-white /home/bverreman/Desktop/test2_high_res/surf/rh.white --rh-pial /home/bverreman/Desktop/test2_high_res/surf/rh.pial 


 mri_segstats --seed 1234 --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject test2_high_res --surf-wm-vol --ctab /usr/local/freesurfer/7.4.1/WMParcStatsLUT.txt --etiv 

#-----------------------------------------
#@# Parcellation Stats lh Mon Aug 21 12:23:12 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab test2_high_res lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab test2_high_res lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Mon Aug 21 12:23:39 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab test2_high_res rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab test2_high_res rh pial 

#-----------------------------------------
#@# Parcellation Stats 2 lh Mon Aug 21 12:24:07 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab test2_high_res lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Mon Aug 21 12:24:22 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab test2_high_res rh white 

#-----------------------------------------
#@# Parcellation Stats 3 lh Mon Aug 21 12:24:38 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab test2_high_res lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Mon Aug 21 12:24:51 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab test2_high_res rh white 

#--------------------------------------------
#@# ASeg Stats Mon Aug 21 12:25:05 EDT 2023

 mri_segstats --seed 1234 --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/7.4.1/ASegStatsLUT.txt --subject test2_high_res 

#--------------------------------------------
#@# BA_exvivo Labels lh Mon Aug 21 12:33:17 EDT 2023

 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA1_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA2_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3a_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3b_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4a_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4p_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA6_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA44_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA45_exvivo.label --trgsubject test2_high_res --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V1_exvivo.label --trgsubject test2_high_res --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V2_exvivo.label --trgsubject test2_high_res --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.MT_exvivo.label --trgsubject test2_high_res --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject test2_high_res --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject test2_high_res --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG1.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.FG1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG2.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.FG2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG3.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.FG3.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG4.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.FG4.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc1.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.hOc1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc2.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.hOc2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc3v.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.hOc3v.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc4v.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./lh.hOc4v.mpm.vpnl.label --hemi lh --regmethod surface 


 mris_label2annot --s test2_high_res --ctab /usr/local/freesurfer/7.4.1/average/colortable_vpnl.txt --hemi lh --a mpm.vpnl --maxstatwinner --noverbose --l lh.FG1.mpm.vpnl.label --l lh.FG2.mpm.vpnl.label --l lh.FG3.mpm.vpnl.label --l lh.FG4.mpm.vpnl.label --l lh.hOc1.mpm.vpnl.label --l lh.hOc2.mpm.vpnl.label --l lh.hOc3v.mpm.vpnl.label --l lh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s test2_high_res --hemi lh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.perirhinal_exvivo.label --l lh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s test2_high_res --hemi lh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab test2_high_res lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab test2_high_res lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Mon Aug 21 12:38:15 EDT 2023

 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA1_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA2_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3a_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3b_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4a_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4p_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA6_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA44_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA45_exvivo.label --trgsubject test2_high_res --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V1_exvivo.label --trgsubject test2_high_res --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V2_exvivo.label --trgsubject test2_high_res --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.MT_exvivo.label --trgsubject test2_high_res --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject test2_high_res --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject test2_high_res --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG1.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.FG1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG2.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.FG2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG3.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.FG3.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG4.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.FG4.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc1.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.hOc1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc2.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.hOc2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc3v.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.hOc3v.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc4v.mpm.vpnl.label --trgsubject test2_high_res --trglabel ./rh.hOc4v.mpm.vpnl.label --hemi rh --regmethod surface 


 mris_label2annot --s test2_high_res --ctab /usr/local/freesurfer/7.4.1/average/colortable_vpnl.txt --hemi rh --a mpm.vpnl --maxstatwinner --noverbose --l rh.FG1.mpm.vpnl.label --l rh.FG2.mpm.vpnl.label --l rh.FG3.mpm.vpnl.label --l rh.FG4.mpm.vpnl.label --l rh.hOc1.mpm.vpnl.label --l rh.hOc2.mpm.vpnl.label --l rh.hOc3v.mpm.vpnl.label --l rh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject test2_high_res --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s test2_high_res --hemi rh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.perirhinal_exvivo.label --l rh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s test2_high_res --hemi rh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab test2_high_res rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab test2_high_res rh white 



#---------------------------------
# New invocation of recon-all Tue Aug 22 12:13:12 EDT 2023 
#--------------------------------------------
#@# Mask BFS Tue Aug 22 12:13:14 EDT 2023

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 


 mri_mask -transfer 255 -keep_mask_deletion_edits brain.finalsurfs.mgz brain.finalsurfs.manedit.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# Fill Tue Aug 22 12:13:18 EDT 2023

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.presurf.mgz -ctab /usr/local/freesurfer/7.4.1/SubCorticalMassLUT.txt -auto-man filled.auto.mgz filled.mgz ../tmp/filled.edits.txt wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Tue Aug 22 12:15:16 EDT 2023

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Tue Aug 22 12:15:24 EDT 2023

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Tue Aug 22 12:15:33 EDT 2023

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Tue Aug 22 12:15:39 EDT 2023

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Tue Aug 22 12:15:45 EDT 2023

 mris_inflate -no-save-sulc -n 100 ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Tue Aug 22 12:23:07 EDT 2023

 mris_inflate -no-save-sulc -n 100 ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Tue Aug 22 12:32:44 EDT 2023

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Tue Aug 22 12:36:17 EDT 2023

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#@# Fix Topology lh Tue Aug 22 12:40:39 EDT 2023

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 corrected_filled lh 

#@# Fix Topology rh Tue Aug 22 12:41:40 EDT 2023

 mris_fix_topology -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 corrected_filled rh 


 mris_euler_number ../surf/lh.orig.premesh 


 mris_euler_number ../surf/rh.orig.premesh 


 mris_remesh --remesh --iters 3 --input /home/bverreman/Desktop/corrected_filled/surf/lh.orig.premesh --output /home/bverreman/Desktop/corrected_filled/surf/lh.orig 


 mris_remesh --remesh --iters 3 --input /home/bverreman/Desktop/corrected_filled/surf/rh.orig.premesh --output /home/bverreman/Desktop/corrected_filled/surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm -f ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm -f ../surf/rh.inflated 

#--------------------------------------------
#@# AutoDetGWStats lh Tue Aug 22 12:47:10 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.lh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/lh.orig.premesh
#--------------------------------------------
#@# AutoDetGWStats rh Tue Aug 22 12:47:17 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.rh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/rh.orig.premesh
#--------------------------------------------
#@# WhitePreAparc lh Tue Aug 22 12:47:23 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --wm wm.mgz --threads 1 --invol brain.finalsurfs.mgz --lh --i ../surf/lh.orig --o ../surf/lh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# WhitePreAparc rh Tue Aug 22 12:55:06 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --wm wm.mgz --threads 1 --invol brain.finalsurfs.mgz --rh --i ../surf/rh.orig --o ../surf/rh.white.preaparc --white --seg aseg.presurf.mgz --nsmooth 5
#--------------------------------------------
#@# CortexLabel lh Tue Aug 22 13:02:58 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 0 ../label/lh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg lh Tue Aug 22 13:03:27 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 1 ../label/lh.cortex+hipamyg.label
#--------------------------------------------
#@# CortexLabel rh Tue Aug 22 13:03:55 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 0 ../label/rh.cortex.label
#--------------------------------------------
#@# CortexLabel+HipAmyg rh Tue Aug 22 13:04:22 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 1 ../label/rh.cortex+hipamyg.label
#--------------------------------------------
#@# Smooth2 lh Tue Aug 22 13:04:51 EDT 2023

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Tue Aug 22 13:04:58 EDT 2023

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Tue Aug 22 13:05:05 EDT 2023

 mris_inflate -n 100 ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Tue Aug 22 13:06:11 EDT 2023

 mris_inflate -n 100 ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Tue Aug 22 13:07:11 EDT 2023

 mris_curvature -w -seed 1234 lh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Tue Aug 22 13:08:50 EDT 2023

 mris_curvature -w -seed 1234 rh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 

#--------------------------------------------
#@# Sphere lh Tue Aug 22 13:10:29 EDT 2023

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Tue Aug 22 13:31:06 EDT 2023

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Tue Aug 22 13:55:07 EDT 2023

 mris_register -curv ../surf/lh.sphere /usr/local/freesurfer/7.4.1/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 


 ln -sf lh.sphere.reg lh.fsaverage.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Tue Aug 22 14:19:33 EDT 2023

 mris_register -curv ../surf/rh.sphere /usr/local/freesurfer/7.4.1/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 


 ln -sf rh.sphere.reg rh.fsaverage.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Tue Aug 22 14:49:40 EDT 2023

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Tue Aug 22 14:49:44 EDT 2023

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Tue Aug 22 14:49:49 EDT 2023

 mrisp_paint -a 5 /usr/local/freesurfer/7.4.1/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Tue Aug 22 14:49:52 EDT 2023

 mrisp_paint -a 5 /usr/local/freesurfer/7.4.1/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Tue Aug 22 14:49:56 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Tue Aug 22 14:50:44 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# WhiteSurfs lh Tue Aug 22 14:51:24 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white.preaparc --o ../surf/lh.white --white --nsmooth 0 --rip-label ../label/lh.cortex.label --rip-bg --rip-surf ../surf/lh.white.preaparc --aparc ../label/lh.aparc.annot
#--------------------------------------------
#@# WhiteSurfs rh Tue Aug 22 15:02:36 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white.preaparc --o ../surf/rh.white --white --nsmooth 0 --rip-label ../label/rh.cortex.label --rip-bg --rip-surf ../surf/rh.white.preaparc --aparc ../label/rh.aparc.annot
#--------------------------------------------
#@# T1PialSurf lh Tue Aug 22 15:13:50 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white --o ../surf/lh.pial.T1 --pial --nsmooth 0 --rip-label ../label/lh.cortex+hipamyg.label --pin-medial-wall ../label/lh.cortex.label --aparc ../label/lh.aparc.annot --repulse-surf ../surf/lh.white --white-surf ../surf/lh.white
#--------------------------------------------
#@# T1PialSurf rh Tue Aug 22 15:30:31 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 1 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white --o ../surf/rh.pial.T1 --pial --nsmooth 0 --rip-label ../label/rh.cortex+hipamyg.label --pin-medial-wall ../label/rh.cortex.label --aparc ../label/rh.aparc.annot --repulse-surf ../surf/rh.white --white-surf ../surf/rh.white
#@# white curv lh Tue Aug 22 15:44:12 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --curv-map ../surf/lh.white 2 10 ../surf/lh.curv
#@# white area lh Tue Aug 22 15:44:19 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --area-map ../surf/lh.white ../surf/lh.area
#@# pial curv lh Tue Aug 22 15:44:22 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --curv-map ../surf/lh.pial 2 10 ../surf/lh.curv.pial
#@# pial area lh Tue Aug 22 15:44:29 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --area-map ../surf/lh.pial ../surf/lh.area.pial
#@# thickness lh Tue Aug 22 15:44:33 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# area and vertex vol lh Tue Aug 22 15:46:17 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# white curv rh Tue Aug 22 15:46:24 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --curv-map ../surf/rh.white 2 10 ../surf/rh.curv
#@# white area rh Tue Aug 22 15:46:31 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --area-map ../surf/rh.white ../surf/rh.area
#@# pial curv rh Tue Aug 22 15:46:35 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --curv-map ../surf/rh.pial 2 10 ../surf/rh.curv.pial
#@# pial area rh Tue Aug 22 15:46:42 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --area-map ../surf/rh.pial ../surf/rh.area.pial
#@# thickness rh Tue Aug 22 15:46:47 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness
#@# area and vertex vol rh Tue Aug 22 15:48:32 EDT 2023
cd /home/bverreman/Desktop/corrected_filled/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness

#-----------------------------------------
#@# Curvature Stats lh Tue Aug 22 15:48:39 EDT 2023

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm corrected_filled lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Tue Aug 22 15:48:48 EDT 2023

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm corrected_filled rh curv sulc 

#--------------------------------------------
#@# Cortical ribbon mask Tue Aug 22 15:48:57 EDT 2023

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon corrected_filled 

#-----------------------------------------
#@# Cortical Parc 2 lh Tue Aug 22 16:33:21 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Tue Aug 22 16:34:25 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 3 lh Tue Aug 22 16:35:21 EDT 2023

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled lh ../surf/lh.sphere.reg /usr/local/freesurfer/7.4.1/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Tue Aug 22 16:35:53 EDT 2023

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 corrected_filled rh ../surf/rh.sphere.reg /usr/local/freesurfer/7.4.1/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# WM/GM Contrast lh Tue Aug 22 16:36:26 EDT 2023

 pctsurfcon --s corrected_filled --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Tue Aug 22 16:36:39 EDT 2023

 pctsurfcon --s corrected_filled --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Tue Aug 22 16:36:51 EDT 2023

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# APas-to-ASeg Tue Aug 22 16:37:55 EDT 2023

 mri_surf2volseg --o aseg.mgz --i aseg.presurf.hypos.mgz --fix-presurf-with-ribbon /home/bverreman/Desktop/corrected_filled/mri/ribbon.mgz --threads 1 --lh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/lh.cortex.label --lh-white /home/bverreman/Desktop/corrected_filled/surf/lh.white --lh-pial /home/bverreman/Desktop/corrected_filled/surf/lh.pial --rh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/rh.cortex.label --rh-white /home/bverreman/Desktop/corrected_filled/surf/rh.white --rh-pial /home/bverreman/Desktop/corrected_filled/surf/rh.pial 


 mri_brainvol_stats --subject corrected_filled 

#-----------------------------------------
#@# AParc-to-ASeg aparc Tue Aug 22 16:38:41 EDT 2023

 mri_surf2volseg --o aparc+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/corrected_filled/label/lh.aparc.annot 1000 --lh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/lh.cortex.label --lh-white /home/bverreman/Desktop/corrected_filled/surf/lh.white --lh-pial /home/bverreman/Desktop/corrected_filled/surf/lh.pial --rh-annot /home/bverreman/Desktop/corrected_filled/label/rh.aparc.annot 2000 --rh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/rh.cortex.label --rh-white /home/bverreman/Desktop/corrected_filled/surf/rh.white --rh-pial /home/bverreman/Desktop/corrected_filled/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.a2009s Tue Aug 22 16:53:53 EDT 2023

 mri_surf2volseg --o aparc.a2009s+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/corrected_filled/label/lh.aparc.a2009s.annot 11100 --lh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/lh.cortex.label --lh-white /home/bverreman/Desktop/corrected_filled/surf/lh.white --lh-pial /home/bverreman/Desktop/corrected_filled/surf/lh.pial --rh-annot /home/bverreman/Desktop/corrected_filled/label/rh.aparc.a2009s.annot 12100 --rh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/rh.cortex.label --rh-white /home/bverreman/Desktop/corrected_filled/surf/rh.white --rh-pial /home/bverreman/Desktop/corrected_filled/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.DKTatlas Tue Aug 22 17:08:44 EDT 2023

 mri_surf2volseg --o aparc.DKTatlas+aseg.mgz --label-cortex --i aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/corrected_filled/label/lh.aparc.DKTatlas.annot 1000 --lh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/lh.cortex.label --lh-white /home/bverreman/Desktop/corrected_filled/surf/lh.white --lh-pial /home/bverreman/Desktop/corrected_filled/surf/lh.pial --rh-annot /home/bverreman/Desktop/corrected_filled/label/rh.aparc.DKTatlas.annot 2000 --rh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/rh.cortex.label --rh-white /home/bverreman/Desktop/corrected_filled/surf/rh.white --rh-pial /home/bverreman/Desktop/corrected_filled/surf/rh.pial 

#-----------------------------------------
#@# WMParc Tue Aug 22 17:23:58 EDT 2023

 mri_surf2volseg --o wmparc.mgz --label-wm --i aparc+aseg.mgz --threads 1 --lh-annot /home/bverreman/Desktop/corrected_filled/label/lh.aparc.annot 3000 --lh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/lh.cortex.label --lh-white /home/bverreman/Desktop/corrected_filled/surf/lh.white --lh-pial /home/bverreman/Desktop/corrected_filled/surf/lh.pial --rh-annot /home/bverreman/Desktop/corrected_filled/label/rh.aparc.annot 4000 --rh-cortex-mask /home/bverreman/Desktop/corrected_filled/label/rh.cortex.label --rh-white /home/bverreman/Desktop/corrected_filled/surf/rh.white --rh-pial /home/bverreman/Desktop/corrected_filled/surf/rh.pial 


 mri_segstats --seed 1234 --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject corrected_filled --surf-wm-vol --ctab /usr/local/freesurfer/7.4.1/WMParcStatsLUT.txt --etiv 

#-----------------------------------------
#@# Parcellation Stats lh Tue Aug 22 17:45:50 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab corrected_filled lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab corrected_filled lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Tue Aug 22 17:47:13 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab corrected_filled rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab corrected_filled rh pial 

#-----------------------------------------
#@# Parcellation Stats 2 lh Tue Aug 22 17:48:38 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab corrected_filled lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Tue Aug 22 17:49:27 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab corrected_filled rh white 

#-----------------------------------------
#@# Parcellation Stats 3 lh Tue Aug 22 17:50:10 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab corrected_filled lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Tue Aug 22 17:50:51 EDT 2023

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab corrected_filled rh white 

#--------------------------------------------
#@# ASeg Stats Tue Aug 22 17:51:31 EDT 2023

 mri_segstats --seed 1234 --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/7.4.1/ASegStatsLUT.txt --subject corrected_filled 

#--------------------------------------------
#@# BA_exvivo Labels lh Tue Aug 22 18:00:26 EDT 2023

 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA1_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA2_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3a_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3b_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4a_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4p_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA6_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA44_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA45_exvivo.label --trgsubject corrected_filled --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V1_exvivo.label --trgsubject corrected_filled --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V2_exvivo.label --trgsubject corrected_filled --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.MT_exvivo.label --trgsubject corrected_filled --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject corrected_filled --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject corrected_filled --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG1.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.FG1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG2.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.FG2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG3.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.FG3.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.FG4.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.FG4.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc1.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.hOc1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc2.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.hOc2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc3v.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.hOc3v.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.hOc4v.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./lh.hOc4v.mpm.vpnl.label --hemi lh --regmethod surface 


 mris_label2annot --s corrected_filled --ctab /usr/local/freesurfer/7.4.1/average/colortable_vpnl.txt --hemi lh --a mpm.vpnl --maxstatwinner --noverbose --l lh.FG1.mpm.vpnl.label --l lh.FG2.mpm.vpnl.label --l lh.FG3.mpm.vpnl.label --l lh.FG4.mpm.vpnl.label --l lh.hOc1.mpm.vpnl.label --l lh.hOc2.mpm.vpnl.label --l lh.hOc3v.mpm.vpnl.label --l lh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s corrected_filled --hemi lh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.perirhinal_exvivo.label --l lh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s corrected_filled --hemi lh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab corrected_filled lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab corrected_filled lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Tue Aug 22 18:10:39 EDT 2023

 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA1_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA2_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3a_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3b_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4a_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4p_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA6_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA44_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA45_exvivo.label --trgsubject corrected_filled --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V1_exvivo.label --trgsubject corrected_filled --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V2_exvivo.label --trgsubject corrected_filled --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.MT_exvivo.label --trgsubject corrected_filled --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject corrected_filled --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject corrected_filled --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG1.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.FG1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG2.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.FG2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG3.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.FG3.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.FG4.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.FG4.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc1.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.hOc1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc2.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.hOc2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc3v.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.hOc3v.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.hOc4v.mpm.vpnl.label --trgsubject corrected_filled --trglabel ./rh.hOc4v.mpm.vpnl.label --hemi rh --regmethod surface 


 mris_label2annot --s corrected_filled --ctab /usr/local/freesurfer/7.4.1/average/colortable_vpnl.txt --hemi rh --a mpm.vpnl --maxstatwinner --noverbose --l rh.FG1.mpm.vpnl.label --l rh.FG2.mpm.vpnl.label --l rh.FG3.mpm.vpnl.label --l rh.FG4.mpm.vpnl.label --l rh.hOc1.mpm.vpnl.label --l rh.hOc2.mpm.vpnl.label --l rh.hOc3v.mpm.vpnl.label --l rh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/bverreman/Desktop/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject corrected_filled --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s corrected_filled --hemi rh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.perirhinal_exvivo.label --l rh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s corrected_filled --hemi rh --ctab /usr/local/freesurfer/7.4.1/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab corrected_filled rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab corrected_filled rh white 

