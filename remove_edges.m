function pc_indices = remove_edges(num_pixels_to_remove, x_dim, y_dim)
    pc_indices = [];
    count = 0;
    for i = 1:y_dim
        for j = 1:x_dim
            count = count + 1;
            if i <= num_pixels_to_remove | i > y_dim-num_pixels_to_remove | j <= num_pixels_to_remove | j > x_dim - num_pixels_to_remove
                pc_indices = [pc_indices; count];
            end
        end
    end
end