%% ===============================================================
%  ΔR → ε → F  추정 (3채널)  —  m_i 캘리브레이션 & ν 보정 버전
%  INPUT:
%    - r_var_log_20250730_000426_num31.csv  (R1,R2,R3가 2,4,6 column)
%    - string_stress_interp.mat             (strain_data, stress_data 포함)
%  OUTPUT:  eps_i(t), F_i(t), summary plot
%% ===============================================================
clear; clc;

%% MATLAB string164766
dataM = readtable('M4_string_forces_log_with_disp.txt', 'Delimiter', '\t');
displacement = -dataM.Displacement;

% Force, Length datas
F16 = dataM.FString16;
F47 = dataM.FString47;
F66 = dataM.FString66;

L16 = dataM.LString16;
L47 = dataM.LString47;
L66 = dataM.LString66;

%% ------------------ 0) Load resistance file --------------------------
data  = readtable('r_var_log_20250730_000426_num3.csv', 'VariableNamingRule','preserve');
load('string_stress_interp.mat'); % strain_data, stress_data

% 'true' or 'engineering'
stress_kind = 'engineering';

% 보간기 (외삽 NaN)
stress_interp = @(eps) interp1(strain_data, stress_data, eps, 'pchip', NaN);

%% ------------------ 1) 기하/상수 ------------------------------
nu = 0.48;                                 % Poisson5s ratio
D0_m = 1e-3;                               % String's diameter [m] (1 mm)
A0   = pi/4 * D0_m^2;                      % Initial cross-sectional area [m^2]
W0   = pi * D0_m;                          % Initial circumference [m]

% 프리텐션/길이 스케일: 채널별 (명시적)
L_eff = [0.0457, 0.0415, 0.0435];          % [m]  ΔL = ε_fromR * L_eff
L_ref = [0.0420, 0.0390, 0.0400];          % [m]  ε_final = (ΔL + dL0)/L_ref
dL0   = [0.0032, 0.0025, 0.0028];          % [m]  pre-stretched length

% 2선식 접촉항 비율(무시부터 시작)
alpha = [0,0,0];                           % α_i = 2Rc/R0  (필요시 0.03~0.05 등 실험치로)

%% ------------------ 2) 저항 시계열 · 스무딩 -------------------

R1f = data{:,2}; R2f = data{:,4}; R3f = data{:,6};

% Savitzky–Golay 스무딩
w = 99; p = 3;                              % (w: 홀수)

R1s = sgolayfilt(R1f, p, w);
R2s = sgolayfilt(R2f, p, w);
R3s = sgolayfilt(R3f, p, w);

% 기준 R0: 초기 n0 샘플 중앙값(시팅/노이즈 완화)
n0  = min(50, numel(R1s));
R01 = median(R1s(1:n0));
R02 = median(R2s(1:n0));
R03 = median(R3s(1:n0));

% ΔR 정규화
y1 = (R1s - R01)./R01;     % y = ΔR/R0
y2 = (R2s - R02)./R02;
y3 = (R3s - R03)./R03;

%% ------------------ 3) m_i 캘리브레이션 -----------------------
% “실험 끝(압축 80%)”에서의 참값 ε_end (각 스트링, 사용자 제공)
eps_end_true = [0.162, 0.133, 0.178];      % <== 네가 준 값

% 끝 샘플 인덱스(지금은 전체 로그의 마지막이 '끝'이라고 가정)
idx_end1 = numel(y1);
idx_end2 = numel(y2);
idx_end3 = numel(y3);

% lam_target = 실험에서 목표로 하는 ‘절대’ 신장비(프리텐션/길이 스케일 포함)
%   eps_abs = ((lam-1)*L_eff + dL0)/L_ref  ⇒  lam = 1 + (eps_abs*L_ref - dL0)/L_eff
lam_tgt1 = 1 + (eps_end_true(1)*L_ref(1) - dL0(1))/L_eff(1);
lam_tgt2 = 1 + (eps_end_true(2)*L_ref(2) - dL0(2))/L_eff(2);
lam_tgt3 = 1 + (eps_end_true(3)*L_ref(3) - dL0(3))/L_eff(3);

% m_i 계산:
%   y_end = (ΔR/R0)_end,  (1+y_end/(1-α)) = lam^m  ⇒  m = ln(1+y/(1-α)) / ln(lam_tgt)
m1 = log(1 + y1(idx_end1)/(1 - alpha(1))) / log(lam_tgt1);
m2 = log(1 + y2(idx_end2)/(1 - alpha(2))) / log(lam_tgt2);
m3 = log(1 + y3(idx_end3)/(1 - alpha(3))) / log(lam_tgt3);

