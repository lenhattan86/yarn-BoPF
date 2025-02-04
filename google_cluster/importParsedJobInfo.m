function [jobIds,submitTime,finishTime,scheduleClass,VarName5] = importParsedJobInfo(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [JOBIDS,SUBMITTIME,FINISHTIME,SCHEDULECLASS,VARNAME5] =
%   IMPORTFILE(FILENAME) Reads data from text file FILENAME for the default
%   selection.
%
%   [JOBIDS,SUBMITTIME,FINISHTIME,SCHEDULECLASS,VARNAME5] =
%   IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [jobIds,submitTime,finishTime,scheduleClass,VarName5] = importfile('jobInfo_sample.csv',1, 5953);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/01/30 16:50:05

%% Initialize variables.
delimiter = ',';
if nargin<=2
  startRow = 1;
  endRow = inf;
end

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
  frewind(fileID);
  dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
  for col=1:length(dataArray)
    dataArray{col} = [dataArray{col};dataArrayBlock{col}];
  end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
jobIds = dataArray{:, 1};
submitTime = dataArray{:, 2};
finishTime = dataArray{:, 3};
scheduleClass = dataArray{:, 4};
VarName5 = dataArray{:, 5};


