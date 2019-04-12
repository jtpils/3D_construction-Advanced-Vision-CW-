function fused_pc = fuse_frames(frames)
    fused_pc = frames{1, 2};
    for i = 1:(size(frames, 1)-1)
        i
        R = frames{i, 9};
        T = frames{i, 10};
        transformed_points = R*fused_pc.Location' + T;
        fused_pc = pointCloud(transformed_points', 'Color', fused_pc.Color);
        fused_pc = pcmerge(fused_pc, frames{i+1, 2}, 0.01);
    end
end