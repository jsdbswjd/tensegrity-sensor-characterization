function J = numericalJacobian(fun, x, varargin)
    % fun : 함수 핸들 (@(x) ...)
    % x   : 입력 벡터
    % varargin : fun에 전달할 추가 인자

    fx = fun(x, varargin{:});
    n  = length(x);
    m  = length(fx);
    J  = zeros(m, n);

    h = 1e-8; % 미분 스텝
    for i = 1:n
        x_step = x;
        x_step(i) = x_step(i) + h;
        fx_step = fun(x_step, varargin{:});
        J(:, i) = (fx_step - fx) / h;
    end
end