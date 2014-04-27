function Plot_Raman_Maps(varargin);
% Plot_Raman_Maps('min2D',0, 'max2D',Inf, 'max2Dw',Inf, 'minGf',0, 'minD_G',0, ...)
% Plots maps of Raman parameters (such as peak height, width and frequency).
% The arguments specify optional criteria for including or excluding data points in the maps:
%  'min2D' = minimum of 2D height; spectra with smaller values won't be shown
%  'max2D' = maximum of 2D height; spectra with larger values won't be shown
%  'min2Dw' = minimum of 2D width; spectra with smaller values won't be shown
%  'max2Dw' = maximum of 2D width; spectra with larger values won't be shown
%  etc.

for i = 1:nargin,
	if ischar(varargin{i}),	arg{i} = varargin{i}; else arg{i} = ''; end
end

% Check input arguments
[argcheck,ind] = ismember('min2D',arg);
if argcheck, min2D = varargin{ind+1}; else min2D = 1; end
[argcheck,ind] = ismember('max2D',arg);
if argcheck, max2D = varargin{ind+1}; else max2D = Inf; end
[argcheck,ind] = ismember('min2Dw',arg);
if argcheck, min2Dw = varargin{ind+1}; else min2Dw = 5; end
[argcheck,ind] = ismember('max2Dw',arg);
if argcheck, max2Dw = varargin{ind+1}; else max2Dw = Inf; end
[argcheck,ind] = ismember('min2Df',arg);
if argcheck, min2Df = varargin{ind+1}; else min2Df = 0; end
[argcheck,ind] = ismember('max2Df',arg);
if argcheck, max2Df = varargin{ind+1}; else max2Df = Inf; end
[argcheck,ind] = ismember('minG',arg);
if argcheck, minG = varargin{ind+1}; else minG = 0; end
[argcheck,ind] = ismember('maxG',arg);
if argcheck, maxG = varargin{ind+1}; else maxG = Inf; end
[argcheck,ind] = ismember('minGf',arg);
if argcheck, minGf = varargin{ind+1}; else minGf = 0; end
[argcheck,ind] = ismember('maxGf',arg);
if argcheck, maxGf = varargin{ind+1}; else maxGf = Inf; end
[argcheck,ind] = ismember('minGw',arg);
if argcheck, minGw = varargin{ind+1}; else minGw = 0; end
[argcheck,ind] = ismember('maxGw',arg);
if argcheck, maxGw = varargin{ind+1}; else maxGw = Inf; end
[argcheck,ind] = ismember('min2D_G',arg);
if argcheck, min2D_G = varargin{ind+1}; else min2D_G = 0; end
[argcheck,ind] = ismember('max2D_G',arg);
if argcheck, max2D_G = varargin{ind+1}; else max2D_G = Inf; end
[argcheck,ind] = ismember('minD_G',arg);
if argcheck, minD_G = varargin{ind+1}; else minD_G = 0; end
[argcheck,ind] = ismember('maxD_G',arg);
if argcheck, maxD_G = varargin{ind+1}; else maxD_G = Inf; end

% Load data
load data.mat; %variables: 'Ncurves', 'X', 'Y', 'Xpos', 'Ypos'
load 2D.mat;   %variables: 'twoD_h', 'twoD_f', 'twoD_w', 'noise'
load G.mat;    %variables: 'G_h', 'G_f', 'G_w'
load D.mat;    %variables: 'D_h', 'D_f', 'D_w'

figure('OuterPosition',get(0,'Screensize')); % Maximized figure
xo = min(Xpos); yo = min(Ypos);
dx = max(Xpos) - xo;
dy = max(Ypos) - yo;
Xrange = Xpos - xo;
Yrange = Ypos - yo;

% Determine blank areas
bk = -1;
D_G = D_h./G_h; D_G(G_h<=0) = bk;
twoD_G = twoD_h./G_h; twoD_G(G_h<=0) = bk;
blank = twoD_h < min2D | twoD_h > max2D | twoD_w > max2Dw | twoD_w < min2Dw | twoD_f < min2Df | twoD_f > max2Df | ...
	G_h < minG | G_h > maxG | G_f < minGf | G_f > maxGf | G_w < minGw | G_w > maxGw | ...
	twoD_G < min2D_G | twoD_G > max2D_G | D_G < minD_G | D_G > maxD_G;
