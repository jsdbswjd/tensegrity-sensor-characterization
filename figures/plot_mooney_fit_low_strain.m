load('string_stress_interp.mat');  % strain_data, stress_data (Pa)

lambda_data = 1 + strain_data;

% --- Mooney-Rivlin 모델 ---
mooney_model = @(C, lambda) 2*(C(1) + C(2)./lambda) .* (lambda - 1./lambda.^2);

% --- 전체 구간 (≤0.8)으로 피팅 ---
obj_fun = @(C) sum( (mooney_model(C, lambda_data) - stress_data).^2 );

C0 = [1e5, 1e5];

opts = optimoptions('fminunc','Display','iter','Algorithm','quasi-newton');
[C_fit, fval] = fminunc(obj_fun, C0, opts);

%% =======================
% 📊 평가: strain ≤ 0.2만 사용
%% =======================
mask_eval = strain_data <= 0.2;

strain_eval = strain_data(mask_eval);
lambda_eval = 1 + strain_eval;
stress_eval = stress_data(mask_eval);

stress_fit_eval = mooney_model(C_fit, lambda_eval);

% --- 성능 지표 ---
SS_tot = sum( (stress_eval - mean(stress_eval)).^2 );
SS_res = sum( (stress_eval - stress_fit_eval).^2 );

R_squared = 1 - SS_res/SS_tot;
RMSE = sqrt(mean( (stress_eval - stress_fit_eval).^2 ));

% NRMSE (range 기반)
NRMSE = RMSE / (max(stress_eval) - min(stress_eval));

fprintf('--- Evaluation (strain ≤ 0.2) ---\n');
fprintf('R² = %.5f\n', R_squared);
fprintf('RMSE = %.3f kPa\n', RMSE/1e3);
fprintf('NRMSE = %.5f\n', NRMSE);

fprintf('\n--- Fitted Parameters (strain ≤ 0.8 fit) ---\n');
fprintf('C1 = %.3e Pa\n', C_fit(1));
fprintf('C2 = %.3e Pa\n', C_fit(2));

%% =======================
% 📈 Plot (0 ~ 0.2만 표시)
%% =======================

lambda_fine = linspace(1, 1.2, 500);  % strain 0~0.2
strain_fine = lambda_fine - 1;
stress_fit = mooney_model(C_fit, lambda_fine);

% 실험 보간
stress_interp = @(eps) pchip(strain_data, stress_data, eps);

eps_fine = linspace(0, 0.2, 500);
sigma_nom_exp = stress_interp(eps_fine);

figure; clf;
plot(strain_fine, stress_fit/1e6, 'r-', 'LineWidth', 4, ...
     'DisplayName','Mooney-Rivlin');
hold on;
plot(eps_fine, sigma_nom_exp/1e6, 'b--', 'LineWidth', 2.5, ...
     'DisplayName','Original SS curve');

set(gca, 'FontSize', 20, 'FontWeight','bold', 'FontName','Times New Roman');

ax = gca;

majX = 0:0.05:0.2; xticks(majX);
minX = majX(1:end-1) + diff(majX)/2;
ax.XAxis.MinorTickValues = minX;

majY = 0:1:5; yticks(majY);
minY = majY(1:end-1) + diff(majY)/2;
ax.YAxis.MinorTickValues = minY;

ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

xlabel('Strain', 'FontWeight','bold','FontSize',20,'FontName','Times New Roman');
ylabel('Nominal stress (MPa)', ...
       'FontWeight','bold','FontSize',20,'FontName','Times New Roman');

axis([0 0.2 0 5]);
axis square

legend('FontName','Times New Roman','FontSize', 13, ...
       'FontWeight', 'bold','Location','NorthWest');