ccc
%
% Here, we introduce some basic unit functions that will be used throughout this package
%
% 1. Make figures with different positions
% 2. Plot Homogeneous Transformation Matrices (Pre:global / Post:local)
% 3. Coordinate Transforms
% 4. Plot Cube in 3D and Rotate w.r.t. local-z
% 5. Plot 3D arrow and Rotate w.r.t. global-z
% 6. Kinematic Chain and Forward Kinematics
% 7. Get a Transformation Matrix from Three Points in 3D
% 8. Plot Interactive Markers
% 9. Interpolate between Two Rotation Matrices, R1 and R2
% 10. Load URDF and Generate a Kinemactic Chain
% 11. Rodrigues' formula: get R from a constant angular velocity vector
% 12. Solve IK using a numerical method
% 13. Plot Kinematic Chain Structure
% 14. IK with Interactive Markers
% 15. Load CAD and find its bounding cube
% 16. Animate Chain with Linear and Angular Velocities
%
%
%
%% 1. Make figures with different positions
ccc

set_fig_position(figure(1),'position',[0.0,0.6,0.2,0.35],'ADD_TOOLBAR',1,'view_info',[80,16]);
set_fig_position(figure(2),'position',[0.2,0.6,0.2,0.35],'ADD_TOOLBAR',1,'view_info',[80,16]);
set_fig_position(figure(3),'position',[0.4,0.6,0.2,0.35],'ADD_TOOLBAR',1,'view_info',[80,16]);

%% 2. Plot Homogeneous Transformation Matrices
% pre-multiply: global transfrom / post-multiply: local transform
ccc
% Random Transformation Matrix
T_init = pr2t(-0.5+1.0*rand(1,3),rpy2r(360*rand(1,3)));
% Plot figure
vid_obj = init_vid_record('../vid/ut02_homogeneous_transforms.mp4','HZ',40,'SAVE_VID',0);
set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
    'view_info',[80,16],'axis_info',2.0*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
plot_T(T_init,'subfig_idx',2,'alw',1,'als','--','PLOT_AXIS_TIP',0); % plot initial T
plot_T(pr2t([0,0,0],eye(3,3)),'subfig_idx',3,'alen',1.0,'alw',3,'PLOT_AXIS_TIP',0,...
    'PLOT_SPHERE',0); % plot origin
for tick = 1:5:360 % Global rotate w.r.t. x-axis
    T = pr2t([0,0,0],rpy2r(tick*[1,0,0]*D2R))*T_init; % pre-mul
    plot_T(T,'alw',3); plot_title('Global X-rotation'); drawnow; record_vid(vid_obj);
end
for tick = 1:5:360 % Global rotate w.r.t. y-axis
    T = pr2t([0,0,0],rpy2r(tick*[0,1,0]*D2R))*T_init; % pre-mul
    plot_T(T,'alw',3); plot_title('Global Y-rotation'); drawnow; record_vid(vid_obj);
end
for tick = 1:5:360 % Global rotate w.r.t. z-axis
    T = pr2t([0,0,0],rpy2r(tick*[0,0,1]*D2R))*T_init; % pre-mul
    plot_T(T,'alw',3); plot_title('Global Z-rotation'); drawnow; record_vid(vid_obj);
end
for tick = 1:5:360 % Local rotate w.r.t. x-axis
    T = T_init*pr2t([0,0,0],rpy2r(tick*[1,0,0]*D2R)); % post-mul
    plot_T(T,'alw',3); plot_title('Local X-rotation'); drawnow; record_vid(vid_obj);
end
for tick = 1:5:360 % Local rotate w.r.t. y-axis
    T = T_init*pr2t([0,0,0],rpy2r(tick*[0,1,0]*D2R)); % post-mul
    plot_T(T,'alw',3); plot_title('Local Y-rotation'); drawnow; record_vid(vid_obj);
end
for tick = 1:5:360 % Local rotate w.r.t. z-axis
    T = T_init*pr2t([0,0,0],rpy2r(tick*[0,0,1]*D2R)); % post-mul
    plot_T(T,'alw',3); plot_title('Local Z-rotation'); drawnow; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 3. Coordinate Transforms
ccc
T_world_coord = pr2t([0,0,0],eye(3,3)); % 'world coord'
% Randomly determine the initial 'local coord' and 'T_a_local'
T_w2a_coord_init = pr2t(1.0*rand(1,3),rpy2r(360*rand(1,3))); % initital 'local coord'
T_a_p = pr2t([0,0,-1],rpy2r(360*rand(1,3)*D2R)); % position in the 'a coord'

