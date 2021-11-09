function [TheirLocs,crossLoc_dft,crossFlags1,crossFlags2]=MotionAnalyze_April15(videoName1,videoName2)
%% Jitter Analysis of gain=1 experiments
% videoName1: original video
% videoName2: online stabilized video
% Asieh Daneshi April. 2021

myVideo1=VideoReader(videoName1);
fNom1=myVideo1.FrameRate*myVideo1.Duration;    % Number of frames in the video

myVideo2=VideoReader(videoName2);
fNom2=myVideo2.FrameRate*myVideo2.Duration;    % Number of frames in the video



% vWrite=VideoWriter([videoName1(1:end-4),'_StabilizationCorrected.avi']);    % start a video to record jitter-free frames
% vWrite.FrameRate=30;
% open(vWrite);


%% finding the best position for the cross to align all the frames to it
flag=1;
d=1;
while flag
    [x2,y2,crossFlag2]=Cross_oneFrame_November4(myVideo2,0,d+1);
    locx=x2;
    locy=y2;
    d=d+1;
    if crossFlag2==1 && locx>250 && locx<462 && locy>250 && locy<462
        flag=0;
    end
end
% if the resulting frames were cropped and looked odd (as a result of
% inverse fourier transform) try to use the following values for locx, and locy
locx=356;
locy=356;

%%  removing jitters and making a new video
for b=1:fNom1-1
    [x1,y1,crossFlag1]=Cross_oneFrame_November4(myVideo1,0,b);
    [x2,y2,crossFlag2]=Cross_oneFrame_November4(myVideo2,0,b+1);
    crossFlags1(b)=crossFlag1;
    crossFlags2(b+1)=crossFlag2;
    if crossFlag1 && crossFlag2
        originalLocs(b,:)=[x1,y1];
        OriginalFrame=im2double(read(myVideo1,b));
        StabilizedFrame=im2double(read(myVideo2,b+1));
        [r,c]=find(StabilizedFrame);
        OriginalFramePadded=padarray(OriginalFrame,[100,100],0,'both');
        if (x1<100 || x1>512-100) || (y1<100 || y1>512-100) || (x2<100 || x2>712-100) || (y2<100 || y2>712-100)
            outlier(b)=1;
        else
            OriginalFrameCrop1=OriginalFrame(y1-44:y1+44,x1-100:x1-10);
            StabilizedFrameCrop1=StabilizedFrame(y2-44:y2+44,x2-100:x2-10);
            OriginalFrameCrop2=OriginalFrame(y1-44:y1+44,x1+10:x1+100);
            StabilizedFrameCrop2=StabilizedFrame(y2-44:y2+44,x2+10:x2+100);
            StabilizedFrameCrop=StabilizedFrame(y2-44:y2+44,x2-100:x2+100);
            Nxcorr=normxcorr2(StabilizedFrameCrop,OriginalFrame);
            if isempty(find(Nxcorr,1))
                outlier(b)=1;
            else
                [x3,y3]=find(Nxcorr==max(Nxcorr(:)));        % cross correlation
                [rs,cs]=find(StabilizedFrame);
                rpad(b)=min(rs(:));
                cpad(b)=min(cs(:));
                MyLocs(b,:)=([x3,y3]-[44,100])+[cpad(b),rpad(b)];
                TheirLocs(b,:)=[x2,y2];
                [output1,G1]=dftregistration(fft2(OriginalFrameCrop1),fft2(StabilizedFrameCrop1),1000);
                crossLoc_dft1(b,:)=[output1(3),output1(4)];    % dftregistration
                [output2,G2]=dftregistration(fft2(OriginalFrameCrop2),fft2(StabilizedFrameCrop2),1000);
                crossLoc_dft2(b,:)=[output2(3),output2(4)];    % dftregistration
                crossLoc_dft(b,:)=mean([crossLoc_dft1(b,:);crossLoc_dft2(b,:)]);
                
                [nr,nc]=size(StabilizedFrame);
                Nr=ifftshift((-fix(nr/2):ceil(nr/2)-1));
                Nc=ifftshift((-fix(nc/2):ceil(nc/2)-1));
                [Nc,Nr] = meshgrid(Nc,Nr);
                Greg=fft2(StabilizedFrame).*exp(1i*2*pi*(+((TheirLocs(b,2)-locy)*Nr/nr)+((TheirLocs(b,1)-locx)*Nc/nc)));
                Greg=Greg.*exp(-1i*output2(2));
                Shifts(b,:)=[output2(3)+(TheirLocs(b,2)-locy),output2(4)+(TheirLocs(b,1)-locx)];
%                 StabilizedFrameCorrected=ifft2(Greg);
%                 fig1=figure;
%                 imshow(StabilizedFrameCorrected,[])
%                 myFrame=getframe;
%                 writeVideo(vWrite,myFrame.cdata)
%                 close(fig1)
            end
        end
    end
end