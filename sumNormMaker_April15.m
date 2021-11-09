function [sumNorm]=sumNormMaker_April15(videoName,PathName)
%% This code makes sumNorm from the stabilized video
% Load input video, and receive the sumNorm image with the same name as
% input video
% Asieh Daneshi April. 2021
myVideo=VideoReader([PathName,filesep,videoName]);
fNom=myVideo.FrameRate*myVideo.Duration;  
for a=1:fNom
    I(:,:,a)=im2double(read(myVideo,a));
end
[sx,sy,sz]=size(I);
for a1=1:sx
    for a2=1:sy
        sumNorm(a1,a2)=sum(I(a1,a2,:))/length(nonzeros(I(a1,a2,:)));
    end
end