% Set figure
vid_obj = init_vid_record('../vid/ut03_coordinate_transform.mp4','HZ',40,'SAVE_VID',0);
set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
    'view_info',[80,16],'axis_info',2.5*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
plot_T(T_world_coord,'subfig_idx',1,'alen',1.0,'alw',4,'PLOT_AXIS_TIP',1,'atipsize',0.05,...
    'PLOT_SPHERE',1,'sr',0.05,'text_str','World Coord','text_fs',20); % 'world coord'
plot_T(T_w2a_coord_init,'subfig_idx',2,'alen',0.5,'alw',2,'als','--','PLOT_AXIS_TIP',0,...
    'PLOT_SPHERE',1,'sr',0.1,'text_str',''); % 'local coord'
for tick = 1:1:360
    % 1. Change the 'local coord' by rotating w.r.t. the x-axis
    T_w2a_coord = T_w2a_coord_init*pr2t([0,0,0],rpy2r(tick*[1,0,0]*D2R));
    % Pre-multiply the 'local coord' to transfrom 'T_a_local' to the 'world coord'
    T_a = T_w2a_coord * T_a_p;
    % Animate
    plot_line(t2p(T_world_coord),t2p(T_w2a_coord),'subfig_idx',1,...
        'color','k','lw',2,'ls','--','text_str','w2l'); % line from 'world coord' to 'local coord'
    plot_T(T_w2a_coord,'subfig_idx',3,'alen',0.5,'alw',3,'PLOT_AXIS_TIP',1,'atipsize',0.1,...
        'PLOT_SPHERE',1,'sr',0.1,'text_str','Local Coord','text_fs',13); % 'local coord'
    plot_line(t2p(T_w2a_coord),t2p(T_a),'subfig_idx',2,...
        'color','b','lw',1,'ls','--','text_str','l2a'); % line from 'local coord' to 'p_a'
    plot_T(T_a,'subfig_idx',4,'alen',0.3,'alw',3,'atipsize',0.2,...
        'PLOT_SPHERE',1,'sr',0.1,'text_str','T_a'); % T_a in the 'world coord'
    plot_title(sprintf('[%d/%d]',tick,360));
    drawnow; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 4. Plot Cube in 3D and Rotate w.r.t. local-z
ccc

T_world_coord = pr2t([0,0,0],eye(3,3)); % 'world coord'
T_cube_init = pr2t(2*rand(1,3),rpy2r(360*rand(1,3)*D2R)); % 'box coord'

% Set figure
vid_obj = init_vid_record('../vid/ut04_plot_cube_3d.mp4','HZ',40,'SAVE_VID',0);
set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
    'view_info',[80,16],'axis_info',5.0*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
plot_T(T_world_coord,'subfig_idx',1,'alen',1.0,'alw',4,'PLOT_AXIS_TIP',1,'atipsize',0.05,...
    'PLOT_SPHERE',1,'sr',0.05,'text_str','World Coord','text_fs',20); % plot 'world coord'
plot_T(T_cube_init,'subfig_idx',2,'alen',0.5,'alw',3,'als','--','PLOT_AXIS_TIP',1,'atipsize',0.15,...
    'PLOT_SPHERE',1,'sr',0.05,'text_str','Box Coord','text_fs',20); % plot 'box coord'
plot_title('Rotate Cube w.r.t Local Z-axis');
for tick = 1:360
    T_cube = T_cube_init*pr2t([0,0,0],rpy2r(tick*[0,0,1*D2R])); % local z-rotation
    plot_line(t2p(T_world_coord),t2p(T_cube),'subfig_idx',1,...
        'color','k','lw',2,'ls','--','text_str','w2l'); % line from 'world coord' to 'box coord'
    plot_T(T_cube,'subfig_idx',3,'alen',0.5,'alw',3,'PLOT_AXIS_TIP',1,'atipsize',0.15,...
        'PLOT_SPHERE',1,'sr',0.05,'text_str','Box Coord','text_fs',20); % 'box coord'
    plot_cube(T_cube,[0,0,0],[1,2,3],'color','b','alpha',0.2,'edge_color','k'); % plot blue cube
    plot_title(sprintf('[%d/%d]',tick,360));
    drawnow; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 5. Plot 3D arrow and Rotate w.r.t. global-z
