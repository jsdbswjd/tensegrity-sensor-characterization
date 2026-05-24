function grad = mooney_energy_gradient_plate_0407(x, N, C_s, C_b, kb, l0_s, l0_b, fixed_nodes, F_ext, As, ...
    constraint_bottom, constraint_top, C_fit, stiffness_penalty)

n_nodes = size(N, 2);
free_nodes = setdiff(1:n_nodes, fixed_nodes);

% 복원된 위치 배열
N_free = reshape(x, 3, []);
N(:, free_nodes) = N_free;

%% Strings
u_s = N(:, C_s(:,1)) - N(:, C_s(:,2));
l_s = sqrt(sum(u_s.^2, 1));
dl_s = l_s - l0_s';
dE_s = zeros(3, n_nodes);

% Mooney-Rivlin constants
C1 = C_fit(1);
C2 = C_fit(2);

for i = 1:size(C_s,1)
    a = C_s(i,1); 
    b = C_s(i,2);

    if l_s(i) ~= 0
        dir = u_s(:,i) / l_s(i);
    else
        dir = zeros(3,1);
    end

    strain = dl_s(i) / l0_s(i);

    if strain < 0
        f = zeros(3,1);  % slack string
    else
        lambda = 1 + strain;
        stress = 2 * (C1 + C2 / lambda) * (lambda - 1 / lambda^2);
        A_eff = As / lambda;   % incompressibility assumption
        f = stress * A_eff * dir;
    end

    dE_s(:,a) = dE_s(:,a) + f;
    dE_s(:,b) = dE_s(:,b) - f;
end

%% Bars
u_b = N(:, C_b(:,1)) - N(:, C_b(:,2));
l_b = sqrt(sum(u_b.^2, 1));
dl_b = l_b - l0_b';
dE_b = zeros(3, n_nodes);

for i = 1:size(C_b,1)
    a = C_b(i,1); 
    b = C_b(i,2);

    if l_b(i) ~= 0
        dir = u_b(:,i) / l_b(i);
    else
        dir = zeros(3,1);
    end

    f = kb(i) * dl_b(i) * dir;
    dE_b(:,a) = dE_b(:,a) + f;
    dE_b(:,b) = dE_b(:,b) - f;
end

%% Constraint forces using stiffness penalty
dE_c = zeros(3, n_nodes);   % constraint force 분리

floor_z = min(N(3, [3, 5, 9]));          % bottom limit
plate_z_max = max(N(3, [26, 32, 36]));   % current plate height

% Bottom constraint
for i = 1:length(constraint_bottom)
    idx = constraint_bottom(i);
    z_val = N(3, idx);

    if z_val < floor_z
        dz = floor_z - z_val;
        dE_c(3, idx) = dE_c(3, idx) + stiffness_penalty * dz;
    end
end

% Top constraint
for i = 1:length(constraint_top)
    idx = constraint_top(i);
    z_val = N(3, idx);

    if z_val > plate_z_max
        dz = z_val - plate_z_max;
        dE_c(3, idx) = dE_c(3, idx) - stiffness_penalty * dz;
    end
end

%% 결과: 외력 - 내부력
grad_all = dE_s + dE_b + dE_c - F_ext;
grad = reshape(grad_all(:, free_nodes), [], 1);

end