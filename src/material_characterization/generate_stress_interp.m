data = readmatrix('5.csv');  % [strain, stress] 형식이라 가정
strain_data = data(:,7);
stress_data_MPa = data(:,6);
stress_data = stress_data_MPa *1e6; % 이미 Pa로 변환 완료함
[T_unique, ~, ic] = unique(strain_data); %strain 값 오름차순, 중복 제거
S_avg = accumarray(ic, stress_data, [], @mean);
%ic가 가리키는 인덱스대로 stress_data 그룹으로 묶고, 각 그룹마다 평균 값을 계산

strain_data = T_unique;
strain_data = strain_data / 100;
stress_data = S_avg;

% 보간 함수 생성
string_stress_interp = @(strain) interp1(strain_data, stress_data, strain, 'linear', 'extrap');

% 보간 범위 정보 저장
min_strain = min(strain_data);
max_strain = max(strain_data);

% 저장
save('string_stress_interp.mat', 'string_stress_interp', 'min_strain', 'max_strain', 'strain_data', 'stress_data');
