function createScaledModel(settings)
    
% Process static data.
static = [settings.base_dir filesep settings.static_file];
results = [settings.base_dir filesep settings.static_folder];
mkdir(results);
processStaticData(results, static, settings.marker_system);

% Create models directory. 
model_dir = [settings.base_dir filesep settings.model_folder];
mkdir(model_dir);

% Scale model.
static = [results filesep settings.static_file];
model = [model_dir filesep settings.model_name];
scaleModel(settings.mass, model, static);

end