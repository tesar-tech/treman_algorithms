

%% testing the accelerometers data
filename = 'MV6.txt';
fileName_txt = ['testsets/radim01/' filename];

vectorsAccelerometer = accelerometer_data_reading(fileName_txt);
fs_accelerometer = 100;
[ampSpects_accelerometer, total_acc] = getAmpSpectsWithMax(vectorsAccelerometer ,fs_accelerometer);
total_acc.frequencies(total_acc.max_ind)

subplot(2,1,1);
plot(vectorsAccelerometer); title('vectors acc');
subplot(2,1,2); plot(total_acc.frequencies,total_acc.values);title('freq spect combined');
hold on;
stem(total_acc.frequencies(total_acc.max_ind),total_acc.values(total_acc.max_ind),'r')
legend('freq',['max ' num2str(total_acc.frequencies(total_acc.max_ind),"%.2f") ' Hz'])
sgtitle( filename )
%
% 
%%
%from video 
fileName_video = 'testsets/radim01/MV2.mp4';
[vectorsCenterOfMotion,fs_video] = centerOfMotion_getVectors(fileName_video);
[ampSpects_centerOfMotion,total_com] = getAmpSpectsWithMax(vectorsCenterOfMotion ,fs_video);


% for ii = 1:3
% subplot(3,1,ii), plot(ampSpect{ii}.frequencies,ampSpect{ii}.values), title ('y freq');hold on;xlabel('freq [Hz]')
% stem(ampSpect{ii}.frequencies(ampSpect{ii}.max_ind),ampSpect{ii}.values(ampSpect{ii}.max_ind),'r')
% legend('y freq',['max ' num2str(ampSpect{ii}.frequencies(ampSpect{ii}.max_ind),"%.2f") ' Hz'])
% end

%%
plot(vectorsAccelerometer(:,1))

%% read 
function [ampSpects, total] = getAmpSpectsWithMax(vectors,fs)
ampSpect_total_values  = [];
    for ii = 1:size(vectors,2)
    vector =  vectors(:,ii);
    xfft = fft(vector);%removes mean -> better results for fft
    p1 = abs(xfft(1:round(length(xfft)/2)));%important part of freq spect
    x_tics = linspace(0,fs/2,length(p1));%x tics are same for both parts 
    [~, max_ind_p1] = max(p1);%get max 
    ampSpect.values = p1;
    ampSpect_total_values = [ampSpect_total_values p1];
    ampSpect.frequencies = x_tics';
    ampSpect.max_ind = max_ind_p1;
    ampSpects{ii} = ampSpect;
    end
    
    total.values = mean(ampSpect_total_values,2);
    [~, max_ind_p1_total] = max(total.values);%get max
    total.frequencies = ampSpects{1}.frequencies;
    total.max_ind = max_ind_p1_total;
    
end