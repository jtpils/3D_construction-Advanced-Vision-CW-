function [new_M, new_D] = ransac(M, D, max_iter, samples, threshold_dist, threshold_percent)
    new_M = [];
    new_D = [];
    i = 0;
    while i < max_iter
        i = i+1;
        subset_ind = randperm(length(M), samples);
        M_s = M(subset_ind, :);
        D_s = D(subset_ind, :);
        [R, t] = get_transformation(M_s, D_s);
        M_t = R*M' + t;
        euclid_dist = sum((M_t - D').^2, 1).^0.5;
        if sum(euclid_dist < threshold_dist) > threshold_percent*length(M)
            new_M = [new_M; M_s];
            new_D = [new_D; D_s];
        end
        if mod(i, 10000) == 0
            [new_M,ia,~] = unique(new_M, 'rows', 'stable');
            new_D = new_D(ia, :);
            if size(new_M, 1) > 4
                i = max_iter + 1;
            else
                threshold_percent = threshold_percent-0.1;
                if threshold_percent <= 0.2
                    threshold_percent = 0.2;
                    threshold_dist = threshold_dist + 0.05;
                end
            end
        end
    end
end