ccc

% Position of the tip of the arrow
p_tip_init = [0.5,1.0,1.5];
T_world_coord = pr2t([0,0,0],eye(3,3)); % 'world coord'

% Set figure
vid_obj = init_vid_record('../vid/ut05_plot_arrow_3d.mp4','HZ',40,'SAVE_VID',0);
set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
    'view_info',[80,16],'axis_info',2.0*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
plot_T(T_world_coord,'subfig_idx',1,'alen',1.0,'alw',4,'PLOT_AXIS_TIP',1,'atipsize',0.05,...
    'PLOT_SPHERE',1,'sr',0.05,'text_str','World Coord','text_fs',20); % plot 'world coord'
for tick = 1:360
    T_tip = pr2t([0,0,0],rpy2r(tick*[0,0,1]*D2R))*pr2t(p_tip_init,eye(3,3)); % rotate w.r.t. global z-axis
    p_tip = t2p(T_tip);
    plot_arrow_3d([0,0,0],p_tip,'color','b','alpha',0.4); % plot arrow
    plot_T(T_tip,'subfig_idx',2,'PLOT_AXIS',0,'PLOT_AXIS_TIP',0,...
        'PLOT_SPHERE',1,'sr',0.05,'text_str','Arrow Tip','text_fs',20);
    plot_title(sprintf('[%d/%d]',tick,360));
    drawnow; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 6. Kinematic Chain and Forward Kinematics
%
% Here, we follow the parameters defined by Kajita et al. except we use multiple childs structure.
% We separate joints from links by adapting this multiple childs structure.
%
% Chain.joint contains:
%  name
%  parent
%  childs
%  p
%  R
%  v
%  w
%  q
%  dq
%  ddq
%  a        : joint axis vector (relative to parent)
%  b        : joint relative position (relative to parent)
%
% chain.link containts
%  m        : mass
%  c        : center of mass
%  I        : moment of intertia
%
ccc

% Manually define the kinematic chain
%
% Apply 'p_offset' first w.r.t parent's 'R', and then, apply 'R_offset'
%
chain.name = 'custom chain';
chain.joint(1) = struct('name','world','parent',[],'childs',[2],'p',[0,0,0]','R',eye(3,3),...
    'q',0,'a',[0,0,0]','p_offset',[1,0,0]','R_offset',rpy2r([0,0,0]));
chain.joint(2) = struct('name','j1','parent',[1],'childs',[3],'p',[0,0,0]','R',eye(3,3),...
    'q',0,'a',[0,0,1]','p_offset',[1,0,0]','R_offset',rpy2r([0,-90,0]));
chain.joint(3) = struct('name','j2','parent',[2],'childs',[4],'p',[0,0,0]','R',eye(3,3),...
    'q',0,'a',[0,1,0]','p_offset',[1,0,0]','R_offset',rpy2r([0,0,0]));
chain.joint(4) = struct('name','j3','parent',[3],'childs',[5],'p',[0,0,0]','R',eye(3,3),...
    'q',0,'a',[1,0,0]','p_offset',[1,0,0]','R_offset',rpy2r([0,0,0]));
chain.joint(5) = struct('name','ee','parent',[4],'childs',[],'p',[0,0,0]','R',eye(3,3),...
    'q',0,'a',[0,0,0]','p_offset',[1,0,0]','R_offset',rpy2r([0,0,0]));
chain.n_joint = length(chain.joint);
chain.n_revolute_joint = 2;
chain.joint_names = {'world','j1','j2','j3','ee'};
% Zero pose
chain = update_chain_q(chain,{'j1','j2','j3'},[0,0,0]);
chain = fk_chain(chain);
% Get size of the model
xyz_min = inf*ones(3,1);
xyz_max = -inf*ones(3,1);
for i_idx = 1:chain.n_joint
    xyz_min = min(xyz_min,chain.joint(i_idx).p);
    xyz_max = max(xyz_max,chain.joint(i_idx).p);
end
xyz_len = xyz_max - xyz_min;
chain.xyz_min = xyz_min;
chain.xyz_max = xyz_max;
chain.xyz_len = xyz_len;