twoD_h(blank) = bk; twoD_w(blank) = bk; twoD_f(blank) = bk;
G_h(blank) = bk; G_w(blank) = bk; G_f(blank) = bk;
D_h(blank) = bk; D_w(blank) = bk; D_f(blank) = bk;
x0 = mean(G_f(G_f>0)); y0 = mean(twoD_f(twoD_f>0));

% Create a grid matrix for the coordinates
XX = sort(unique(Xrange)); YY = sort(unique(Yrange));
Xsize = length(XX); Ysize = length(YY);
if Xsize*Ysize ~= Ncurves, stop; end
[Xgrid,sorter] = sort(Xrange);
Ygrid = Yrange(sorter);
Xgrid = reshape(Xgrid,Ysize,Xsize);
Ygrid = reshape(Ygrid,Ysize,Xsize);
grid = reshape(sorter,Ysize,Xsize);
for i = 1:Xsize,
	 [tmp,sorter] = sort(Ygrid(:,i));
	 Ygrid(:,i) = tmp;
	 grid(:,i) = grid(sorter,i);
end

% Reshape the Raman parameters into the grid matrix
twoD_h = reshape(twoD_h(grid),Ysize,Xsize);
twoD_w = reshape(twoD_w(grid),Ysize,Xsize);
twoD_f = reshape(twoD_f(grid),Ysize,Xsize);
G_h = reshape(G_h(grid),Ysize,Xsize);
G_f = reshape(G_f(grid),Ysize,Xsize);
G_w = reshape(G_w(grid),Ysize,Xsize);
D_h = reshape(D_h(grid),Ysize,Xsize);
D_f = reshape(D_f(grid),Ysize,Xsize);
D_w = reshape(D_w(grid),Ysize,Xsize);
twoD_G = twoD_h./G_h; twoD_G(G_h<=0) = bk;
D_G = D_h./G_h; D_G(G_h<=0) = bk;


% Plot maps
nrow = 2; ncol = 4;
%2D height
subplot(nrow, ncol, 1); i = twoD_h(twoD_h>0);
transparent(imagesc(XX,YY,twoD_h)); title('2D height');
axis image; caxis([min(i),max(i)]); colorbar;
%2D width
subplot(nrow, ncol, 2); i = twoD_w(twoD_w>0); 
transparent(imagesc(XX,YY,twoD_w)); title('2D width'); 
axis image; caxis([0,50]); colorbar;
%2D frequency
subplot(nrow, ncol, 3); i = twoD_f(twoD_f>0); 
transparent(imagesc(XX,YY,twoD_f)); title('2D freq'); 
axis image; caxis([min(i),max(i)]); colorbar;
%2D/G
subplot(nrow, ncol, 4); i = twoD_G(twoD_G>0);
transparent(imagesc(XX,YY,twoD_G)); title('2D/G'); 
axis image; caxis([min(i),max(i)]); colorbar;
%G height
subplot(nrow, ncol, 5); i = G_h(G_h>0);
transparent(imagesc(XX,YY,G_h)); title('G height'); 
axis image; caxis([min(i),max(i)]); colorbar;
%G width
subplot(nrow, ncol, 6); i = G_w(G_w>0);
transparent(imagesc(XX,YY,G_w)); title('G width'); 
axis image; caxis([min(i),max(i)]); colorbar;
%G frequency
subplot(nrow, ncol, 7); i = G_f(G_f>0);
transparent(imagesc(XX,YY,G_f)); title('G freq'); 
axis image; caxis([min(i),max(i)]); colorbar;
%D/G
subplot(nrow, ncol, 8); i = D_G(D_G>0);
transparent(imagesc(XX,YY,D_G)); title('D/G'); axis image; 
if max(i)>0, caxis([min(i),max(i)]); else caxis([0 0.01]); end; colorbar;


%--------------------------------------------
function transparent(img);
% Makes the points with CData = -1 transparent
colordata = get(img, 'CData');
alphadata = colordata; 
alphadata(colordata==-1) = 0;
alphadata(colordata~=-1) = 1;
set(img, 'AlphaData', alphadata);
end
