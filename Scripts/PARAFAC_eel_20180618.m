% Keith PARAFAC End member analysis for Eel River 
% monthly water samples 2016-2017

% based on PenobscotParafac_Source_Tracking_Modifications.m file
% in /Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/PARAFAC_Analyses/ForKeith/Sample PARAFAC-original/

%Make sure that ex.txt and em.txt are in the current directory for Matlab.
%The input EEMs can be in any directory, and the input Excel file can also
%be in any directory. 

%DOMFluor %Check to make sure DOMFluor package is loaded

% Clear out workspace
clear
clc
close all



%% INPUTS

EEMdir = 'C:/Users/!j.wingenroth/Documents/PARAFAC_KBG/EEMS_EX_3nm_corrected_subset'; %Insert the directory for the EEMs here
% OLD inputSS = '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Aqualog_Data/NEED TO CHANGE FOR SUBSET FILESinput_eem_filenames.xlsx'; %Insert complete filename of input spreadsheet
 inputSS = 'C:/Users/!j.wingenroth/Documents/PARAFAC_KBG/EEMS_EX_3nm_corrected_subset/Data/eem_sample_list_subset.txt'; %Insert complete filename of input spreadsheet
 sheetname = 'sample_names'; %Insert name of the appropriate sheet of the above spreadsheet. Usually this will just be 'Sheet1'
groups = 1; %Number of pre-designated groups for split-half analysis. If you want the code to do this automatically, set it to one. Otherwise, if you have designated groups in column O of the spreadsheet, it should be 2.
lastrow = 232; %Last sample row on inpust spreadsheet
max_components = 6; %This is the maximum number of components there might possibly be in the model (does NOT mean the model would ultimately be run with this number of components). I recommend using 10 here, but if the best model turns out to be the 10-component model, rerun the analysis with a larger max_components.
first_em = 275.742; %The first emission wavelength to crop to in the    model. Use 212.423 when beginning (no data will be cut). 
last_em = 620.139; %The last emission wavelength to crop to in the model. Use 620.139 when beginning (no data will be cut).
first_ex = 252; %The first excitation wavelength to crop to in the model. Use 240 when beginning (no data will be cut). 
last_ex = 585; %The last excitation wavelength to crop to in the model. Use 600 when beginning (no data will be cut).
ex_increment = 3; %The nm increment between excitation wavelengths


%% Build matrix of sample files
%Produce matrix of sample files and group designators for split-half analysis
[X, desig, Ex, Em] = combineSampleFiles_KBG(EEMdir, inputSS, sheetname, lastrow, groups, first_em, last_em, first_ex, last_ex); 
%save('desigFile.mat', 'desig');


% %Make "Original Data" structure for use with new parafac toolbox.
OriginalData.Ex = Ex;
OriginalData.Em = Em;
OriginalData.X = X;
[OriginalData.nSample, OriginalData.nEm, OriginalData.nEx] = size(X);
OriginalData.XBackup = X;

% Plot original data and save jpegs
%PlotEEMby1_AndSave(1:231, OriginalData, 'R.U', '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Figures/CorrectedSubset_EEM', inputSS, sheetname, lastrow)

% PlotSurfby4(1:5, OriginalData, 'R.U')
%PlotEEMby4(1:20, OriginalDataNorm, 'R.U.')

% Save OriginalData
%save('OriginalDataFile.mat', 'OriginalData')
%OriginalDataFile = load('OriginalDataFile.mat');
%OriginalData = OriginalDataFile.OriginalData;
desig = load('desigFile.mat');


%% Eliminate first and second order Rayleigh scattering regions and put in a triangle of zeros.

% help EEMCut
%[CutData] = EEMCut(OriginalData, 15, NaN, 25, NaN, 'No'); %Eliminate first and second order Rayleigh scattering regions and put in triangle of zeros

% 25 nm removes the noise in the top left of the EEM
% 15 nm removes the bottom right triangle
% Did not see any EEEM where these parameters cut off a substantial portion of fluorescence

%Normalize by sum of squares
%CutData = normeem(CutData);

%save('CutDataFile.mat', 'CutData')

CutDataLoad = load('CutDataFile.mat')
CutData = CutDataLoad.CutData

% PLOT CUT EEMS
%PlotEEMby1_AndSave(1:231, CutData, 'R.U', '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Figures/CorrectedSubset_EEM_Cut', inputSS, sheetname, lastrow)
%PlotEEMby4(1:20, CutData, 'R.U.')
%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%FIRST STOP
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%% PERFORM AN OUTLIER ANALYSIS

% help OutlierTest
 %[TestCutNoOutliers] = OutlierTest(CutData,1,1,max_components,'Yes','No');	%This will run an outlier test for a model with between 2 components and max_components with non-negativity constraints 
 %save('TestCutNoOutliersNorm_File.mat', 'TestCutNoOutliers')

 TestCutLoad = load('TestCutNoOutliersNorm_File.mat', 'TestCutNoOutliers')
 TestCutNoOutliers = TestCutLoad.TestCutNoOutliers
 
