function positions=findpeaks2D(im,N,nhood,threshold,mask)
%FINDPEAKS: Find peaks in an image to subpixel accuracy.
% 
%   Peaks in the image are found using LOCALMAXIMA. The 3x3 region around
%   each maximum is then used by SUBPIXEL to find an approximation of the
%   true peak position to subpixel accuracy.
% 
%   POSITIONS = FINDPEAKS(IM,N) finds N peaks in IM.
% 
%   POSITIONS = FINDPEAKS(IM,N,NHOOD) defines the flattening
%   neighbourhood NHOOD to be used in LOCALMAXIMA. The default is [71 71].
%
%   POSITIONS = FINDPEAKS(IM,N,NHOOD,THRESHOLD) finds peaks with a
%   minimum value of THRESHOLD. The default is MAX(MAX(im))/2. If N is
%   empty FINDPEAKS finds all peaks with a value above THRESHOLD.
%
%   POSITIONS = FINDPEAKS(IM,N,NHOOD,THRESHOLD,MASK) finds peaks but
%   replaces the positions with [0; 0] if they coincide with non-zero
%   values of MASK.
% 
%   See also: LOCALMAXIMA, SUBPIXEL

%   Copyright 2007 The MathWorks Ltd
%   $Revision: 1.2.1$  $Date: 2007-08-22$

if nargin<5||isempty(mask)  
    mask=zeros(size(im));
elseif size(mask)~=size(im)
    error('Mask must be the same size as input image')
end

if nargin<4
    threshold=max(max(im))/2;
end
if nargin<3
    nhood = [71 71];
end

pixels = localmaxima(im,N,threshold,nhood);
if isempty(N)
    N=size(pixels,2);
end

positions=zeros(2,N);
for i=1:N
    if(pixels(1,i)==0 && pixels(2,i)==0||mask(pixels(1,i),pixels(2,i)))
        continue
    end
    
    imheight=size(im,1);
    imwidth=size(im,2);
%     % Ignore cases where the pixels are too close to the edge.
%     if (pixels(1,i)-edgecutoff(1)) < 0 || pixels(2,i)-edgecutoff(2) < 0 || ...
%             pixels(1,i)+edgecutoff(1) > imheight || pixels(2,i)+edgecutoff(2) > imwidth
%         continue
%     end
    
%     roi=zeros(3);
    
    roi=getroi(im,pixels(:,i),3);
    
%     roirlow=1;
%     roirhigh=3;
%     roiclow=1;
%     roichigh=3;
%     % Choosing region boundary indices so that they don't go over the edge.
%     rlow = pixels(1,i)-1;
%     rhigh = pixels(1,i)+1;
%     clow = pixels(2,i)-1;
%     chigh = pixels(2,i)+1;
%     
%     if rlow<1
%         rlow=1;
%         roirlow=2;
%     end
%     if rhigh>size(im,1)
%         rhigh=size(im,1);
%         roirhigh=2;
%     end
%     if clow<1
%         clow=1;
%         roiclow=2;
%     end
%     if chigh>size(im,2)
%         chigh=size(im,2);
%         roichigh=2;
%     end
%     
%     roi(roirlow:roirhigh,roiclow:roichigh)=im(rlow:rhigh,clow:chigh);
    if numel(roi)==numel(zeros(3))
    delta=flipud(subpixel(roi));
    positions(:,i)=pixels(:,i)+delta;
    end
end