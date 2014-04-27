function success = Fit_Raman_Peak(peakname,S_N)
% Fit_Raman_Peak(peakname, signal_to_noise)
% An interactive function for fitting lorentzian curves to the 2D, G, and D 
%   peaks of the Raman spectra stored in 'data.mat'.
% After each fit, the result is plotted and the GUI waits for a button click:
%   'Continue' to fit the next spectrum
%   'Pause OFF' to continue fitting without pausing
%   'Plot OFF' to continue fitting without plotting
% Returns TRUE or FALSE, indicating the success of the fit.

load data.mat; %variables: 'Ncurves', 'X', 'Y', 'Xpos', 'Ypos'

% Determine the peak range
switch peakname,
	case '2D'
		peak = X>2600 & X<2800; %peak range
		base = X>2500 & ~peak; %baseline range
		fit0 = [1; 2700; 15; 0]; %initial fit estimates
	case 'G'
		peak = X>1500 & X<1700; %peak range
		base = X>1400 & X<1800 & ~peak; %baseline range
		fit0 = [1; 1580; 10; 0]; %initial fit estimates
	case 'D'
		peak = X>1300 & X<1400; %peak range
		base = X<1500 & ~peak; %baseline range
		fit0 = [1; 1350; 10; 0]; %initial fit estimates
end

% Initialize variables
Xpeak = X(peak); 
success = false;
plot_on = true; %Indicates if the spectra should be plotted
pause_on = true; %Indicates if the GUI should pause after plotting each spectrum
figure;

% Calculate the background noise
range = X>1900 & X<2200; %Flat region of the spectra
fit = polyfit(X(range), Y(range,1), 1); %Linear fit to the background
fit = polyval(fit, X(range)); 
[noise_y,noise_x] = hist(Y(range,1)-fit); %Residual noise
[ymax,i] = max(noise_y);
fit = [ymax; noise_x(i); (max(noise_x)-min(noise_x))/4]; %Initial estimates for noise fitting
fit = lsqcurvefit(@gaussian, fit, noise_x, noise_y); %Fit gaussian to the noise
noise = 2 * fit(3);
signal = noise * S_N;

% Plot the noise histogram
bar(noise_x,noise_y); 
title(['Noise = ', num2str(noise), ';   Press key to continue.']);
hold on; 
plot(noise_x,gaussian(fit,noise_x),'r'); 
hold off;
k = waitforbuttonpress;

% Draw action buttons for plot options
figuresize = get(gcf,'Position');
PlotOFF = uicontrol('Style','togglebutton', 'String','Plot OFF', 'Position',[20 0 60 20], 'Callback','uiresume', 'Value',~plot_on);
PauseOFF = uicontrol('Style','togglebutton', 'String','Pause OFF', 'Position',[figuresize(3)/2-30 0 60 20], 'Callback','uiresume', 'Value',~pause_on);
Continue = uicontrol('Style','pushbutton', 'String','Continue', 'Position',[figuresize(3)-80 0 60 20], 'Callback','uiresume');
for i = 1:Ncurves,
	% Subtract the baseline
	basefit = polyfit(X(base), Y(base,i), 1); %Linear fit to the base line
	Ybase = polyval(basefit, Xpeak);
	Ypeak = Y(peak,i) - Ybase;
	Ymax = max(Ypeak);
	if Ymax >= signal,
		fit0(1) = Ymax; 
		[fit,a,a,success] = lsqcurvefit(@lorentzian, fit0, Xpeak, Ypeak); %Lorentzian fit
		para(1,i) = fit(1); para(2,i) = fit(2); para(3,i) = fit(3);
	else
		success = true;
		para(1:3,i) = 0;
	end
	if plot_on,
		plot(X,Y(:,i),'b.'); title(i); %Plot the raw data
		if para(1,i) > 0,
			hold on;
			plot(Xpeak, Ybase, 'r:'); %Plot the baseline
			plot(Xpeak, lorentzian(fit,Xpeak)+Ybase, 'r'); %Plot the lorentzian fit
			hold off; 
		end
		if ~success, %Give an error message
			beep;
			answer = questdlg('Keep or delete this data point?','Lorentzian Fit Failed!','Keep','Delete','Stop','Delete');
			switch answer,
				case 'Delete',
					disp(['Data point ', num2str(i), ' deleted.']);
					para(1:3,i) = 0;
				case 'Stop'
					disp('Fitting failed!');
					close;
					return
			end
		end
	else 
		i %if plot is off then display the index of the current spectrum
	end
	if plot_on & i < Ncurves, 
		% Wait for button click
		if pause_on, uiwait; else pause(0.01); end
		plot_on = ~get(PlotOFF,'Value');
		pause_on = ~get(PauseOFF,'Value');
		if pause_on, set(Continue,'Enable','on'); else set(Continue,'Enable','off'); end
		if ~plot_on, close; end
	end
end

% Remove the action buttons
if plot_on, 
	set(Continue, 'Visible', 'off');
	set(PlotOFF, 'Visible', 'off');
	set(PauseOFF, 'Visible', 'off');
end

% Save peak parameters
switch peakname, 
	case '2D'
		twoD_h = para(1,:); twoD_f = para(2,:); twoD_w = para(3,:);
		save('2D.mat', 'twoD_h', 'twoD_f', 'twoD_w', 'noise');
	case 'G'
		G_h = para(1,:); G_f = para(2,:); G_w = para(3,:);
		save('G.mat', 'G_h', 'G_f', 'G_w');
	case 'D'
		D_h = para(1,:); D_f = para(2,:); D_w = para(3,:);
		save('D.mat', 'D_h', 'D_f', 'D_w');
end
disp('Fitting completed.');
success = true;

%---------------------------------------------------------
function f = gaussian(p,x)
f = p(1) * exp(-((x-p(2))/p(3)).^2);
%---------------------------------------------------------
function f = lorentzian(p,x), 
f = p(1)./(1+((x-p(2))/p(3)).^2)+p(4);