for ii = 2:max_components
    figure
    PlotLL(TestCutNoOutliers, 2); %Plot leverage and loadings plots
    %ComponentEEM(TestCut, ii); %Plot EEMs of components
    %pause
end


    PlotLL(TestCut, 7); %Plot leverage and loadings plots
    ComponentEEM(TestCut, 4); %Plot EEMs of components
    PlotLeverage(TestCut, 6)
   
    EvalModel(TestCut, 7)

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%SECOND STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%% ENTER ADDITIONAL INPUT DATA
EMP_EX500 = [30 35 36 81 105 115 117 118 124 134];
possible_outliers = EMP_EX500
possible_outliers= []
% possible_outliers = [81 105 115 117 118]; %Enter a vector of the sample numbers that are possibly outliers, separated by spaces. If there are none, set possible_outliers equal to [].
input_data_file = CutData; %Enter the input data file. If this is your first pass removing outliers, it should be CutData. If not, it should be CutData2.

%EXAMINE OUTLIERS
if ~isempty(possible_outliers)
    PlotEEMby4(100, input_data_file, 'R.U.');
end

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%THIRD STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%% ENTER ADDITIONAL INPUT DATA
final_outliers.samples = []; %Enter a vector of the sample numbers that are outliers that should be removed. If there are none, set final_outliers.samples to [].
%CutData2 outliers: [167 224]
%CutData3 outliers: [105 115 117 118 167 224]

final_outliers.em_wavelengths = Em(1:3); %Enter a vector of the emission wavelengths that are outliers that should be removed. If there are none, set final_outliers.em_wavelengths to []. 
%If there is more than one range (e.g., 350:400 and 500:550), type them like this example: [350:2:400 500:2:550]. The 2 always needs to be in the middle of the range!

final_outliers.ex_wavelengths = [573 576 579 582 585];%Enter a vector of the excitation wavelengths that are outliers that should be removed. If there are none, set final_outliers.ex_wavelengths to []. 
final_outliers.ex_wavelengths = [450:3:585];%Enter a vector of the excitation wavelengths that are outliers that should be removed. If there are none, set final_outliers.ex_wavelengths to []. 

%If there is more than one range (e.g., 350:400 and 500:550), type them like this example: [350:5:400 500:5:550]. The 5 always needs to be in the middle of the range!

input_cut_data = CutData; %Enter the name of the input matrix to cut from. Will either be CutData (if this is your first time through this section), CutData2 (if you have already been 
%through this section at least once already), or backup_cut_data (if you
%want to redo the last attempt at outlier removal.)

