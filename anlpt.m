function T = anlpt(I, config)

    %% set parameters
    % default parameters
    psize = 50;
    stride = 50;
    region = 10;
    channel = 3;
    % parameters setting
    if ~exist('config', 'var')
        config = initConfig();
    end
    if isfield(config, 'patch_size');   psize = config.patch_size;      end
    if isfield(config, 'stride');       stride = config.stride;         end
    if isfield(config, 'region');       region = config.region;         end
    if isfield(config, 'channel');      channel = config.channel;       end
    %% preperation
    [h, w] = size(I);
    cell_T = cell(h, w);
    %% detecting
    row = 1;
    while row + psize - 1 <= h
        col = 1;
        while col + psize - 1 <= w
            %% construction
            [Tensor, Loc] = construct_r(I, row, col, config);
            %% decomposition
            % default configuration of decomposition
            opts.tol = 1e-8;
            opts.mu = 1e-4;
            opts.rho = 1.1;
            opts.DEBUG = 1;
            [n1, n2, n3] = size(Tensor);
            lambda = update_lambda(Tensor);
            % trpca with adaptive compromissing factor
            [Tens_B, Tens_T, err, iter] = trpca_tnn_adaptive(Tensor, lambda, opts);
            for c = 1 : channel
                patch_T = Tens_T( : , : , c);
                x_l = Loc(c, 2);
                y_l = Loc(c, 1);

                for u = 1 : n1
                    for v = 1 : n2
                        cell_T{y_l + u - 1, x_l + v - 1} = [cell_T{y_l + u - 1, x_l + v - 1}, patch_T(u, v)];
                    end
                end
            end
            
            col = col + increment(w, psize, stride, col);
        end
        row = row + increment(h, psize, stride, row);
    end
    %% reconstruction
    for u = 1 : h
        for v = 1 : w
            if isempty(cell_T{u, v})
                cell_T{u, v} = 0;
            end
            if u<=1||u>=h||v<=1||v>=h
                cell_T{u, v} = 0;
            end
            cell_T{u, v} = median(cell_T{u, v});
        end
    end
    T = uint8(mat2gray(pos(cell2mat(cell_T))) .* 255);
end

% caculate the increment of row and col after every iteration
function pixels = increment(len_i, psize, stride, local)

    residue = len_i - local - psize + 1;

    if residue > psize
        pixels = stride;
    else
        pixels = residue;
    end

    if pixels == 0
        pixels = 1;
    end
    
end