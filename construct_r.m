function [X, Loc] = construct_r(I, y, x, config)

    % default configuration
    psize = 50;
    region = 10;
    channel = 3;
    points = [];

    % parameters setting
    if isfield(config, 'patch_size');   psize = config.patch_size;  end
    if isfield(config, 'region');       region = config.region;     end
    if isfield(config, 'channel');      channel = config.channel;   end
    if isfield(config, 'points');       points = config.points;     end

    % initialize output tensor
    X = zeros(psize, psize, channel);
    % fprintf('y: %d, x: %d\n', y, x);
    X( : , : , 1) = I(y : y + psize - 1, x : x + psize - 1);
    % initialize location list
    loc_list = zeros(channel, 6);
    loc_list( : , 3) = inf;
    loc_list( : , 6) = inf;
    e_0 = entropy(I(y : y + psize - 1, x : x + psize - 1));
    loc_list(1, 1 : 3) = [y, x, e_0];
    % init entropy array
    ent_ary = inf(channel, length(points));
    [y_next, x_next, e_next, ent_s] = search_r(I, y, x, e_0, points, psize);
    loc_list(1, 4 : 6) = [y_next, x_next, e_next];
    ent_ary(1, : ) = ent_s;

    for i = 2 : channel
        % matching
        [mbd, idx] = min(abs(loc_list( : , 6) - loc_list( : , 3)));
        y_0 = loc_list(idx, 1);
        x_0 = loc_list(idx, 2);
        e_0 = loc_list(idx, 3);
        y_i = loc_list(idx, 4);
        x_i = loc_list(idx, 5);
        e_i = loc_list(idx, 6);
        loc_list(i, 1 : 3) = [y_i, x_i, e_i];
        X( : , : , i) = I(y_i : y_i + psize - 1, x_i : x_i + psize - 1);
        if (i == channel)
            break;
        end
        [y_next, x_next, e_next, ent_s] = search_r(I, y_i, x_i, e_i, points, psize);
        loc_list(i, 4 : 6) = [y_next, x_next, e_next];
        ent_ary(i, : ) = ent_s;

        % update old block
        [dy_new, dx_new, e_new, ent_new] = updateSearchDomain(y_i - y_0, x_i - x_0, e_0, ent_ary(idx, : ), points, region);
        loc_list(idx, 4 : 6) = [y_0 + dy_new, x_0 + dx_new, e_new];
        ent_ary(idx, : ) = ent_new;
        % update new block
        [dy_new, dx_new, e_new, ent_new] = updateSearchDomain(y_0 - y_i, x_0 - x_i, e_i, ent_ary(i, : ), points, region);
        loc_list(i, 4 : 6) = [y_i + dy_new, x_i + dx_new, e_new];
        ent_ary(i, : ) = ent_new;
    end

    Loc = loc_list( : , 1 : 2);

end


function [dy_o, dx_o, e_o, ent_s] = updateSearchDomain(dy, dx, e_r, ent_s, points, region)

    % [lic, idx] = ismember([dy, dx], points, 'row');
    for i = 1 : length(points)
        dy_i = points(i, 1);
        dx_i = points(i, 2);
        if (dx_i - dx) ^ 2 + (dy_i - dy) ^ 2 < region ^ 2
            ent_s(i) = inf;
        else
            continue;
        end
    end
    [mbd, idx] = min(abs(ent_s - e_r));
    dy_o = points(idx, 1);
    dx_o = points(idx, 2);
    e_o = ent_s(idx);
    
end
