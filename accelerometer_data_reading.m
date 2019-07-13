function [vectors] = accelerometer_data_reading(fileName)
%accelerometer_data_reading load data, check format (a bit), fill missing values

fileID = fopen(fileName,'r');
if(fileID == -1)
error(['file not found ' fileName])
end
rows = splitlines(fscanf(fileID,'%c'));
expectedHeaderRow = 'PacketCounter,Acc_X,Acc_Y,Acc_Z,FreeAcc_X,FreeAcc_Y,FreeAcc_Z,Roll,Pitch,Yaw';
if(~strcmp(rows{6,1},expectedHeaderRow ))%check if data has expected header
error('unexpected data format')
end
fclose(fileID);

%fill missing values 
DataMatrix_withMissing = readmatrix(fileName);%read numbers to one matrix
DataMatrix = fillmissing(DataMatrix_withMissing,'linear',1);%one means - operate over first dim.

% get freq from free accx, free accy, free accz
vectors = DataMatrix(:,5:7);

end