vid_obj = init_vid_record('../vid/ut06_kinematic_chain_fk.mp4','HZ',40,'SAVE_VID',0); % init video
max_tick = 360;
traj = nan*ones(max_tick,3);
for tick = 1:max_tick
    
    % Update position in radian
    qs = tick*[1,2,4]*D2R;
    chain = update_chain_q(chain,{'j1','j2','j3'},qs);
    
    % Forward kinematics
    chain = fk_chain(chain);
    
    % Plot Kinematic Chain
    fig = plot_chain(chain,'view_info',[88,4],'axis_info',[-2,+4,-3,+3,-4,+4],...
        'title_str',sprintf('[%d/%d]',tick,max_tick));
    % Plot End-effector
    T_ee = get_chain_T(chain,'ee');
    plot_cube(T_ee,[0.0,-0.2,-0.2],[1.0,0.4,0.4],'color','b','alpha',0.2,'edge_color','k');
    traj(tick,:) = t2p(T_ee)';
    plot_curve_3d(traj(:,1),traj(:,2),traj(:,3),'color',0.5*[1,1,1]);
    
    drawnow limitrate; record_vid(vid_obj);
    if ~ishandle(fig),break;end  % if figure is closed, then stop
end
end_vid_record(vid_obj);

%% 7. Get a Transformation Matrix from Three Points in 3D
ccc

% Three points in 3D
p1 = -1+2*rand(3,1); p2 = -1+2*rand(3,1); p3_init = -1+2*rand(3,1);

vid_obj = init_vid_record('../vid/ut07_transform_from_three_points.mp4','HZ',40,'SAVE_VID',0); % init video

for tick = 1:360
    % Rotate p3
    p3 = rpy2r(tick*[0,0,1]'*D2R)*p3_init;
    % Get a transformation matrix from Three Points
    T = ps2T(p1,p2,p3);
    % Plot
    fig = set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
        'view_info',[80,16],'axis_info',[-2,+2,-2,+2,-2,+2],'SET_DRAGZOOM',1,'GRID_ON',1);
    plot_T(p2t(p1),'subfig_idx',1,'PLOT_AXIS',0,'PLOT_AXIS_TIP',0,'sfc','r','sr',0.05,'sfa',0.9,...
        'text_str','p1'); % plot p1
    plot_T(p2t(p2),'subfig_idx',2,'PLOT_AXIS',0,'PLOT_AXIS_TIP',0,'sfc','g','sr',0.05,'sfa',0.9,...
        'text_str','p2'); % plot p2
    plot_T(p2t(p3),'subfig_idx',3,'PLOT_AXIS',0,'PLOT_AXIS_TIP',0,'sfc','b','sr',0.05,'sfa',0.9,...
        'text_str','p3'); % plot p3
    plot_T(T,'subfig_idx',4,'PLOT_AXIS',1,'alw',4,'PLOT_AXIS_TIP',0,'atipsize',0.05,...
        'sfc','k','sr',0.05,'text_str','T'); % plot T
    plot_plane([p1,p2,p3]','fc','y','ec','k','alpha',0.5);
    plot_title(sprintf('[%d/%d]',tick,360));
    drawnow; record_vid(vid_obj);
    if ~ishandle(fig),break;end  % if figure is closed, then stop
end
end_vid_record(vid_obj);

%% 8. Plot Interactive Markers
ccc
global g_im

% Plot interactive markers
vid_obj = init_vid_record('../vid/ut08_interactive_markers.mp4','HZ',20,'SAVE_VID',0); % init video
fig = set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
    'view_info',[80,16],'axis_info',5*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
plot_interactive_marker('subfig_idx',1,'T',pr2t([0,-2,0],rpy2r(0*rand(1,3))));
plot_interactive_marker('subfig_idx',2,'T',pr2t([0,+2,0],rpy2r(0*rand(1,3))));
tick = 0;
while ishandle(fig)
    tick = tick + 1;
    title_str = sprintf('[%d] p1:%s p2:%s \n',...
        tick,vec2str(t2p(g_im{1}.T)','%.2f'),vec2str(t2p(g_im{2}.T)','%.2f'));
    plot_title(title_str);
    drawnow limitrate; if ishandle(fig), record_vid(vid_obj); end
end
end_vid_record(vid_obj);

%% 9. Interpolate between Two Rotation Matrices, R1 and R2
ccc

R1 = rpy2r(360*rand(1,3)*D2R);
R2 = rpy2r(360*rand(1,3)*D2R);

w = r2w(R1'*R2); % angular velocity in radian
w_hat = scew(w); % make sure to use radian here

vid_obj = init_vid_record('../vid/ut09_interpolate_rotations.mp4','HZ',20,'SAVE_VID',0); % init video

for t = linspace(0,1,100)
    R_t = R1*expm(w_hat*t);
    % Plot
    set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
        'view_info',[80,16],'axis_info',3*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
    plot_T(r2t(R1),'subfig_idx',1,'text_str','R1','TEXT_AT_ZTIP',1);
    plot_T(r2t(R2),'subfig_idx',2,'text_str','R2','TEXT_AT_ZTIP',1);
    plot_T(r2t(R_t),'subfig_idx',3,'alw',3,'PLOT_AXIS_TIP',1,...
        'text_str','R_t','TEXT_AT_ZTIP',1,'text_fs',20,'text_color','b');
    plot_title(sprintf('t:[%.2f]',t));
    drawnow; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 10. Load URDF and Generate a Kinemactic Chain
ccc

% Which model to use
model_name = 'coman'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);
% Plot robot
chain = update_chain_q(chain,chain.rev_joint_names,360*ones(1,chain.n_rev_joint)*D2R);
chain = fk_chain(chain);
fig = plot_chain(chain,'view_info',[88,4],'axis_info','',...
    'PLOT_MESH',1,'PLOT_LINK',1,'PLOT_ROTATE_AXIS',0,'PLOT_JOINT_AXIS',0,...
    'PLOT_JOINT_SPHERE',0,'PRINT_JOINT_NAME',0,...
    'title_str',sprintf('[%s]',chain.name),...
    'MULTIPLE_MONITOR',1,'monitor_idx',1);
plot_T(pr2t([0,0,0]',rpy2r([0,0,0]')),'PLOT_SPHERE',0,'alw',4);
% Animate
for tick = 1:0
    chain = update_chain_q(chain,chain.rev_joint_names,tick*ones(1,chain.n_rev_joint)*D2R);
    chain = fk_chain(chain);
    fig = plot_chain(chain,'view_info',[88,4],'axis_info','',...
        'PLOT_MESH',1,'PLOT_LINK',1,'PLOT_ROTATE_AXIS',0,'PLOT_JOINT_AXIS',0,...
        'PLOT_JOINT_SPHERE',0,'PRINT_JOINT_NAME',0,...
        'title_str',sprintf('[%s][%d]',chain.name,tick));
    drawnow limitrate;