fprintf('m1=%.4f, m2=%.4f, m3=%.4f (기하 m=1+nu≈%.2f)\n', m1,m2,m3, 1+nu);

%% ------------------ 4) ε(t) 계산 (상대 → 절대) -----------------
% 상대 ε_fromR: lam_fromR = (1 + y/(1-α))^(1/m) ,  ε_fromR = lam_fromR - 1
lam1 = (1 + y1/(1 - alpha(1))).^(1/m1);   eps_fromR1 = lam1 - 1;
lam2 = (1 + y2/(1 - alpha(2))).^(1/m2);   eps_fromR2 = lam2 - 1;
lam3 = (1 + y3/(1 - alpha(3))).^(1/m3);   eps_fromR3 = lam3 - 1;

% 절대 ε_final (프리텐션/길이 스케일 적용)
eps1 = (eps_fromR1 .* L_eff(1) + dL0(1)) / L_ref(1);
eps2 = (eps_fromR2 .* L_eff(2) + dL0(2)) / L_ref(2);
eps3 = (eps_fromR3 .* L_eff(3) + dL0(3)) / L_ref(3);

% (검증) 끝점이 참값과 일치하는지 확인
eps_end_hat = [eps1(end), eps2(end), eps3(end)];
fprintf('eps_end_hat = [%.3f %.3f %.3f]  vs  true = [%.3f %.3f %.3f]\n', ...
        eps_end_hat, eps_end_true);

%% ------------------ 5) 힘 추정 F(t) ---------------------------
% 응력 보간 후 힘:
switch lower(stress_kind)
    case 'true'
        % True(Cauchy) stress 가 주어진 경우:  F = σ_true * A_current
        % A_current = A0 * lam^{-2ν} (등방 가로수축)
        F1 = stress_interp(eps1) .* A0 .* (1+eps1).^(-2*nu);
        F2 = stress_interp(eps2) .* A0 .* (1+eps2).^(-2*nu);
        F3 = stress_interp(eps3) .* A0 .* (1+eps3).^(-2*nu);
    case 'engineering'
        % Engineering stress 가 주어진 경우: F = σ_eng * A0
        F1 = stress_interp(eps1) .* A0;
        F2 = stress_interp(eps2) .* A0;
        F3 = stress_interp(eps3) .* A0;
    otherwise
        error('stress_kind must be ''true'' or ''engineering''.');
end

% Optional: 스무딩(보기 좋게)
F1s = sgolayfilt(F1, p, w);
F2s = sgolayfilt(F2, p, w);
F3s = sgolayfilt(F3, p, w);

%% ------------------ 6) (선택) 20%% 구간만 보기 -----------------
% 전체 길이 중 20% 구간 샘플 수 (원하면 고정값으로 대체 가능: Nkeep20=1125;)
Nkeep20 = round(0.20 * numel(R1f));
Nkeep20 = min([Nkeep20, numel(eps1), numel(eps2), numel(eps3)]);  % 안전
idx20    = 1:Nkeep20;

%% ------------------ 7) 플롯 -------------------------------
figure(1); clf;
plot(sgolayfilt(eps1, p, w),'b','LineWidth',2, 'DisplayName', 'R1'); hold on;
plot(sgolayfilt(eps2, p, w),'r-.','LineWidth',2, 'DisplayName', 'R2');
plot(sgolayfilt(eps3, p, w),'color', [0, 0.5, 0],'LineStyle', ':','LineWidth', 2.5 , 'DisplayName', 'R3');

yline(eps_end_true(1),'b--', 'HandleVisibility','off');
yline(eps_end_true(2),'r--', 'HandleVisibility','off');
yline(eps_end_true(3),'color', [0, 0.5, 0], 'LineStyle', '--', 'HandleVisibility','off');

set(gca, 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ax = gca;
majX = 0:1000:4000; xticks(majX); 
minX = majX(1:end-1) + diff(majX)/2;
ax.XAxis.MinorTickValues = minX;

majY = 0:0.03:0.24; yticks(majY);
minY = majY(1:end-1) + diff(majY)/2;
ax.YAxis.MinorTickValues = minY;

ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

xlabel('samples','FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');
xlim([0 4300]); 
ylabel('strain','FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');
legend('FontName', 'Times New Roman','FontWeight', 'bold', 'FontSize', 8);
%title('Estimated strain from \DeltaR (absolute)');
% lgd1 = legend('R1','R2','R3','R1 true end','R2 true end','R3 true end','Location','northwest');
% lgd1.FontSize = 6;


mask = (displacement <= 0.032) & isfinite(F16) & isfinite(F47) & isfinite(F66);
idxMask = find(mask);

% 공통 길이 맞추기: (displacement≤0.04인 샘플 수) vs (Fig.3의 idx20 길이)
nCommon = min([numel(idxMask), numel(idx20), numel(F1s), numel(F2s), numel(F3s)]);
idxMask = idxMask(1:nCommon);
idx20_c = idx20(1:nCommon);

% 슬라이스
x = displacement(idxMask) .*1000;                 % x축: 변위 [m]
F16_sub = F16(idxMask); F47_sub = F47(idxMask); F66_sub = F66(idxMask);   % PVW
F1_sub  = F1s(idx20_c);  F2_sub  = F2s(idx20_c);  F3_sub  = F3s(idx20_c); % ΔR→F (Fig.1)


%% ------------------ 9) Cross-correlation alignment ------------------

