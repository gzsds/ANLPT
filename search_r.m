function [y_o, x_o, e_o, ent_s] = search_r(I, y, x, e_ref, points, psize)

    [h, w] = size(I);
    % init mbd array
    ent_s = inf(length(points), 1);
    % init mbd
    mbd = inf;
    % ergodic circle in first quadrant
    for i = 1 : length(points)
        % init match points
        x_i = x + points(i, 2);
        y_i = y + points(i, 1);
        if x_i < 1 || y_i < 1 || x_i > w - psize + 1 || y_i > h - psize + 1
            continue;
        end
        e_i = entropy(I(y_i : y_i + psize - 1, x_i : x_i + psize - 1));
        ent_s(i) = e_i;
        if abs(e_ref - e_i) < mbd
            mbd = abs(e_ref - e_i);
            x_o = x_i;
            y_o = y_i;
            e_o = e_i;
        end
    end
    
end