end

%% 11. Rodrigues' formula: get R from a constant angular velocity vector
ccc
rng(0);
a_temp = randn(3,1);
a_init = a_temp / norm(a_temp); % unit vector
q_init = rand; % angular velocity
for tick = 1:5*360 % rotate axis
    a = rpy2r(tick*[0,0,1]'*D2R)*a_init;
    q = q_init;
    R = rodrigues(a,q); % rotation matrix from a and q
    % Plot
    set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
        'view_info',[80,16],'axis_info',3*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
    plot_T(r2t(R),'subfig_idx',1,'text_str','R','TEXT_AT_ZTIP',1);
    plot_arrow_3d([0,0,0]',a*q);
    drawnow
end
for tick = 1:100 % increase the angular velocity
    a = a_init;
    q = q_init*(1+tick/50);
    R = rodrigues(a,q); % rotation matrix from a and q
    % Plot
    set_fig_position(figure(1),'position',[0.5,0.5,0.2,0.35],'ADD_TOOLBAR',1,'AXES_LABEL',1,...
        'view_info',[80,16],'axis_info',3*[-1,+1,-1,+1,-1,+1],'SET_DRAGZOOM',1,'GRID_ON',1);
    plot_T(r2t(R),'subfig_idx',1,'text_str','R','TEXT_AT_ZTIP',1);
    plot_arrow_3d([0,0,0]',a*q);
    drawnow
end

%% 12. Solve IK using a numerical method
ccc

% Get the kinematic chain of the model
model_name = 'coman'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);
chain = update_chain_q(chain,chain.rev_joint_names,zeros(chain.n_rev_joint,1));
chain = fk_chain(chain); % initialize chain

% Initial IK
ik = init_ik(chain);
ik = add_ik(ik,'joint_name','RWrj2',...
    'p',chain.joint(idx_cell(chain.joint_names,'RWrj2')).p,'IK_P',1);
ik = add_ik(ik,'joint_name','LWrj2',...
    'p',chain.joint(idx_cell(chain.joint_names,'LWrj2')).p,'IK_P',1);

% Initialize the Kinematic Chain
q = (ik.joint_limits_lower+ik.joint_limits_upper)/2; % median pose
chain = update_chain_q(chain,ik.joint_names_control,q);
chain = fk_chain(chain); % initialize chain

% Start IK
while (ik.tick < ik.max_tick)
    
    % Run IK
    [ik,chain,q] = onestep_ik(ik,chain,q);
    
    % Check oscilation (limbo) of IK
    [FLAG,ik,best_err] = check_ik_oscilating(ik);
    if FLAG, chain = ik.chain; end
    
    % Plot IK status
    fig = plot_ik_chain(chain,ik);
    
    if FLAG
        fprintf(2,'IK is in Limbo.\n');
        break;
    end
end

%% 13. Plot Kinematic Chain Structure
ccc

% Get the kinematic chain of the model
model_name = 'sawyer'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);

% Plot chain graph
plot_chain_graph(chain);

%% 14. IK with Interactive Markers
ccc
global g_im

% Get the kinematic chain of the model
model_name = 'sawyer'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);