input_desig = desig; %Enter the name of the split half validation matrix. Will either be desig (if this is your first time through this section), desig2 (if you have already been
%through this section at least once already), or backup_desig (if you want
%to redo the last attempt at outlier removal. 

%% REMOVE OUTLIERS 
ind_em = []; %Initialize
ind_ex = [];
backup_cut_data = input_cut_data; %Use this variable if you have overwritten CutData2 and are dissatisfied with the result.
backup_desig = input_desig; %Use this variable if you have overwritten desig and are dissatisfied with the result.
for ii = 1:length(final_outliers.em_wavelengths)
    ind_em(ii) = find(Em==final_outliers.em_wavelengths(ii)); %Find the indices of the specified emission wavelengths.
end
for ii = 1:length(final_outliers.ex_wavelengths)
    ind_ex(ii) = find(Ex==final_outliers.ex_wavelengths(ii)); %Find the indices of the specified excitation wavelengths.
end

% Remove outlier samples and wavelengths
[CutData2] = RemoveOutliers(input_cut_data, possible_outliers, ind_em, ind_ex); %Remove the outliers from the sample matrix
%PlotEEMby4(100, CutData2, 'R.U.');
%PlotEEMby1_AndSave(1:231, CutData2, 'R.U', '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Figures/CorrectedSubset_EEM_Cut_Trim450', inputSS, sheetname, lastrow)

%% PERFORM AN OUTLIER ANALYSIS
[TestCut2] = OutlierTest(CutData2,2,1,max_components,'Yes','No'); %This will run an outlier test for a model with between 2 components and max_components with non-negativity constraints
%desig2 = desig;

% PLOT LL FIGURES
    for ii = 2:max_components
        figure
        PlotLL(TestCut2, ii); %Plot leverage and loadings plots
        %ComponentEEM(Test2, ii); %Plot EEMs of components
        %pause
    end

% COMPONENT PLOTS
%for ii = 2:max_components
    %figure
    %ComponentEEM_save_KBG(TestCut2, ii, '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Figures/Components/TestCut3')
    %pause
%end

% SAVE THE MODELS AS MATLAB FILES
%save('CutData_Trim450.mat', 'CutData2')
%save('TestCut_Trim450.mat', 'TestCut2')

%TestCut3 = load('TestCut3File.mat')




%PlotEEMby1_AndSave(1:231, OriginalData, 'R.U', '/Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/Figures/CorrectedSubset_EEM', inputSS, sheetname, lastrow)

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%RUN THIS SECTION ONLY IF YOU NEED TO REMOVE MORE OUTLIERS AT THIS POINT
%AND ARE SATISTIED WITH THE LAST ATTEMPT AT OUTLIER REMOVAL
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[Test2Backup] = TestCut2; %Create a backup of Test2 in case you overwrite it and are dissatisfied with the results.

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% FOURTH STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%ENTER ADDITIONAL INPUT DATA
InputTest = TestCut2; %Enter the test that you will continue the analysis with. Will either be Test2 or Test2Backup.
start_index = 1; % 1 is default. If you are rerunning this section after pausing the execution of Compare2Models, it should be ii+1.

%EXAMINE RESIDUALS
for ii = start_index:ceil(max_components/2)
    if 2*ii ~= max_components %This if.. else structure ensures that two models are always being compared, regardless of the total number of models that were run.
        fprintf('%s%d%s%d%s', 'Comparing models with ', 2*ii, ' and ', 2*ii+1, ' components. ') %Tells you on the screen which models are being compared.
        Compare2Models(InputTest, 2*ii, 2*ii+1) %Examine residuals of two models with a different number of components. To break, hit Ctrl + Pause. 
        pause
    else
        fprintf('%s%d%s%d%s', 'Comparing models with ', 2*ii-1, ' and ', 2*ii, ' components. ') %Tells you on the screen which models are being compared.
        Compare2Models(InputTest, 2*ii-1, 2*ii)
    end
end

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% FIFTH STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%COMPARE SUM OF SQUARED ERROR VALUES OF EACH MODEL (NO INPUT SECTION HERE.)
for ii = 1:ceil(max_components/2)-1
    if 2*ii+1 ~= max_components %This if...else structure ensures that the CompareSpecSSE always has 3 inputs, regardless of the total number of models that were run. 
        figure %Open a new figure window. 
        CompareSpecSSE(InputTest, 2*ii, 2*ii+1, 2*ii+2) %Examine sum-of-squared errors of three models with a different number of components.
    else
        figure
        CompareSpecSSE(InputTest, 2*ii-1, 2*ii, 2*ii+1)
    end
end

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% SIXTH STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%ENTER INPUTS
input_desig = desig2; %Enter the split-half designator array. This will either be desig2 or backup_desig, if you are using results of the penultimate outlier removal.
filename2save = 'SavedSplitHalf.mat'; %Enter the filename to save in single quotes. The .mat extension should be retained. 
min_component = 7; %Enter the minimum number of components to fit in the split-half analysis
max_component = 10; %Enter the maximum number of components to fit in the split-half analysis

%DIVIDE THE DATA INTO TWO HALVES
if groups == 1
    figure
    [AnalysisData] = SplitData(InputTest); %Split the data randomly
else
    figure
    [AnalysisData] = SplitDataPreDesig(InputTest, desig2); %Split the data randomly in accordance with the input data file.
end
pause

%PERFORM SPLIT-HALF ANALYSIS
[AnalysisData] = SplitHalfAnalysis(AnalysisData, (min_component:max_component), filename2save);
for ii = min_component:max_component
    SplitHalfValidation(AnalysisData, '1-2', ii) %Show results of the split half analysis for the first set of halves
    pause
    if groups == 1
        SplitHalfValidation(AnalysisData, '3-4', ii) %If halves were chosen randomly, show the results of the split half analysis for the second set of halves. Otherwise, both sets of halves are the same and this step will not be performed.
        pause
    end
end

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%SEVENTH STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%ENTER INPUTS
validated_n_components = 7; %Enter the number of components that you validated. 
BestModel = AnalysisData.Model7; %All you need to change here is the number at the end. It should be the same as validated_n_components.
SplitModel = AnalysisData.Split(1).Fac_7; %Again, all you need to change here is the number at the end, which should be the same as validated_n_components

%MAKE SURE MODEL CONVERGES TO A GLOBAL MINIMUM
[AnalysisData] = RandInitAnal(AnalysisData, validated_n_components, 10) %This will fit a new model with the correct number of components to the data 10 times to ensure that the model
%does not converge upon a local minimum. 
PlotLoadings(AnalysisData, validated_n_components) %Plot loadings and leverages of new best-fit model
SplitHalfValidation(AnalysisData, '1-2', validated_n_components) %Compare to loadings from split-half validation
title('Split half 1-2')
if groups == 1
    SplitHalfValidation(AnalysisData, '3-4', validated_n_components) %Compare to loadings from the second split-half validation
    title('Split half 3-4')
end
TCC(BestModel, SplitModel) %Use Tucker congruence coefficients to ensure the optimal model is the same as the split-half validated model.

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%EIGHTH STOP
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%ENTER INPUTS
outfile = 'C:\Documents and Settings\Laurel\My Documents\Penobscot Bay\Parafac Results.xls'; %Enter an Excel filename for exporting these results.

%Plot EEMs of components
ComponentEEM(AnalysisData, validated_n_components)

%Export model results
[FMax, B,C] = ModelOut(AnalysisData, validated_n_components, outfile)

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%CONGRATS! YOU MADE IT THROUGH!
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!