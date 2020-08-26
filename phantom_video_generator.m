%% sinus tremor
clc, clear all;

% Video definition
M=480; N=640; %matrix dimensions
m = M/2; n = N/2; %center of object (default values = m = M/2, n = N/2)
a=50; %object dimension
fps = 30; %fps
d = 256/30; %duration of video (in seconds)
f = 5; % frequency(in Hz)
amp = M/4; %amplitude (default value = axis/4)
noise = 0.001; %noise (0 = no noise, default noise = 0.001)
noise_type = 'gaussian'; % ('salt & pepper' or 'gaussian')
name="Video_"+fps+"fps_"+f+"Hz_";

%% Sinus definition
ff= f/(fps/(2*pi));
t = 0:ff:fps*ff*d;
sinus = sin(t);
sinus = sinus*amp;
sinus = round(sinus);


%% square
A = zeros(M, N,3);
A((m-a/2):(m+a/2),(n-a/2):(n+a/2),:) = 1;
name = name+"Square_";

%% Circle 
x=(1:M).';
y=1:N;
r=a/2;
A = zeros(M, N, 3);
A=(x-m).^2 + (y-n).^2 <= r^2; 
A = 255 * repmat(uint8(A), 1, 1, 3);
name = name+"Circle_";

%% X axis tremor
for i = 1:length(sinus)
    if sinus(i) >= 0
        AA = zeros(M,uint8(sinus(i)),3);
        A1= A(:,1:end-sinus(i),:);
        A2 = [AA A1];
    elseif sinus(i) < 0
         AA = zeros(M,uint8(abs(sinus(i))),3);
         A1= A(:,abs(sinus(i)-1):end,:);
         A2 = [A1 AA];
    end
    Array{i} = A2;
end
name = name+"X_axis_tremor";
%% Video creation
name = name+".avi";
video = VideoWriter(name);
video.FrameRate = fps;
open(video);
for i=1:length(Array)
  Frame = im2frame(Array{i});
  writeVideo(video,Frame); %write the image to file
end
close(video);
%% Play video
Frames=zeros(M,N);

for i=1:length(Array)
  Frames(:,:,i) = rgb2gray(Array{1,i});
end
implay(Frames, fps);