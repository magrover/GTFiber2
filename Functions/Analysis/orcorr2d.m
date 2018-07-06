function ims = orcorr2d(ims)

% Get image size in nanometers
nmSize = size(ims.gray).*ims.nmPix;

% Generate lists of segment vectors and one of their endpoints
fiberXY = {ims.Fibers(:).xy_nm};

vecs = cellfun(@(pts) diff(pts,1,2),fiberXY,'UniformOutput',false);
vecPts = cellfun(@(pts) pts(:,1:end-1),fiberXY,'UniformOutput',false);

vecList = [vecs{:}];
ptList = [vecPts{:}];

N=size(vecList,2);
disp(N)

% Make bins equal to image size + 1 in x and y directions
% But numBins is half the number of bins (only in positive directions)
numBins = round(size(ims.gray)/2);
db = nmSize./numBins;

% hh is a 2D histogram with bins for each pixel of the image and
% three entries at each bin:
% 1: number of vector pairs in that spatial bin
% 2: <cos(2*theta)> for all vector pairs in that bin
hh = zeros([2.*numBins+1, 2]);

% pre-compute product of vector magnitudes for dot product
mag = ims.settings.fiberStep_nm^2;

% Iterate over all vector pairs, excluding self-pairs
hwait=waitbar(0,'Calculating Orientation Correlation Array...');
for i = 1:N-1
%     disp(N-i)
    waitbar(i/N,hwait)
    for j = i+1:N
        % Compute distance vector
        dd = ptList(:,i)-ptList(:,j);
        
        % Convert to bin number
        bb = round(fliplr(dd')./db) + numBins + 1;
        bi = bb(1); bj = bb(2);
        if bi<1; bi=1; end
        if bj<1; bj=1; end
        if bi>2*numBins(1)+1; bi=2*numBins(1)+1; end
        if bj>2*numBins(2)+1; bj=2*numBins(2)+1; end
        
        % Increment histogram count
        hh(bi,bj,1)=hh(bi,bj,1)+1;
        
        % Compute rolling average of angle cosine
        hh(bi,bj,2)= hh(bi,bj,1)/(hh(bi,bj,1)+1)*hh(bi,bj,2)...
                  + 1/(hh(bi,bj,1)+1)...
                    * cos(2*acos((vecList(1,i)*vecList(1,j)+vecList(2,i)*vecList(2,j))/mag));
        
    end
end

% Rotate the matrix by 180 and average with itself to mirror the
% orientations
hh(:,:,1) = hh(:,:,1) + rot90(hh(:,:,1),2);
hh(:,:,2) = (hh(:,:,2) + rot90(hh(:,:,2),2)) ./ 2;

[X, Y] = meshgrid((-nmSize(1):db(1):nmSize(1)),(nmSize(2):-db(2):-nmSize(2)));
hh(:,:,3) = X;
hh(:,:,4) = Y;

ims.OrCorr2D = hh;

close(hwait)

end