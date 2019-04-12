function distance = separation(plane1_pc,plane2_pc)
    center_plane1 = [mean(plane1_pc.Location(:,1)), mean(plane1_pc.Location(:,2)), mean(plane1_pc.Location(:,3))]
    center_plane2 = [mean(plane2_pc.Location(:,1)), mean(plane2_pc.Location(:,2)), mean(plane2_pc.Location(:,3))]
    distance = norm(center_plane1 - center_plane2)
end

