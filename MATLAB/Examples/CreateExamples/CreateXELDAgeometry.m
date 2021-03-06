%% This creates the geometry for ray tracing in XELDA
%
%

grids_names = {'Cathode','Gate','Anode','Top'};
grids_origin = zeros(4,3);
grids_pitch = zeros(4) + .5; % distance between opposite sides of hexagon
grids_wirerad = zeros(4) + .05;
grids_orientation = zeros(4);
grid_phase = 'llgg';


n_xenon = 1;
n_gxenon = 1;

abslength_xenon = 1;
abslength_gxenon = 10;

scatlength_xenon = 1;
scatlength_gxenon = 10;

%% derived quantities
grids_hexside = grids_pitch / sqrt(3);
grids_origin(2,1) = 2*grids_hexside(2);
grids_origin(3,1) = grids_hexside(3);

%%
surface_list = struct( ...
    'description', {}, ...
    'intersect_function', {}, ...
    'inbounds_function', {}, ...
    'n_outside', {}, ...
    'n_inside', {}, ...
    'surface_type', {}, ...
    'absorption', {}, ...
    'abslength_outside', {}, ...
    'abslength_inside', {}, ...
    'rayleigh_outside', {}, ...
    'rayleigh_inside', {}, ...
    'unifiedparams', {});

% Make some hexagonal grids by magic (or trig)
for i_g=1:size(grids_origin)
    surface_list(end+1).description = sprintf('Grid:  %s',grids_names{i_g});
    surface_list(end).intersect_function = @(sp,indir)RayToPlane(sp,indir, ...
        grids_origin(i_g,:), [0, 0, 1]);
    surface_list(end).inbounds_function = @(p)(reshape( ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g)), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g)) + .5*grids_pitch(i_g), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) | ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g) + (2*pi/3)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g) + (2*pi/3)), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g) + (2*pi/3)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g) + (2*pi/3)) + .5*grids_pitch(i_g), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) | ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g) - (2*pi/3)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g) - (2*pi/3)), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g) - (2*pi/3)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g) - (2*pi/3)) + .5*grids_pitch(i_g), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) | ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g)) + 1.5*grids_hexside(i_g), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g)), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) | ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g) + (2*pi/3)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g) + (2*pi/3)) + 1.5*grids_hexside(i_g), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g) + (2*pi/3)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g) + (2*pi/3)), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) | ...
        ((mod((p(:,1,:)-grids_origin(i_g,1))*cos(grids_orientation(i_g) - (2*pi/3)) + (p(:,2,:)-grids_origin(i_g,2))*sin(grids_orientation(i_g) - (2*pi/3)) + 1.5*grids_hexside(i_g), 3*grids_hexside(i_g)) < grids_hexside(i_g)) & ...
        (abs(mod((p(:,1,:)-grids_origin(i_g,1))*sin(grids_orientation(i_g) - (2*pi/3)) - (p(:,2,:)-grids_origin(i_g,2))*cos(grids_orientation(i_g) - (2*pi/3)), grids_pitch(i_g)) - .5*grids_pitch(i_g)) < grids_wirerad(i_g))) ...
        , size(p,1), []));
    surface_list(end).n_outside = (n_xenon*(grid_phase(i_g)=='l')) + (n_gxenon*(grid_phase(i_g)=='g'));
    surface_list(end).n_inside = (n_xenon*(grid_phase(i_g)=='l')) + (n_gxenon*(grid_phase(i_g)=='g'));
    surface_list(end).surface_type = 'normal';
    surface_list(end).absorption = 1; % call grids black
    surface_list(end).abslength_outside = (abslength_xenon*(grid_phase(i_g)=='l')) + (abslength_gxenon*(grid_phase(i_g)=='g')); % photons shouldn't get there
    surface_list(end).abslength_inside = (abslength_xenon*(grid_phase(i_g)=='l')) + (abslength_gxenon*(grid_phase(i_g)=='g')); % xenon
    surface_list(end).rayleigh_outside = (scatlength_xenon*(grid_phase(i_g)=='l')) + (scatlength_gxenon*(grid_phase(i_g)=='g')); % photons shouldn't get there
    surface_list(end).rayleigh_inside = (scatlength_xenon*(grid_phase(i_g)=='l')) + (scatlength_gxenon*(grid_phase(i_g)=='g'));
    surface_list(end).unifiedparams = zeros(1,5);
end
