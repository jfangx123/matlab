function saveIpCoreAdditionalSourceFileToModel( obj, modelName, additionalSourceFile )


if ( ~obj.isMLHDLC ) && ( obj.isIPCoreGen ) &&  ...
~downstream.tool.isDUTTopLevel( modelName ) && ~downstream.tool.isDUTModelReference( modelName )
if ~obj.getloadingFromModel
if ~strcmp( hdlget_param( modelName, 'IPCoreAdditionalFiles' ), additionalSourceFile )
hdlset_param( modelName, 'IPCoreAdditionalFiles', additionalSourceFile );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUq3KKZ.p.
% Please follow local copyright laws when handling this file.

