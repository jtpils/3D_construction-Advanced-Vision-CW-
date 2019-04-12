function [f,d] = extract_sift(rgb, mask)
    I = single(rgb2gray(im2double(rgb)));

    [f,d] = vl_sift(I);
    
    to_keep = [];
    for i = 1:size(f,2)
        if mask(uint64(f(2,i)), uint16(f(1,i))) == 1
            to_keep = [to_keep; i];
        end
    end
    f = f(:,to_keep);
    d = d(:,to_keep);
end