function [positions,vals]=localmaxima(im,count,threshold,neighbourhood)
%LOCALMAXIMA: find local maxima in an input matrix.
%
%   Local maxima are found by using MAX to find a maximum and then setting
%   the neighbourhood to 0 so it is not included in subsequent searches. A
%   default neighbourhood of [3 3] is used.
%
%   [POSITIONS,VALS] = LOCALMAXIMA(X,N) finds N local maxima in X and
%   outputs their coordinates and values.
%
%   POSITIONS = LOCALMAXIMA(X,N,THRESHOLD) finds up to N local maxima with
%   value greater than THRESHOLD. The default is 0. A matrix of size 2xN is
%   returned. If the number of local maxima found is less than N, the end
%   of the matrix is filled with zeros.
%
%   POSITIONS = LOCALMAXIMA(X,[],THRESHOLD) finds all local maxima with
%   value greater than THRESHOLD.
%
%   POSITIONS = LOCALMAXIMA(X,N,THRESHOLD,NHOOD) defines the flattening
%   neighbourhood. The neighbourhood must have odd dimensions. The default
%   is [5 5].
%
%   See also: IMREGIONALMAX, IMHMAX

%   Copyright 2007 The MathWorks Ltd
%   $Revision: 1.0$  $Date: 2007-07-24$

if nargin<2
    error('Function requires input matrix and maximum number of maxima');
end

if nargin<3
    if(isempty(count))
        error('Without a threshold you must specify a number of maxima to find')
    end
    threshold=0;
end

if nargin>3
    if (mod(neighbourhood(1),2)==0 || mod(neighbourhood(2),2)==0)
        error('Neighbourhood must be odd');
    end
else
    neighbourhood=[5 5];
end

nhoodoffset=(neighbourhood-1)./2;

% Preallocate.
if(~isempty(count))
positions=zeros(2,count);
vals=zeros(count);
else
    positions=[0;0];
    count=numel(im);
end

rmax=size(im,1);
cmax=size(im,2);
for i=1:count
%     imsize=size(im);
    [maxval,index]=max(im(:));
    [rowindex, colindex]=ind2sub(size(im),index);
%     [maxval,colindex]=max(maxima);

    if maxval<threshold||maxval==0
        break;
    end
%     rowindex=rowindices(colindex);
    positions(1,i)=rowindex;
    positions(2,i)=colindex;
    vals(i)=maxval;
    if(i<count)
        % Make sure it doesn't go off the edges.
        rlow=max([rowindex-nhoodoffset(1), 1]);
        rhigh=min([rowindex+nhoodoffset(1),rmax]);
        clow=max([colindex-nhoodoffset(2),1]);
        chigh=min([colindex+nhoodoffset(2),cmax]);

        % Set the neighbourhood to 0.

        im( (rlow:rhigh),(clow:chigh)  )=0;
    end

end