% 채널 하나 기준으로 먼저 검증 (예: String16 ↔ R3)
FR = F3_sub(:);     % Resistance 기반 force
FP = F16_sub(:);    % PVW force

% NaN 제거
valid = isfinite(FR) & isfinite(FP);
FR = FR(valid);
FP = FP(valid);

% 평균 제거 (중요)
FR = FR - mean(FR);
FP = FP - mean(FP);

% cross-correlation
[c,lags] = xcorr(FR, FP, 'coeff');

% 최대 상관
[~,I] = max(c);
lag_opt = lags(I);

fprintf('\n===== Cross-correlation Result =====\n');
fprintf('Optimal lag = %d samples\n', lag_opt);
fprintf('Max correlation = %.4f\n', c(I));

% shift 적용
if lag_opt > 0
    FR_shift = FR(1+lag_opt:end);
    FP_shift = FP(1:end-lag_opt);
elseif lag_opt < 0
    FR_shift = FR(1:end+lag_opt);
    FP_shift = FP(1-lag_opt:end);
else
    FR_shift = FR;
    FP_shift = FP;
end

% RMSE 계산 (정렬 후)
RMSE_align = sqrt(mean((FR_shift - FP_shift).^2));
fprintf('Aligned RMSE = %.4f N\n', RMSE_align);

% 정렬 전 RMSE
RMSE_raw = sqrt(mean((FR - FP).^2));
fprintf('Raw RMSE = %.4f N\n', RMSE_raw);

% 플롯
figure(2); clf; hold on;

% PVW (실선)
plot(x, F16_sub, 'color', [0, 0.5, 0], 'LineWidth', 2.5,'LineStyle', ':', 'DisplayName', 'String 16 (PVW)');
plot(x, F47_sub, 'r-.' , 'LineWidth', 2.5, 'DisplayName', 'String 47 (PVW)');
plot(x, F66_sub, 'b--' , 'LineWidth', 2.5, 'DisplayName', 'String 66 (PVW)');

%Resistance (점선, Fig.1의 첫 20% 구간)
plot(x, F3_sub , 'color', [0, 0.5, 0], 'LineStyle', '--','LineWidth', 1, 'DisplayName', 'R3 (String16)');
plot(x, F2_sub , 'r' , 'LineStyle', '--','LineWidth', 1, 'DisplayName', 'R2 (String47)');
plot(x, F1_sub , 'b' , 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', 'R1 (String66)');

set(gca, 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ax = gca;
xlim([0 32]);
majX = 0:10:32; xticks(majX); 
minX = majX(1:end-1) + diff(majX)/2;
ax.XAxis.MinorTickValues = minX;

majY = 0:0.2:2.2; yticks(majY);
minY = majY(1:end-1) + diff(majY)/2;
ax.YAxis.MinorTickValues = minY;

ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

xlabel('Displacement (mm)', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');
ylabel('Force (N)', 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Times New Roman');

lgd = legend({'R3 (String16)', 'R2 (String47)', 'R1 (String66)'}, ...
    'Location','northwest','FontName','Times New Roman', 'FontSize',10);

%text(0.017, 1.43, 'Solid: PVW   Dashed: Resistance', 'FontName','Times New Roman', 'FontSize',11);
box on

%title('PVW vs $\Delta$R-based Force (Displacement $\le$ 0.04 m)');
%% ------------------ 8) 요약 출력 ---------------------------
S = table( (1:3).', [R01;R02;R03], [m1;m2;m3], eps_end_hat.', eps_end_true.', ...
    'VariableNames', {'Ch','R0_ohm','m_eff','eps_end_hat','eps_end_true'});
disp(S);


figure;
plot(FP, 'k', 'LineWidth',1.5); hold on;
plot(FR, 'r--');
legend('PVW','Resistance (raw)');
title('Before alignment');

figure;
plot(FP_shift, 'k', 'LineWidth',1.5); hold on;
plot(FR_shift, 'r--');
legend('PVW','Resistance (aligned)');
title('After alignment (cross-correlation)');
