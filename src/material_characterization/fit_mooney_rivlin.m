% --- 실험 데이터 불러오기 ---
load('string_stress_interp.mat');  % strain_data, stress_data (Pa)

% --- stretch ratio ---
lambda_data = 1 + strain_data;

% --- Mooney-Rivlin (Nominal stress) ---
mooney_model = @(C, lambda) 2*(C(1) + C(2)./lambda) .* (lambda - 1./lambda.^2);

% --- 목적 함수 (Nominal vs Nominal) ---
obj_fun = @(C) sum((mooney_model(C, lambda_data) - stress_data).^2);

% --- 초기값 ---
C0 = [1e5, 1e5];

% --- 최적화 ---
opts = optimoptions('fminunc','Display','iter','Algorithm','quasi-newton');
[C_fit, fval] = fminunc(obj_fun, C0, opts);

% --- 피팅 결과 ---
lambda_fine = linspace(min(lambda_data), max(lambda_data), 500);
strain_fine = lambda_fine - 1;
stress_fitted = mooney_model(C_fit, lambda_fine);

stress_fitted_interp = mooney_model(C_fit, lambda_data);

%% =======================
% 📊 성능 지표 (Nominal 기준)
%% =======================

SS_tot = sum((stress_data - mean(stress_data)).^2);
SS_res = sum((stress_data - stress_fitted_interp).^2);

R_squared = 1 - SS_res / SS_tot;
RMSE = sqrt(mean((stress_data - stress_fitted_interp).^2));

% NRMSE
range_stress = max(stress_data) - min(stress_data);
NRMSE = RMSE / range_stress;

fprintf('NRMSE = %.5f (%.2f%%)\n', NRMSE, NRMSE*100);
fprintf('R² = %.5f\n', R_squared);
fprintf('RMSE = %.3f kPa\n', RMSE / 1e3);
fprintf('C1 = %.3e Pa\n', C_fit(1));
fprintf('C2 = %.3e Pa\n', C_fit(2));

%% =======================
% 📈 시각화 (Nominal stress)
%% =======================

figure;
plot(strain_fine, stress_fitted/1e6, 'r-', ...
     'DisplayName', 'Mooney-Rivlin', 'LineWidth', 4);
hold on;

plot(strain_data, stress_data/1e6, 'bo', ...
     'DisplayName', 'Experiment');

set(gca, 'FontSize', 13, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ax = gca;

majX = 0:0.2:0.8; xticks(majX); 
minX = majX(1:end-1) + diff(majX)/2;
ax.XAxis.MinorTickValues = minX;

majY = 0:2:14; yticks(majY);
minY = majY(1:end-1) + diff(majY)/2;
ax.YAxis.MinorTickValues = minY;

ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

xlabel('Strain', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');
ylabel('Nominal Stress (MPa)', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');

legend;

save('mooney_constants.mat', 'C_fit');