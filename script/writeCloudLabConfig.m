clear; close all; clc;

data = importCloudlab('cloudlab.csv');

fileToWrite ='config.txt';
%fileToWrite ='~/Dropbox/temp/config.txt';

fileID = fopen(fileToWrite,'w');
fprintf(fileID,'StrictHostKeyChecking no \n\n');
fclose(fileID);

fileID = fopen(fileToWrite,'a');


fmt_01 = 'host %s-0 \n';
fmt_02 = '  Hostname %s \n';
fmt_03 = '  Port 22 \n';
fmt_04 = '  User tanle \n';
fmt_05 = '  IdentityFile ~/Dropbox/Research/cloudlab/cloudlab.pem \n';
fmt_06 = '   \n';

fmt = [fmt_01 fmt_02 fmt_03 fmt_04 fmt_06];
 

sId = 1;
dataSize = size(data);
for i=1:dataSize(1)
    hostname = data{i,5};
    if length(data{i,1})<10
        ipadress = resolveip(hostname(17:length(hostname)));
        fprintf(fileID,fmt, data{i,1}, ipadress);
    else
        disp(data{i,1})
    end
end

fclose(fileID);
datetime('now')
disp('done');
