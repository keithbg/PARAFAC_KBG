% This is my edited version of combineSampleFiles5.m 
% in /Users/KeithBG/Documents/UC Berkeley/2016 Spring Classes/EEA_DOC/Aqualog_EEMs/PARAFAC_Analyses/ForKeith/More recent PARAFAC/
% Variables are defined in PARAFAC_eel_<datae>.m script

function [X, finaldesig, Ex, Em] = combineSampleFilesKBG(EEMdir, inputSS, sheetname, lastrow, groups, first_em, last_em, first_ex, last_ex)

% Load filenames
% OLD XSLX VERSION
%[numeric, filenames] = xlsread(inputSS, sheetname, sprintf('A2:A%d', lastrow)); %load filenames
%clear numeric;

% USING TEXT FILE
fileID=fopen(inputSS);
filename_spreadsheet = textscan(fileID, '%s%s%s%s%s%s', 'HeaderLines', 1);
fclose(fileID);
file_list = filename_spreadsheet{1};

if groups == 2
    desig = xlsread(inputSS, sheetname, sprintf('B2:B%d', lastrow)); %Load group designator
end

% Set loop counter to 1
counter=1;


% Loop to read in each file, create the matrix, and then store in an array
for ii=1:length(file_list)
    try
        % fopen does something I don't understand
        % that is similar to "staging" the file
        % OLD XLSX VERSION fid = fopen(sprintf('%s%s%s', EEMdir, filenames{ii})); % should be positive integer if file loads
        fid = fopen(sprintf('%s%s%s', EEMdir, file_list{ii})); % should be positive integer if file loads
        % textscan loads in file
        C = textscan(fid, '%n%n%n', 'HeaderLines', 1);
        fclose(fid);
        % Extract z values in 3rd column
        currfile = C{3};
        ex = C{1}; em = C{2};
        Exfull = unique(ex); Emfull = unique(em);
        % Make the "z" fluorescence vector a matrix of row_num=Em
        % wavelengths and column_num= Ex wavelengths
        currfile = fliplr(reshape(currfile, length(Emfull), length(Exfull))); %Turn fluorescence into a matrix (from plotEEMs.m) 
        currfile(find(currfile<0))=0; %Set negative values to 0.
        
        % Trim the matrix by the first & last wavelength values specified 
        MatrixPrelim=currfile(find(Emfull==first_em):find(Emfull==last_em), find(Exfull==first_ex):find(Exfull==last_ex));%check what using for ex/em indices
        
        % Trim Ex and Em wavelength vector
        Ex = Exfull(find(Exfull==first_ex):find(Exfull==last_ex));
        Em = Emfull(find(Emfull==first_em):find(Emfull==last_em));
        
        % Store matrix in new variable X, which will have a matrix for
        % each file in filenames vector
        % (uses <counter> variable to increase by 1 each loop cycle)
        X(counter,:,:)= MatrixPrelim; %If we do want to sample by 10, change MatrixPrelim here to NewMatrix
        
        % Start  process of inputting another file
        clear currfile;
        
        counter = counter + 1;
    catch
        fprintf('%s%s', filenames{ii}, ' not loaded.   ') %Let user know if can't find file. If this is because of a blank row in the spreadsheet, it will just read "   not loaded," and the user shouldn't worry.
    end
end

% Fill desig matrix with blanks if groups does not =2
if groups ~=2
    finaldesig = [];
end

 