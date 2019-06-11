%% videoCreator
% script for creating simple chessboard like videos with predefined
% frequency, frame rate and duration
%% testing fft of step signal

%props inicialization
framesForOnePic = 12;
fs = 60;
halfSize = 128;%half size of resolution
totalFrames = 500;
f = fs/framesForOnePic/2

%just testing on 1d signal
repmatFactor = round(totalFrames/framesForOnePic/2);
v = repmat([ones(1,framesForOnePic) zeros(1,framesForOnePic)],[1 repmatFactor]);

%testing way how to get fft
%t = 0:1/fs:10;
%v = sin(2*pi*10*t);
% plot(v);

vfft = fft(v);
p1 = vfft(1:round(length(vfft)/2));
plot(linspace(0,fs/2,length(p1)),abs(p1))
%% Create and save video 

A_chess_1sec = repmat([zeros(halfSize) ones(halfSize);ones(halfSize) zeros(halfSize)],1,1,3,framesForOnePic);
A_black_1sec = zeros([halfSize*2,halfSize*2,3,framesForOnePic]);
Avide = repmat(cat(4,A_chess_1sec,A_black_1sec),[1 1 1 repmatFactor]);
% implay(Avide)

% autoname
saveVideo(Avide,['chess_' num2str(halfSize*2) '_fs' num2str(fs) 'Hz_f'  num2str(f,"%.2f") 'Hz_' num2str(totalFrames) 'Fr'])

function saveVideo (video4d,name)
v = VideoWriter(name);
v.FrameRate = 30;
open(v);
writeVideo(v,video4d)
close(v)
end

