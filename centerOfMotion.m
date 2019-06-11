%% Center of motion algoritm test
%%
%% load video, change size, convert to gray
addpath('testsets/radim01');
% for oo = 2:6
% videoName = ['MV' num2str(oo) '.mp4'];
videoName = 'MV1.mp4';
v = VideoReader(videoName);
fs = v.FrameRate;
%reduce size for faster computation 
sizeReductionFactor = 0.1;%1 -> same resolution; 0.5 -> half resolution
sizeX = round(v.Height*sizeReductionFactor);
sizeY= round(v.Width*sizeReductionFactor);
%variable for video in gray
V3 = zeros([sizeX sizeY   round(v.FrameRate * v.Duration)]);
ii = 1;%just for progress notification
while hasFrame(v)
    %change size and convert to gray
    V3(:,:,ii) = mat2gray(rgb2gray( imresize(readFrame(v),[sizeX sizeY])));
    ii = ii+1;
    ii
end

V3Diff = diff(V3,1,3);%difference of consequent frames -> motion detection

tic
x_centers = zeros(1,size(V3Diff,3));
y_cemters = zeros(1,size(V3Diff,3));

V4_e = zeros([size(V3Diff,1),size(V3Diff,2),3,length(V3Diff)]);%for showing currnet centerOfMass
centerOfMotionX = size(V3Diff,2) /2;%kdyby byl 1. diff 0 (stejny prvni a druhy frame)
centerOfMotionY = size(V3Diff,1) /2;

x = 1 : size(V3Diff, 2); 
y = 1 : size(V3Diff, 1); 
[X, Y] = meshgrid(x, y);
for ii = 1:size(V3Diff,3)%for every frame
    
    % A = imbinarize(abs(V4D(:,:,ii)));
    A = mat2gray(V3Diff(:,:,ii));%this is important part that creates something
    %different than centerOfMass, but works great
    
    
    meanA = mean(A,'all');
    if(meanA~=0)% In case of same frames is diff 0 -> centerOfMotion will be copied from previous frame
        centerOfMotionX = mean(A(:) .* X(:)) / meanA;
        centerOfMotionY = mean(A(:) .* Y(:)) / meanA;
    end
    
    x_centers(ii) = centerOfMotionX;
    y_cemters(ii) = centerOfMotionY;
    
    
    if false %create video with point in com. (slows computation)
        V4_e_current = cat(3,V3Diff(:,:,ii),V3Diff(:,:,ii),V3(:,:,ii));
        if (~isnan(centerOfMotionX) && ~isnan(centerOfMotionY))
            V4_e_current =insertShape( V4_e_current,'FilledCircle',[centerOfMotionX,centerOfMotionY,8]);
        end
        V4_e(:,:,:,ii) = V4_e_current ;
    end
    
end
toc

% implay(V4_e)


xfft = fft(x_centers - mean(x_centers));%removes mean -> better results for fft
p1 = abs(xfft(1:round(length(xfft)/2)));%important part of freq spect

yfft = fft(y_cemters- mean(y_cemters));
p2 = abs(yfft(1:round(length(yfft)/2)));

pAvg = mean([p1;p2]);%avg of x and y freq spect

x_tics = linspace(0,fs/2,length(p1));%x tics are same for both parts 

[max_val_p1, max_ind_p1] = max(p1);%get max 
[max_val_p2, max_ind_p2] = max(p2);
[max_val_pMean, max_ind_pMean] = max(pAvg);

%plots:
fig = figure;
subplot 321, plot(x_centers), title ('motion in x direction'),xlabel('frames')
subplot 322, plot(y_cemters), title ('motion in y direction'),xlabel('frames')

subplot 323, plot(x_tics,p1), title ('x freq');hold on;xlabel('freq [Hz]')
stem(x_tics(max_ind_p1),max_val_p1,'r')
legend('x freq',['max ' num2str(x_tics(max_ind_p1),"%.2f") ' Hz'])

subplot 324, plot(x_tics,p2), title ('y freq');hold on;xlabel('freq [Hz]')
stem(x_tics(max_ind_p2),max_val_p2,'r')
legend('y freq',['max ' num2str(x_tics(max_ind_p2),"%.2f") ' Hz'])

subplot 313, plot(x_tics,pAvg), title ('avg freq');hold on;xlabel('freq [Hz]')
stem(x_tics(max_ind_pMean),max_val_pMean,'r')
legend('avg freq',['max ' num2str(x_tics(max_ind_pMean),"%.2f") ' Hz'])

sgtitle( videoName )

% saveas(fig,['media/img_result_centerofmotion_' videoName '.png'])
% end