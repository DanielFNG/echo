function createScaledModel(settings)
    
% Process static data.
static = [settings.base_dir filesep settings.static_file];
processStaticData(settings.base_dir, static, settings.marker_system);

% Create models directory. 
model_dir = [settings.base_dir filesep settings.model_folder];
mkdir(model_dir);

% Scale model. 
model = [model_dir filesep settings.model_name];
scaleModel(settings.mass, model, static);

end