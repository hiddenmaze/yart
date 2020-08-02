function chain_model = get_chain_model_with_cache(model_name,varargin)
%
% Get chain_model with cache
%


% Parse options
p = inputParser;
addParameter(p,'RE',false); % redo loading
addParameter(p,'cache_folder','../cache'); % folder to caache
addParameter(p,'urdf_folder','../urdf'); % root folder contains URDF subfolders
parse(p,varargin{:});
RE = p.Results.RE;
cache_folder = p.Results.cache_folder;
urdf_folder = p.Results.urdf_folder;


% Cache file
cache_path = sprintf('%s/model/urdf_%s.mat',cache_folder,model_name);
[p,~,~] = fileparts(cache_path);
make_dir_if_not_exist(p);

if exist(cache_path,'file') && (RE==0)
    l = load(cache_path); % load 
    chain_model = l.chain_model; 
else
    
    % Parse URDF
    urdf_path = sprintf('%s/%s/%s_urdf.xml',urdf_folder,model_name,model_name);
    chain_model = get_chain_from_urdf(model_name,urdf_path,'CENTER_ROBOT',1);
    
    % Optimize capsules
    for i_idx = 1:chain_model.n_link % for each link
        link_i = chain_model.link(i_idx);
        fv_i = link_i.fv;
        if ~isempty(fv_i)
            cap_opt_i = optimize_capsule(fv_i); % optimize capsule (takes time)
        else
            cap_opt_i = '';
        end
        chain_model.link(i_idx).capsule = cap_opt_i;
    end
    
    % Self-Collision Check
    chain_model.sc_checks = get_sc_checks(chain_model);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % Save
    save(cache_path,'chain_model');
    fprintf(2,'[%s] saved.\n',cache_path);
end







