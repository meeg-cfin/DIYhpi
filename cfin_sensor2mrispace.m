function [grad_mri, hpi_err] = cfin_sensor2mrispace(dataset,hpi_mri)
% [grad_mri, hpi_err] = cfin_sensor2mrispace(dataset,hpi_mri)
%
% What it does:
% - extracts the HPI coils and MEG sensors in device coordinates
% - when you supply the HPI coil coordinates in MRI space, it calculates a
%   best-fit transform between device space and MRI space based on the
%   coil locations
% 
% What it does NOT do yet but we should implement someday:
% - the device2mri transform should be enforced as a rigid-body transform,
%   i.e., no scaling/stretching/distorting in case the coordinates are poorly
%   marked or the MRI is distorted.
% - report any goodness-of-fit, etc.
%
% Dependencies: fiff_read_meas_info_cfin.m, rot3dfit.m
%
% Author: Sarang Dalal, CFIN, Aarhus University

hdr = ft_read_header(dataset);

info = fiff_read_meas_info_cfin(dataset); % Sarang's version of this function, which pulls out HPI coords
hdr.grad = ft_convert_units(hdr.grad,'mm'); 

%% convert sensors back to device coordinates.
% (every dataset from same MEG should have same device coodinates!!)
% NB: ft_transform_sens may error out because of overly strict determinant
% threshold. if so, raise threshold!

head2device_xfm = inv(info.dev_head_t.trans); 
head2device_xfm(1:3,4) = head2device_xfm(1:3,4)*1000; % convert to mm 
grad_device = ft_transform_sens(head2device_xfm, hdr.grad);

hpi_device = [info.hpi.r]'*1000; % convert to mm 
hpi_device(5,:) = []; % Aarhus/CFIN generally doesn't use 5th HPI coil

%% need to supply hpi_mri!!! (HPI locations in MRI mm)
[R,T,Yf,Err] = rot3dfit(hpi_device, hpi_mri);

device2mri_xfm = [R' T'; 0 0 0 1];

hpi_device2mri = nmt_transform_coord(device2mri_xfm,hpi_device); % for sanity check

grad_mri = ft_transform_sens(device2mri_xfm, grad_device);

%% plot chanpos and hpi coils in MRI space to confirm they make sens
figure
plot3(grad_mri.chanpos(:,1),grad_mri.chanpos(:,2),grad_mri.chanpos(:,3),'*')
hold on
plot3(hpi_mri(:,1),hpi_mri(:,2),hpi_mri(:,3),'r*')
plot3(hpi_device2mri(:,1),hpi_device2mri(:,2),hpi_device2mri(:,3),'g*')
axis equal

%% co-registration error in mm
hpi_err = zeros(4,1);
for ii=1:4
    hpi_err(ii) = norm(Yf(ii,:)-hpi_mri(ii,:));
    hpi_err = round(hpi_err,3);
end