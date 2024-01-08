function [b,posoffset]=getroi(im,coords,siz,pad)


    if size(siz)==0
        error('Region size is empty')
    end
    
    if numel(siz)>2
        error('Region size must be no bigger than 2 elements')
    end
    
    if numel(coords)~=2
        error('Coordinate vector must have two elements')
    end
    
    if numel(siz)==1
        siz(1:2)=siz;
    end

    if (mod(siz(1),2)==0)||(mod(siz(2),2)==0)
        error('Region size must be odd')
    end
    
    if nargin<4
        pad=0;
    end
    
        posoffset=0;
    
    offset=(siz'-1)/2;
    
%     
%     points(1:2)=flipud(coords-offset);
%     points(3:4)=flipud(siz'-1);
%  
%         b=imcrop(im,points);
    
    % The useful part of imcrop. Imcrop itself spends a long time calling
    % ParseInputs.
    pixelHeight= siz(1)-1;
    pixelWidth = siz(2)-1;

    r1=coords(1)-offset(1);
    c1=coords(2)-offset(2);
    r2=r1+pixelHeight;
    c2=c1+pixelWidth;


    m = size(im,1);
    n = size(im,2);

    if ((r1 > m) || (r2 < 1) || (c1 > n) || (c2 < 1))
        b = [];
        return
    end
    
    if pad==1 && (r1<1 || r2>m || c1<1 || c2 > n)
        im=padarray(im,[pixelHeight pixelWidth],'replicate');
        c1=c1+pixelWidth;
        c2=c2+pixelWidth;
        r1=r1+pixelHeight;
        r2=r2+pixelHeight;
        posoffset=[pixelHeight;pixelWidth];
    end
%     if c1<1
        
    
    r1 = max(r1, 1);
    r2 = min(r2, m);
    c1 = max(c1, 1);
    c2 = min(c2, n);
    b = im(r1:r2, c1:c2, :);
    end

    

%     figure,imshow(b)
% h=imgca;
%     hold(h,'on');
% hold on
%     plot(offset(2)+1,offset(1)+1,'r.')
    
%     points