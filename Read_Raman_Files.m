function Read_Raman_Files
% Reads Raman spectra from txt files.
% Each file contains the data for a single Raman spectrum:
%  X = Wavelength (cm-1)
%  Y = Raman intensity
% The name of the input file contains the coordinates at which the spectrum is taken.
% Results are stored in 'data.mat'.

files = dir('*.txt');
Ncurves = length(files);
if Ncurves==0, display('No txt files found!'); return; end
for i = 1:Ncurves,
	i
	fname = files(i).name;
	data = importdata(fname);
	if i==1, X = data(:,i); end
	Y(:,i) = data(:,2);
	dash = strfind(fname,'__');
	Xpos(i) = str2num(fname(strfind(fname,'Xµm_')+4:dash(2)-1));
	Ypos(i) = str2num(fname(strfind(fname,'Yµm_')+4:dash(3)-1));
end;
save('data.mat', 'Ncurves', 'X', 'Y', 'Xpos', 'Ypos');
return