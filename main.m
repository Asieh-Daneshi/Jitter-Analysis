close all
clear
clc

%% ========================================================================
fprintf('Please select all the videos you aim to analyze. (unstabilized videos)\n');
[videoName,PathName]=uigetfile('*.avi','MultiSelect', 'on');
stf=input('Please enter the number of first frame\n');    % starting frame
ef=input('Please enter the number of last frame\n');      % end frame

if ~iscell(videoName)
    video1=videoName;   % original video
    video2=[video1(1:end-4),'_stabilized.avi'];  % online stabilized video
    [motion,jitter,crossFlags1,crossFlags2]=MotionAnalyze_April15(video1,video2);
    save([video1(1:end-4),'_jitter.mat'],'jitter')
    save([video1(1:end-4),'_motion.mat'],'motion')
    
    containingCross1=find(crossFlags1~=0);
    containingCross2=find(crossFlags2~=0);
    containingCross2=intersect(containingCross2,[stf-1:ef+1]);
    myVideo=VideoReader(video1);
    fNom=myVideo.FrameRate*myVideo.Duration;
    finalShift=NaN(fNom,2);
    for a=1:length(containingCross1)
        finalShift(containingCross1(a),:)=motion(containingCross1(a),:)-motion(containingCross1(1),:)+jitter(containingCross1(a),:);
    end
    finalshiftp1=finalShift;
    finalshiftp1(isnan(finalshiftp1(:,1)),:)=0;
    finalshiftp2=[[0,0];finalshiftp1];
    movement=finalshiftp2(1:length(finalshiftp1),:)-finalshiftp1;
    [r,~]=find(movement>2);
    finalShift(r,:)=NaN;
    figure;subplot(1,2,1);plot(finalShift(:,1),'.');subplot(1,2,2);plot(finalShift(:,2),'.')
    containingCross=length(containingCross2);
    save([video1(1:end-4),'_finalShift.mat'],'finalShift')
else
    for Nom=1:length(videoName)
        video1=cell2mat(videoName(Nom));   % original video
        video2=[video1(1:end-4),'_stabilized.avi'];  % online stabilized video
        [motion,jitter,crossFlags1,crossFlags2]=MotionAnalyze_April15(video1,video2);
        save([video1(1:end-4),'_jitter.mat'],'jitter')
        save([video1(1:end-4),'_motion.mat'],'motion')
        containingCross1=find(crossFlags1~=0);
        containingCross2=find(crossFlags2~=0);
        containingCross2=intersect(containingCross2,[stf-1:ef+1]);
        myVideo=VideoReader(video1);
        fNom=myVideo.FrameRate*myVideo.Duration;
        finalShift=NaN(fNom,2);
        for a=1:length(containingCross1)
            finalShift(containingCross1(a),:)=motion(containingCross1(a),:)-motion(containingCross1(1),:)+jitter(containingCross1(a),:);
        end
        finalshiftp1=finalShift;
        finalshiftp1(isnan(finalshiftp1(:,1)),:)=0;
        finalshiftp2=[[0,0];finalshiftp1];
        movement=finalshiftp2(1:length(finalshiftp1),:)-finalshiftp1;
        [r,~]=find(movement>2);
        finalShift(r,:)=NaN;
        figure;subplot(1,2,1);plot(finalShift(:,1),'b.','markersize',10);subplot(1,2,2);plot(finalShift(:,2),'b.','markersize',10)
        containingCross(Nom)=length(containingCross2);
        save([video1(1:end-4),'_finalShift.mat'],'finalShift')
    end
end
% myset=setdiff(containingCross2,[stf-1:ef+1])
% close all
% myVideo1=VideoReader(video1);
% myVideo2=VideoReader(video2);
% for b=1:30
%     ref1=im2double(read(myVideo1,b));
%     ref2=im2double(read(myVideo2,b));
%     figure;
%     subplot(1,2,1);imshow(ref1,[])
%     subplot(1,2,2);imshow(ref2,[])
% end
% for b=1:length(containingCross)
%     containingCross(b)
%     ref=im2double(read(myVideo2,containingCross(b)+1));figure;imshow(ref,[])
% end