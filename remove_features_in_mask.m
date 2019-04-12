function [f,d] = remove_features_in_mask(f, d, mask)
    to_keep = [];
    for i = 1:size(f,2)
        if mask(uint64(f(2,i)), uint64(f(1,i))) == 1
            to_keep = [to_keep; i];
        end
    end
    f = f(:,to_keep);
    d = d(:,to_keep);
end