function mask = plot_binary_mask(ind_to_remove, x_dim, y_dim, display_img)
    mask = ones(x_dim*y_dim, 1);
    mask(ind_to_remove) = 0;
    mask = reshape(mask, [x_dim, y_dim])';
    if display_img
        figure(4); imshow(mask); title('Binary Mask');
    end
end