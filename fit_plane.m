function [plane1, plane2, plane3] = fit_plane(fused_pc)
    maxDistance = 0.1;
    %referenceVector = [0,0,1];
    %maxAngularDistance = 5;


    [model1,inlierIndices,outlierIndices] = pcfitplane(fused_pc,maxDistance);
    plane1 = select(fused_pc,inlierIndices);
    remainPtCloud = select(fused_pc,outlierIndices);
    
    [model2,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance);
    plane2 = select(remainPtCloud,inlierIndices);
    remainPtCloud = select(remainPtCloud,outlierIndices);


    [model3,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance);
    plane3 = select(remainPtCloud,inlierIndices);
    remainPtCloud = select(remainPtCloud,outlierIndices);

    [model4,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance);
    plane4 = select(remainPtCloud,inlierIndices);
    remainPtCloud = select(remainPtCloud,outlierIndices);
    
    find_ceiling = (rad2deg(acos(abs(model4.Normal*model1.Normal'))) > 60 & (rad2deg(acos(abs(model4.Normal*model2.Normal')))) > 60 & (rad2deg(acos(abs(model4.Normal*model3.Normal')))) > 60)
    model_ceiling = model4;
    plane_ceiling = plane4;
    if ~find_ceiling
        [model5,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance);
        plane5 = select(remainPtCloud,inlierIndices);
        remainPtCloud = select(remainPtCloud,outlierIndices);
        model_ceiling = model5;
        plane_ceiling = plane5;
    end
    
    
    [model_floor,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance, model_ceiling.Normal);
    plane_floor = select(remainPtCloud,inlierIndices);
    remainPtCloud = select(remainPtCloud,outlierIndices);
    
    [model_center_ceiling,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,maxDistance, model_ceiling.Normal);
    plane_center_ceiling = select(remainPtCloud,inlierIndices);
    remainPtCloud = select(remainPtCloud,outlierIndices);
    
    figure(11)
    pcshow(plane1)
    title('First Plane')
    figure(12)
    pcshow(plane2)
    title('Second Plane')
    figure(13)
    pcshow(plane3)
    title('Third Plane')
    if find_ceiling
        figure(14)
        pcshow(plane_ceiling)
        title('Ceiling Surround')
    else
        figure(15)
        pcshow(plane5)
        title('plane5') 
    end
     
    figure(16)
    pcshow(plane_center_ceiling)
    title('center ceiling')
    
    pc_rm_ceiling = pcmerge(remainPtCloud, plane1, 0.01);
    pc_rm_ceiling = pcmerge(pc_rm_ceiling, plane2, 0.01);
    pc_rm_ceiling = pcmerge(pc_rm_ceiling, plane3, 0.01);
    if ~find_ceiling
        pc_rm_ceiling = pcmerge(pc_rm_ceiling, plane4, 0.01);
    end
    pc_rm_ceiling = pcmerge(pc_rm_ceiling, plane_floor, 0.01);
    figure(17)
    pcshow(pc_rm_ceiling)
    title('remove ceiling')
    
% visualization of models
%     hold on
%     plot(model1)
%     hold on
%     plot(model2)
%     hold on
%     plot(model3)
    
    eval_12 = abs(model1.Normal * model2.Normal');
    angle_12 = rad2deg(acos(eval_12))    
    eval_23 = abs(model2.Normal * model3.Normal');
    angle_23 = rad2deg(acos(eval_23))
    eval_13 = abs(model1.Normal * model3.Normal');
    angle_13 = rad2deg(acos(eval_13))
end