% Configuration
switch model_name
    case 'coman'
        ik_config(1) = struct('name','RWrj2','IK_P',1,'IK_R',0);
        ik_config(2) = struct('name','LWrj2','IK_P',1,'IK_R',0);
        ik_config(3) = struct('name','RElbj','IK_P',1,'IK_R',0);
        ik_config(4) = struct('name','LElbj','IK_P',1,'IK_R',0);
    case 'panda'
        ik_config(1) = struct('name','hand','IK_P',1,'IK_R',1);
    case 'sawyer'
        ik_config(1) = struct('name','right_hand','IK_P',1,'IK_R',1);
end

% Initialize IK with interactive marker
idxs = [];
for i_idx = 1:length(ik_config)
    idxs = union(idxs,get_idx_route(chain,ik_config(i_idx).name)); % all joints to targets
end
idxs = intersect(idxs,chain.rev_joint_idxs); % only for revolute joints
for i_idx = 1:length(ik_config)
    % idxs = setdiff(idxs,idx_cell(chain.joint_names,ik_config(i_idx).name)); % exclude target ones
end
joint_names_control = cell(1,length(idxs));
for i_idx = 1:length(idxs)
    joint_names_control{i_idx} = chain.joint(idxs(i_idx)).name;
end
ik = init_ik(chain,'joint_names_control',joint_names_control,...
    'stepsize',1.0*D2R,'stepsize_min',1.0*D2R,'stepsize_max',5.0*D2R,...
    'stepsize_inc_rate',2.0,'stepsize_dec_rate',0.5);
for i_idx = 1:length(ik_config)
    joint_name = ik_config(i_idx).name;
    ik = add_ik(ik,'joint_name',joint_name,...
        'p',chain.joint(idx_cell(chain.joint_names,joint_name)).p,...
        'R',chain.joint(idx_cell(chain.joint_names,joint_name)).R,...
        'IK_P',ik_config(i_idx).IK_P,'IK_R',ik_config(i_idx).IK_R);
end

% Save video
vid_obj = init_vid_record('../vid/ut14_interactive_ik.mp4','HZ',20,'SAVE_VID',0); % init video

% Plot model and interactive markers
PLOT_LINK = 0; PLOT_JOINT_AXIS = 0; PLOT_JOINT_SPHERE = 0;
fig = plot_chain(chain,'PLOT_LINK',PLOT_LINK,'PLOT_JOINT_AXIS',PLOT_JOINT_AXIS,...
    'PLOT_JOINT_SPHERE',PLOT_JOINT_SPHERE);
for i_idx = 1:ik.n_target
    clen = max(chain.xyz_len)/10;
    plot_interactive_marker('subfig_idx',i_idx,'T',pr2t(ik.targets(i_idx).p,ik.targets(i_idx).R),...
        'clen',clen,'clen_er',1.2,'sr',clen/5);
end

