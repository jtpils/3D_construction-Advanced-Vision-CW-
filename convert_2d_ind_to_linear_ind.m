function linear_ind = convert_2d_ind_to_linear_ind(ind, x_dim)
    linear_ind = [];
    for i = 1:size(ind, 2)
        linear_ind = [linear_ind; x_dim*(uint64(ind(2,i))-1) + uint64(ind(1,i))];
    end
end