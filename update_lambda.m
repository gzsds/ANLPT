function la = update_lambda(T)
    [n1, n2, n3] = size(T);
    la = 0;
    for i = 1 : n3
        la = la + entropy(uint8(T( : , : , i)));
    end
    % disp(operator_sigmoid(la / n3))
    la = operator_sigmoid(la / n3) / sqrt((max(n1, n2) * n3));
end

function y = operator_sigmoid(x)
    y = (1 / (1 + exp(-x / 2.5)) - 0.4) * 5;
end