fileName_txt = 'testsets/radim01/MV2.txt';
fileName_video = 'testsets/radim01/MV2.mp4';
vectorsAccelerometer = accelerometer_data_reading(fileName_txt);
fs_accelerometer = 100;
ampSpects_accelerometer = getAmpSpectsWithMax(vectorsAccelerometer ,fs_accelerometer);
[vectorsCenterOfMotion,fs_video] = centerOfMotion_getVectors(fileName_video);
ampSpects_centerOfMotion = getAmpSpectsWithMax(vectorsCenterOfMotion ,fs_video);

% for ii = 1:3
% subplot(3,1,ii), plot(ampSpect{ii}.frequencies,ampSpect{ii}.values), title ('y freq');hold on;xlabel('freq [Hz]')
% stem(ampSpect{ii}.frequencies(ampSpect{ii}.max_ind),ampSpect{ii}.values(ampSpect{ii}.max_ind),'r')
% legend('y freq',['max ' num2str(ampSpect{ii}.frequencies(ampSpect{ii}.max_ind),"%.2f") ' Hz'])
% end

%%
plot(vectorsAccelerometer(:,1))

%% read 
function [ampSpects] = getAmpSpectsWithMax(vectors,fs)
    for ii = 1:size(vectors,2)
    vector =  vectors(:,ii);
    xfft = fft(vector);%removes mean -> better results for fft
    p1 = abs(xfft(1:round(length(xfft)/2)));%important part of freq spect
    x_tics = linspace(0,fs/2,length(p1));%x tics are same for both parts 
    [~, max_ind_p1] = max(p1);%get max 
    ampSpect.values = p1;
    ampSpect.frequencies = x_tics';
    ampSpect.max_ind = max_ind_p1;
    ampSpects{ii} = ampSpect;
    end
end