clear
%% read in video
% framerate = 30; default for me
[video,framerate] = Video_load('video_test_4.mov'); % place path to video here
%% set up bounding box (this is static bounding box)
forpts = figure();
frame = video(100).cdata;
imagesc(frame);
axis image;axis off;
title('select the upper left point, lower right point, and this hit return');
[x ,y] = getpts(forpts);
close all;
bbox = floor([x(1) y(1) abs(x(1)-x(2)) abs(y(1)-y(2))]);

%% some manually recorded boxes for spatial averaging
% These are some default heartrate boxes (This are all accurate).
k = 1;    
% bbox = [191 283 156 75];% forehead video 4 (~60 bpm)
% bbox = [320 455 56 75]; % cheek video 4 (~60 bpm)
% bbox = [264 519 200 100]; % forehead video 6 (~70 bpm)
N = size(video,2);

%% simulate jitter
% This is to simulate camera shaking. The amount can be increased as the
% deviation of the Jitter (normal distribution) is.

% on the selected box by adding noise to the box parameters. Then resizing
% to a common size.
% Jitter = 5*randn(N,4);

% resize size
% R = [150 75];

%% calculate transient signal and average over space by channel
while k <= N
    frame = video(k).cdata;
    if k == 100
        figure
        fullout = insertObjectAnnotation(frame,'rectangle',bbox,'Forehead');
        imagesc(fullout)
        axis image
    end
    jbbox = bbox;% + round(Jitter(k,:));
    piece = frame(jbbox(2):jbbox(2)+jbbox(4),jbbox(1):jbbox(1)+jbbox(3),:);
%     piece = imresize(piece,R);
    T(1,k) = mean(mean(piece(:,:,1)));
    T(2,k) = mean(mean(piece(:,:,2)));
    T(3,k) = mean(mean(piece(:,:,3)));
    k = k + 1
end

%% amount to chop off beginning
% gets rid of beginning of video get rid of some error.
skip = 500;
T_prime = T(:,200:end-50)';

t = linspace(1,size(T_prime,1),size(T_prime,1))/framerate;

figure
title('Raw Time R,G,B Signals');
subplot 311
plot(t,T_prime(:,1),'r');
xlabel('time (sec)'); ylabel('average red');
subplot 312
plot(t,T_prime(:,2),'g');
xlabel('time (sec)'); ylabel('average green');
subplot 313
plot(t,T_prime(:,3),'b');
xlabel('time (sec)'); ylabel('average blue');




%% median filtering
% gets ride of values too many standard deviations from the median. This
% rules out extraneous outliers which will wreck havock in the signal
% separation. There is two iterations of this.

medians = median(T_prime,1);
dev = std(T_prime,0,1);
T_prime(:,1) = clamp(T_prime(:,1),[medians(1)-2*dev(1), medians(1)+2*dev(1)]);
dev = std(T_prime,0,1);
T_prime(:,1) = clamp(T_prime(:,1),[medians(1)-2*dev(1), medians(1)+2*dev(1)]);

dev = std(T_prime,0,1);
T_prime(:,2) = clamp(T_prime(:,2),[medians(2)-2*dev(2), medians(2)+2*dev(2)]);
dev = std(T_prime,0,1);
T_prime(:,2) = clamp(T_prime(:,2),[medians(2)-2*dev(2), medians(2)+2*dev(2)]);

dev = std(T_prime,0,1);
T_prime(:,3) = clamp(T_prime(:,3),[medians(3)-2*dev(3), medians(3)+2*dev(3)]);
dev = std(T_prime,0,1);
T_prime(:,3) = clamp(T_prime(:,3),[medians(3)-2*dev(3), medians(3)+2*dev(3)]);

%% mean subtraction
% take out DC term from each transient signal.

T_prime(:,1) = (T_prime(:,1) - mean(T(:,1)));%/std(T(:,1));
T_prime(:,2) = (T_prime(:,2) - mean(T(:,2)));%/std(T(:,2));
T_prime(:,3) = (T_prime(:,3) - mean(T(:,3)));%/std(T(:,3));

T_filt = T_prime;

%% ICA signal separation
% unmix the source signals from the sensor signals

B = jadeR(T_filt',3);
s = B' * T_filt';

%% mixed signal view
% the rest of code is for viewing the signals and spectra of the source
% signals.

figure
title('Raw Time R,G,B Signals');
subplot 311
plot(t,T_prime(:,1),'r');
subplot 312
plot(t,T_prime(:,2),'g');
subplot 313
plot(t,T_prime(:,3),'b');

%% unmixed signal view
figure 
title('Unmixed and filtered signals');
subplot 311
plot(t,s(1,:),'r');
xlabel('time (sec)'); ylabel('unmixed signal 1'); title('Unmixed Signals');
subplot 312
plot(t,s(2,:),'g');
xlabel('time (sec)'); ylabel('unmixed signal 2'); 
subplot 313
plot(t,s(3,:),'b');
xlabel('time (sec)'); ylabel('unmixed signal 3'); 

%% frequency view
f = linspace(0,framerate/2,size(s,2)/2)*60;
fy = fft(s,[],2);
lower = 54;
upper = 233;

figure
subplot 311
plot(f,abs(fy(1,1:end/2)),'r');
xlabel('bpm'); ylabel('signal 1');title('FFT of Unmixed Signals');
axis([45 200 0 max(abs(fy(3,lower:upper)))]);
subplot 312
plot(f,abs(fy(2,1:end/2)),'g');
xlabel('bpm'); ylabel('signal 2');
axis([45 200 0 max(abs(fy(3,lower:upper)))]);
subplot 313
plot(f,abs(fy(3,1:end/2)),'b');
xlabel('bpm'); ylabel('signal 3');
axis([45 200 0 max(abs(fy(3,lower:upper)))]);