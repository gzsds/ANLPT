function point_s = initPoints(region, step)
    % default region
    r = 10;
    % default step
    s = 2;
    if exist('region', 'var');  r = region; end
    if exist('step', 'var');    s = step;   end

    % a inline function returns the y corresponding to the x on the edge of circle
    partner = @(r, x) round(sqrt(r .^ 2 - x .^ 2));

    % init start point and points array with the shape (y, x)
    x = r;
    y = 0;
    point_s = [];
    % get points in interval [0, pi/4]
    while y < x
        point_s = [point_s; y, x];
        y_0 = y;
        x_0 = x;
        while (y - y_0) ^ 2 + (x - x_0) ^ 2 < s ^ 2
            y = y + 1;
            x = partner(r, y);
        end
    end

    % complete points array in the first quadrant
    point_s_inv = point_s(end : -1 : 1, : );
    point_s_inv = point_s_inv( : , end : -1 : 1);
    if point_s(end, : ) == point_s_inv(end, : )
        sta = 2;
    else
        sta = 1;
    end
    point_s = [point_s; point_s_inv(sta : end, :)];

    % complete points array in the second quadrant
    point_s_sec = point_s(end - 1 : -1 : 1, : );
    point_s_sec( : , 2) = -point_s_sec( : , 2);
    point_s = [point_s; point_s_sec];

    % complete points array in the second half circle
    point_s_half = point_s(end - 1 : -1 : 2, : );
    point_s_half( : , 1) = -point_s_half( : , 1);
    point_s = [point_s; point_s_half];
    
end