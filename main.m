clear; clc;

% Read the Raman spectra
if ~exist('data.mat'), Read_Raman_Files; end

% Fit the 2D peak
success = true;
if ~exist('2D.mat'), success = Fit_Raman_Peak('2D',1.5); end
if ~success, return; end

% Fit the G peak
if ~exist('G.mat'), success = Fit_Raman_Peak('G',1.5); end
if ~success, return; end

% Fit the D peak
if ~exist('D.mat'), success = Fit_Raman_Peak('D',0.5); end
if ~success, return; end

Plot_Raman_Maps('min2D',10, 'min2D_G',0.1); return