% Run IK
q = get_q_chain(chain,ik.joint_names_control);
while ishandle(fig)
    
    % Run IK
    iclk_ik = clock;
    [ik,chain,q] = onestep_ik(ik,chain,q);
    ems_ik = etime(clock,iclk_ik)*1000;
    
    % Update IK target
    for i_idx = 1:ik.n_target
        T_i = g_im{i_idx}.T;
        [p_i,R_i] = t2pr(T_i);
        ik.targets(i_idx).p = p_i;
        ik.targets(i_idx).R = R_i;
    end
    
    % Animate
    title_str = sprintf('[%d] err:[%.3f] stepsize:[%.2f]deg [%.2f]ms',...
        ik.tick,ik.err,ik.stepsize*R2D,ems_ik);
    fig = plot_chain(chain,'title_str',title_str,'PLOT_LINK',PLOT_LINK,'PLOT_JOINT_AXIS',PLOT_JOINT_AXIS,...
        'PLOT_JOINT_SPHERE',PLOT_JOINT_SPHERE);
    drawnow limitrate; record_vid(vid_obj);
end
end_vid_record(vid_obj);
ca; % close all

%% 15. Load CAD and find its bounding cube
ccc

% Get the kinematic chain of the model
model_name = 'sawyer'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);

for i_idx = 10
    link_i = chain.link(i_idx);
    
    if ~isempty(link_i.fv)
        % Get the bounding cube of the link
        bcube.xyz_min = min(link_i.fv.vertices)';
        bcube.xyz_max = max(link_i.fv.vertices)';
        bcube.xyz_len = bcube.xyz_max - bcube.xyz_min;
        bcube.c_offset = 0.5*(bcube.xyz_max + bcube.xyz_min);
        
        % Plot the CAD mesh and its bounding cube
        % T = pr2t([0,0,0],rpy2r(2*pi*rand(1,3))); % some random position
        T = pr2t(chain.joint(link_i.joint_idx).p,chain.joint(link_i.joint_idx).R); % actual link position
        set_fig_position(figure(1),'position',[0.5,0.6,0.2,0.35],'ADD_TOOLBAR',1,'view_info',[80,16]);
        h = patch('faces',link_i.fv.faces,'vertices',link_i.fv.vertices,...
            'FaceColor',0.5*[1,1,1],'EdgeColor','none','FaceLighting','gouraud',...
            'AmbientStrength',0.2,'FaceAlpha',0.3); % plot CAD
        tf = hgtransform;
        set(h,'parent',tf);
        set(tf,'Matrix',T); % move CAD to T
        plot_cube(T,bcube.xyz_min,bcube.xyz_len,'subfig_idx',i_idx,...
            'color','b','alpha',0.2,'edge_color','k'); % plot cube
        plot_T(T,'subfig_idx',2*i_idx,'alen',0.1,'alw',3,'PLOT_SPHERE',0); % basis axis
        T_com = T*p2t(bcube.c_offset); % CoM transformation in the global coordinates 
        plot_T(T_com,'subfig_idx',1+2*i_idx+1,...
            'PLOT_AXIS',0,'PLOT_SPHERE',1,'sr',0.015,'sfc','r'); % link CoM
        plot_title(link_i.mesh_path);
        
    end
end

%% 16. Animate Chain with Linear and Angular Velocities
ccc

% Get the kinematic chain of the model
model_name = 'sawyer'; % coman / panda / sawyer
urdf_path = sprintf('../urdf/%s/%s_urdf.xml',model_name,model_name);
chain = get_chain_from_urdf(model_name,urdf_path);
chain.dt = 0.05; % set time step 

% Animate
vid_obj = init_vid_record('../vid/ut16_velocities.mp4','HZ',round(1/chain.dt),'SAVE_VID',0); 
max_tick = 180;
vals = [linspace(0,+90,max_tick/2),linspace(90,0,max_tick/2)];
for tick = 1:max_tick
    chain = update_chain_q(chain,chain.rev_joint_names,vals(tick)*ones(chain.n_rev_joint,1)*D2R,...
        'IGNORE_LIMIT',0);
    chain = fk_chain(chain); % forward kinematics
    chain = fv_chain(chain); % forward velocities
    title_str = sprintf('[%.3f]sec Linear Velocity (red) Angular Velocity (blue)',tick*chain.dt);
    plot_chain(chain,'PLOT_LINK',0,'PLOT_ROTATE_AXIS',0,'PLOT_BCUBE',0,'PLOT_COM',1,...
        'PLOT_JOINT_AXIS',0,'PLOT_JOINT_SPHERE',0,'PLOT_VELOCITY',1,'v_rate',0.5,'w_rate',0.3,...
        'title_str',title_str,'view_info',[35,47]);
    drawnow limitrate; record_vid(vid_obj);
end
end_vid_record(vid_obj);

%% 17. 
ccc









































































%%



































