classdef AppTaskFactory < handle






events 
TaskAdded
TaskRemoved
TaskModified
end 

properties ( SetAccess = protected, Hidden = true )
PreprocessingLiveTasksMap
end 
properties ( SetAccess = protected, Dependent = true )
PreprocessingLiveTasks;
end 
methods 
function val = get.PreprocessingLiveTasks( obj )
ca = obj.PreprocessingLiveTasksMap.values;
for i = 1:length( ca )
val( i ) = ca{ i };%#ok<AGROW>
end 
end 
end 

methods ( Access = private )
function obj = AppTaskFactory(  )


obj.PreprocessingLiveTasksMap = containers.Map(  );
end 
end 

methods 
function task = addTask( obj, nvpairs )
R36
obj
nvpairs.Name( 1, 1 )string
nvpairs.Description string
nvpairs.Group( 1, 1 )string
nvpairs.Path( 1, 1 )string
nvpairs.Icon
nvpairs.InputProperty( 1, 1 )string
nvpairs.SecondInputProperty string = string.empty
nvpairs.TableVariableProperty string = string.empty
nvpairs.TableVariableNamesProperty string = string.empty
nvpairs.TableVarVisibilityProp string = string.empty
nvpairs.HasVisualization( 1, 1 )logical = false
nvpairs.ReshapeOutputVariable double = [  ]
nvpairs.IsTimetableProp string = string.empty
nvpairs.HasRowLabelsProp string = string.empty
nvpairs.NumTableVarsProperty string = string.empty
nvpairs.DocFunctions string = string.empty
end 













































import matlab.internal.preprocessingApp.tasks.*;

key = string( nvpairs.Name ) + "-" + string( nvpairs.Group );
if isKey( obj.PreprocessingLiveTasksMap, key )
task = obj.PreprocessingLiveTasksMap( key );
eventType = "TaskModified";
else 
task = struct(  );
eventType = "TaskAdded";
end 
previousTask = task;


task.Name = nvpairs.Name;
task.Description = nvpairs.Description;
task.Group = nvpairs.Group;
task.Path = nvpairs.Path;
task.Icon = nvpairs.Icon;
task.InputProperty = nvpairs.InputProperty;
task.SecondInputProperty = nvpairs.SecondInputProperty;
task.TableVariableProperty = nvpairs.TableVariableProperty;
task.TableVariableNamesProperty = nvpairs.TableVariableNamesProperty;
task.TableVariableVisibleProperty = nvpairs.TableVarVisibilityProp;
task.HasVisualization = nvpairs.HasVisualization;
task.ReshapeOutputVariable = nvpairs.ReshapeOutputVariable;
task.IsTimetableProperty = nvpairs.IsTimetableProp;
task.HasRowLabelsProperty = nvpairs.HasRowLabelsProp;
task.NumberOfTableVariablesProperty = nvpairs.NumTableVarsProperty;
task.DocFunctions = nvpairs.DocFunctions;

task.PreviousTaskData = previousTask;


obj.PreprocessingLiveTasksMap( key ) = task;


eventData = AppTaskEventData;
eventData.Type = eventType;
eventData.Task = task;

try 
obj.notify( eventType, eventData );
catch e
disp( e );
end 
end 

function removeTask( obj, taskName, taskGroup )
import matlab.internal.preprocessingApp.tasks.*;

key = string( taskName ) + "-" + string( taskGroup );
if isKey( obj.PreprocessingLiveTasksMap, key )
task = obj.PreprocessingLiveTasksMap( key );
obj.PreprocessingLiveTasksMap.remove( key );

eventData = AppTaskEventData;
eventData.Type = "TaskRemoved";
eventData.Task = task;
try 
obj.notify( "TaskRemoved", eventData );
catch e
disp( e );
end 
end 
end 

function tasks = getUserAuthoredTasks( obj )

