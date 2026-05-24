% -------------------------------------------------------------------------
% Load-strain characterization of tensegrity-based strain sensor
% Experimental UTM compression data processing and visualization
%
% Author: yunjeong kim, nasu kim, namjung kim
% Associated paper:
% "Design and Characterization of a Tensegrity-Based Strain Sensor
%  for Large Deformations"
% -------------------------------------------------------------------------

%% Load experimental compression data
% Column 2: measured load (kgf)
% Column 4: displacement (mm)

data  = readmatrix('tensegrity_UTM_compression.xlsx');

loadg = data(:,2);
disp  = data(:,4);

%% Convert to engineering strain and load
% Initial structure height: 205 mm
% Load conversion: kgf -> N

strain = disp ./ 205;
loadN  = loadg * 9.81;

%% Remove invalid entries

strain = double(strain(:));
loadN  = double(loadN(:));

mask = isfinite(strain) & isfinite(loadN);
strain = strain(mask);
loadN  = loadN(mask);

%% Interpolate missing force values if necessary

if any(~isfinite(loadN))
    idx = find(isfinite(loadN));
    loadN = interp1(idx, loadN(idx), 1:numel(loadN), 'linear', 'extrap')';
end

%% Signal smoothing
% Median filter removes impulsive noise
% Savitzky-Golay filter preserves local trends
% Butterworth filter used for final low-pass smoothing

load_med = medfilt1(loadN, 11);

N = numel(load_med);
frameLen = max(7, 2*floor(0.02*N/2)+1);

polyOrd = 3;
y_sg = sgolayfilt(load_med, polyOrd, frameLen);

fc   = 0.01; 
[b,a] = butter(4, fc);

y_lp  = filtfilt(b, a, load_med);

y = y_lp;

%% Plot load-strain response

figure('Position',[100,100,700,400]);
plot(strain, y, 'Color','#77AC30', 'LineWidth', 2.3);

set(gca, 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ax = gca;
majX = 0:0.1:0.8; xticks(majX); 
minX = majX(1:end-1) + diff(majX)/2;
ax.XAxis.MinorTickValues = minX;

majY = 0:0.5:4; yticks(majY);
minY = majY(1:end-1) + diff(majY)/2;
ax.YAxis.MinorTickValues = minY;

ax.XMinorTick = 'on';
ax.YMinorTick = 'on';


xlabel('strain', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Times New Roman');
ylabel('load(N)', 'FontWeight', 'bold', 'FontSize', 20, 'FontName', 'Times New Roman');
box on;
