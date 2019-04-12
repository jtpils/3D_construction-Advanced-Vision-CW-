% run('/home/david/Desktop/Master/Semester_2/Advanced Vision/Assignment/vlfeat-0.9.21/toolbox/vl_setup.m')
%% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
%% Load the test data
% office = load('office2.mat');
% office = office.pcl_test;
visualise = true;

%% 3.1 Preprocessing and SIFT feature extraction.
processed_frames = {};
x_dim = 640;
y_dim = 480;
max_point_depth = 4;
edge_pixels_to_remove = 5;
edge_indices = remove_edges(edge_pixels_to_remove, x_dim, y_dim);
for i = 1:length(office)
    i
    rgb = office{i}.Color; 
    point = office{i}.Location;
    ind_to_delete = find(point(:,3) > max_point_depth); % Remove distant points.
    if i == 27 
        person_indices = find(point(:,3) < 2 & point(:,1) < 0);
        ind_to_delete = [ind_to_delete; person_indices]; % Remove person from frame 27.
    end
    ind_to_delete = [ind_to_delete; edge_indices];
    
    point(ind_to_delete, :) = NaN;
    rgb(ind_to_delete, :) = NaN;
    
    %flying_pix_ind = remove_flying_pixels(point, 0.15, 100, x_dim);
    %point(flying_pix_ind, :) = NaN;
    %rgb(flying_pix_ind, :) = NaN;
    %ind_to_delete = [ind_to_delete; flying_pix_ind];
    
    pc = pointCloud(point, 'Color', rgb);
    new_rgb = imag2d(rgb, false);
    old_rgb = imag2d(office{i}.Color, visualise);
    mask = plot_binary_mask(ind_to_delete, x_dim, y_dim, visualise);
    
    if visualise
        figure(2); pcshow(pc); title('Original Point Cloud');
        figure(3); pcshow(pc); title('Processed Point Cloud');
        pause;
    end

    %% Extract SIFT features
    [f,d] = extract_sift(old_rgb, mask);
    
    %% Store preprocessed data
    processed_frames{i, 1} = new_rgb;
    processed_frames{i, 2} = pc;
    processed_frames{i, 3} = f;
    processed_frames{i, 4} = d;
end

%% Match 3D points in frame i and frame i+1, using matched SIFT features.
for i = 1:(length(processed_frames)-1)
    i
    [matches, scores] = vl_ubcmatch(processed_frames{i, 4}, processed_frames{i+1, 4}, 5);
    if size(matches(2)) <= 10
        [matches, scores] = vl_ubcmatch(processed_frames{i, 4}, processed_frames{i+1, 4}, 2.25);  
    end
    matchedSiftPoints1 = processed_frames{i, 3}(:, matches(1,:));
    matchedSiftPoints2 = processed_frames{i+1, 3}(:, matches(2,:));
    
    f1_match_ind = convert_2d_ind_to_linear_ind(matchedSiftPoints1(1:2, :), x_dim);
    f2_match_ind = convert_2d_ind_to_linear_ind(matchedSiftPoints2(1:2, :), x_dim);
    
    processed_frames{i, 5} = matchedSiftPoints1;
    processed_frames{i, 6} = f1_match_ind;
    processed_frames{i+1, 7} = matchedSiftPoints2;
    processed_frames{i+1, 8} = f2_match_ind;
    
    %% Visualisation of matched SIFT feature points in frame i and i+1.
    if visualise
        %figure(20); title('SIFT Features'); imshow(processed_frames{i, 1});
        %f1_m = vl_plotframe(matchedSiftPoints1);
        %set(f1_m,'color','r','linewidth', 2);
        %f1_no_match = processed_frames{i, 3}(:, setdiff(1:end, matches(1,:)));
        %f1_no_m = vl_plotframe(f1_no_match);
        %set(f1_no_m,'color','r','linewidth', 2);
        
        figure(5); title('Matched SIFT Features'); subplot(1,2,1); imshow(processed_frames{i, 1});
        f1_m = vl_plotframe(matchedSiftPoints1);
        set(f1_m,'color','g','linewidth', 2);
        f1_no_match = processed_frames{i, 3}(:, setdiff(1:end, matches(1,:)));
        f1_no_m = vl_plotframe(f1_no_match);
        set(f1_no_m,'color','r','linewidth', 2);
    
        subplot(1,2,2); imshow(processed_frames{i+1, 1});
        f2_m = vl_plotframe(matchedSiftPoints2);
        set(f2_m,'color','g','linewidth', 2);
        f2_no_match = processed_frames{i+1, 3}(:, setdiff(1:end, matches(2,:)));
        f2_no_m = vl_plotframe(f2_no_match);
        set(f2_no_m,'color','r','linewidth', 2);
        pause;
    end
end

%% Find 3D transformation from frame i to frame i+1.
for i = 1:(length(processed_frames)-1)
    i    
    M = processed_frames{i, 2}.Location(processed_frames{i, 6}, :);
    D = processed_frames{i+1, 2}.Location(processed_frames{i+1, 8}, :);
    [M, D] = ransac(M, D, 100000, 4, 0.1, 0.9);
    [R, T] = get_transformation(M, D);
    processed_frames{i, 9} = R;
    processed_frames{i, 10} = T;
    
    %% Visualisation
    if visualise
        %figure(6); pcshow(processed_frames{i, 2});
        %figure(7); pcshow(processed_frames{i+1, 2});
        merged_pc = fuse_frames(processed_frames(i:i+1, :));
        figure(8); pcshow(merged_pc); title('Merged Point Clouds');
        all_merged_pc = fuse_frames(processed_frames(1:i+1, :));
        figure(9); pcshow(all_merged_pc); title('All Merged Point Clouds');
        pause;
    end
end

%% Fuse frames
fused_pc = fuse_frames(processed_frames);
figure(10); pcshow(fused_pc); title('3D Reconstruction of the Office');

%% Evaluation
%[plane1_pc, plane2_pc, plane3_pc] = fit_plane(fused_pc);
[plane1_pc, plane2_pc, plane3_pc] = fit_plane_backup(fused_pc);
%distance = separation(plane1_pc, plane2_pc);