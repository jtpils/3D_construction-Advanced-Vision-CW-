function [R, T] = get_transformation(M, D)
    M_nan = isnan(M);
    D_nan = isnan(D);
    ind = find(M_nan(:,1)==0 & D_nan(:,1)==0);
    M = M(ind, :);
    D = D(ind, :);
    m = mean(M, 1);
    d = mean(D, 1);
    M = M - m;
    D = D - d;
    H = M'*D;
    [U,~,V] = svd(H);
    R = V*U';
    if det(R) > -1.0001 && det(R) < -0.9999
        V_new = V;
        V_new(:, 3) = V(:, 3)*-1;
        R = V_new*U';
    end
    T = d'-R*m';
end