tasks = obj.PreprocessingLiveTasks( strcmp( [ obj.PreprocessingLiveTasks.Group ],  ...
getString( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_USER' ) ) ) );
end 
end 

methods ( Static = true )
function obj = getInstance(  )
import matlab.internal.preprocessingApp.tasks.*;


persistent factory;
if isempty( factory )
factory = AppTaskFactory(  );
factory.registerDefaults(  );
end 

obj = factory;
end 

function factory = registerDefaults( clearBeforeRegistering )
R36
clearBeforeRegistering( 1, 1 )logical = false
end 

import matlab.internal.preprocessingApp.tasks.*;


factory = AppTaskFactory.getInstance;

if clearBeforeRegistering
tasks = factory.PreprocessingLiveTasks;
for i = 1:length( tasks )
factory.removeTask( tasks( i ).Name, tasks( i ).Group );
end 
end 


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_missingDataCleaner_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_missingDataCleaner_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_CLEANING' ) ) ...
, 'Path', "matlab.internal.dataui.missingDataCleaner" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'missingDataCleaner_24px.png' ) ...
, 'InputProperty', "InputDataDropDownValue" ...
, 'TableVariableProperty', "InputDataTableVarDropDownValue" ...
, 'TableVariableNamesProperty', "InputDataTableVarNames" ...
, 'TableVarVisibilityProp', "InputDataTableVarDropDownVisible" ...
, 'HasVisualization', true ...
, 'ReshapeOutputVariable', 2 ...
, 'DocFunctions', [ "ismissing", "rmmissing", "fillmissing" ] ...
 );


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_outlierDataCleaner_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_outlierDataCleaner_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_CLEANING' ) ) ...
, 'Path', "matlab.internal.dataui.outlierDataCleaner" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'outlierDataCleaner_24px.png' ) ...
, 'InputProperty', "InputDataDropDownValue" ...
, 'TableVariableProperty', "InputDataTableVarDropDownValue" ...
, 'TableVariableNamesProperty', "InputDataTableVarNames" ...
, 'TableVarVisibilityProp', "InputDataTableVarDropDownVisible" ...
, 'HasVisualization', true ...
, 'ReshapeOutputVariable', 2 ...
, 'DocFunctions', [ "isoutlier", "rmoutliers", "filloutliers" ] ...
 );


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_dataSmoother_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_dataSmoother_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_CLEANING' ) ) ...
, 'Path', "matlab.internal.dataui.dataSmoother" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'dataSmoother_24px.png' ) ...
, 'InputProperty', "InputDataDropDownValue" ...
, 'TableVariableProperty', "InputDataTableVarDropDownValue" ...
, 'TableVariableNamesProperty', "InputDataTableVarNames" ...
, 'TableVarVisibilityProp', "InputDataTableVarDropDownVisible" ...
, 'HasVisualization', true ...
, 'DocFunctions', "smoothdata" ...
 );


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_tableStacker_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_tableStacker_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_RESHAPING' ) ) ...
, 'Path', "matlab.internal.dataui.tableStacker" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'tableStacker_24px.png' ) ...
, 'InputProperty', "TableDropDownValue" ...
, 'TableVariableNamesProperty', 'StackingVariables' ...
, 'HasVisualization', false ...
, 'ReshapeOutputVariable', 1 ...
, 'DocFunctions', "stack" ...
 );


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_tableUnstacker_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_tableUnstacker_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_RESHAPING' ) ) ...
, 'Path', "matlab.internal.dataui.tableUnstacker" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'tableUnstacker_24px.png' ) ...
, 'InputProperty', "TableDropDownValue" ...
, 'TableVariableNamesProperty', 'TableVarNames' ...
, 'HasVisualization', false ...
, 'ReshapeOutputVariable', 1 ...
, 'DocFunctions', "unstack" ...
 );

















































factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_NormalizeDataTask_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_NormalizeDataTask_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_CLEANING' ) ) ...
, 'Path', "matlab.internal.dataui.NormalizeDataTask" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'NormalizeData_24px.png' ) ...
, 'InputProperty', "InputDataDropDownValue" ...
, 'TableVariableProperty', "InputDataTableVarDropDownValue" ...
, 'TableVariableNamesProperty', "InputDataTableVarNames" ...
, 'TableVarVisibilityProp', "InputDataTableVarDropDownVisible" ...
, 'HasVisualization', true ...
, 'ReshapeOutputVariable', [  ] ...
, 'DocFunctions', "normalize" ...
 );


factory.addTask(  ...
'Name', string( message( 'MATLAB:dataui:Tool_timetableRetimer_Label' ) ) ...
, 'Description', string( message( 'MATLAB:dataui:Tool_timetableRetimer_Description' ) ) ...
, 'Group', string( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_SYNCHRONIZING' ) ) ...
, 'Path', "matlab.internal.dataui.timetableRetimer" ...
, 'Icon', fullfile( matlabroot, 'toolbox', 'matlab', 'dataui', 'resources', 'timetableRetimer_24px.png' ) ...
, 'InputProperty', "TableInputs" ...
, 'TableVariableProperty', string.empty ...
, 'TableVariableNamesProperty', string.empty ...
, 'TableVarVisibilityProp', string.empty ...
, 'HasVisualization', false ...
, 'ReshapeOutputVariable', 1 ...
, 'DocFunctions', "retime" ...
 );
















end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpT5jA2j.p.
% Please follow local copyright laws when handling this file.

