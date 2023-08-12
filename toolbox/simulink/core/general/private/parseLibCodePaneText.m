function [ libFileList, srcFileList, objFileList,  ...
addIncPaths, addLibPaths, addSrcPaths,  ...
preProcDefList, preProcUndefList,  ...
unrecognizedInfo ] = parseLibCodePaneText( libTextCode, blockHandle )


























current_dir = pwd;
if ~isempty( blockHandle )
mdlName = get_param( bdroot( blockHandle ), 'Name' );
mdlFullPathName = which( mdlName );
idx = strfind( mdlFullPathName, mdlName );
mdlFullPath = mdlFullPathName( 1:idx - 1 );
if ( strcmp( current_dir, mdlFullPath ) == 0 )

addSrcPaths = { current_dir };
else 
addSrcPaths = {  };
end 

else 
addSrcPaths = {  };
end 

srcFileList = {  };
libFileList = {  };
objFileList = {  };
addIncPaths = {  };
addLibPaths = {  };
envPathList = {  };

preProcDefList = {  };
preProcUndefList = {  };
unrecognizedInfo = {  };

libTextCode = [ libTextCode, sprintf( '\n' ) ];
newLineIdx = regexp( libTextCode, sprintf( '\n' ) );
if isempty( newLineIdx )
newLineIdx = length( libTextCode ) + 1;
end 

startLineIdx = 1;

for endLineIdx = newLineIdx
[ featureType, parseList ] = parseLibCodePaneTextLine(  ...
libTextCode( startLineIdx:endLineIdx - 1 ) );

switch ( featureType )
case 'libFile', libFileList = { libFileList{ : }, parseList{ : } };
case 'srcFile', srcFileList = { srcFileList{ : }, parseList{ : } };
case 'envPath', envPathList = { envPathList{ : }, parseList{ : } };
case 'objFile', objFileList = { objFileList{ : }, parseList{ : } };
case 'libPath', addLibPaths = { addLibPaths{ : }, parseList{ : } };
case 'srcPath', addSrcPaths = { addSrcPaths{ : }, parseList{ : } };
case 'incPath', addIncPaths = { addIncPaths{ : }, parseList{ : } };
case 'preProc', preProcDefList = { preProcDefList{ : }, parseList{ : } };
case 'prePrcU', preProcUndefList = { preProcUndefList{ : }, parseList{ : } };
otherwise , unrecognizedInfo = { unrecognizedInfo{ : }, parseList{ : } };
end 

startLineIdx = endLineIdx + 1;

end 

if ~isempty( envPathList )
for m = 1:length( envPathList )
[ status, envPathValue ] = getEnvValuePath( envPathList{ m } );
if ( status ~= 0 )
continue ;
end 
if ( envPathValue( end  ) == sprintf( '\n' ) )
envPathValue = envPathValue( 1:end  - 1 );
end 
if ~isempty( addLibPaths )
for k = 1:length( addLibPaths )
addLibPaths{ k } = strrep( addLibPaths{ k }, envPathList{ m }, envPathValue );
end 
end 
if ~isempty( addIncPaths )
for k = 1:length( addIncPaths )
addIncPaths{ k } = strrep( addIncPaths{ k }, envPathList{ m }, envPathValue );
end 
end 
if ~isempty( addSrcPaths )
for k = 1:length( addSrcPaths )
addSrcPaths{ k } = strrep( addSrcPaths{ k }, envPathList{ m }, envPathValue );
end 
end 
end 
end 


function [ status, result ] = getEnvValuePath( envPath )
if isunix
[ status, result ] = system( [ 'echo ', envPath ] );
else 
envPath = strrep( envPath, '$', '' );
[ status, result ] = system( [ 'set ', envPath ] );
if status == 0
result = strrep( result, [ envPath, '=' ], '' );
end 
end 


function [ featureType, parseList ] = parseLibCodePaneTextLine( lineStr )


splittingStr = '\,|\;';
retStr = ' ';

libParseStr = '';
objParseStr = '';
if isunix
libParseStr = '\.((a)|(so))\s*$';
objParseStr = '\.((o))\s*$';
elseif ismac
libParseStr = '\.((a)|(dylib))\s*$';
objParseStr = '\.((o))\s*$';
elseif ispc
libParseStr = '\.((lib))\s*$';
objParseStr = '\.((obj))\s*$';
end 

if ~isempty( regexpi( lineStr, '^\s*INC(LUDE)?_PATH' ) )
featureType = 'incPath';
retStr = regexprep( lineStr, 'INC(LUDE)?_PATH', '', 'ignorecase' );
parseList = splitText( retStr, splittingStr );
elseif ~isempty( regexpi( lineStr, '^\s*LIB(RARY)?_PATH' ) )
featureType = 'libPath';
retStr = regexprep( lineStr, '^\s*LIB(RARY)?_PATH', '', 'ignorecase' );
parseList = splitText( retStr, splittingStr );
elseif ~isempty( regexpi( lineStr, '^\s*ENV_PATH' ) )
featureType = 'envPath';
retStr = regexprep( lineStr, '^\s*ENV_PATH', '', 'ignorecase' );
parseList = splitText( retStr, splittingStr );
elseif ~isempty( regexpi( lineStr, '^\s*SRC_PATH' ) )
featureType = 'srcPath';
retStr = regexprep( lineStr, '^\s*SRC_PATH', '', 'ignorecase' );
parseList = splitText( retStr, splittingStr );
elseif ~isempty( regexpi( lineStr, '^\s*\-D' ) )
featureType = 'preProc';
parseList = splitText( lineStr, [ splittingStr, '|\-(D|d)' ] );
elseif ~isempty( regexpi( lineStr, '^\s*\-U' ) )
featureType = 'prePrcU';
parseList = splitText( lineStr, [ splittingStr, '|\-(U|u)' ] );
elseif ~isempty( regexpi( lineStr, objParseStr ) )
featureType = 'objFile';
parseList = splitText( lineStr, splittingStr );
elseif ~isempty( regexpi( lineStr, '\.c(pp)?\s*$' ) )
featureType = 'srcFile';
parseList = splitText( lineStr, splittingStr );
elseif ~isempty( regexpi( lineStr, libParseStr ) )
featureType = 'libFile';
parseList = splitText( lineStr, splittingStr );
else 
featureType = '';
retStr = lineStr;
parseList = { retStr };
end 

if isempty( parseList )
retStr = lineStr;
parseList = { retStr };
elseif isequal( featureType, 'incPath' ) || isequal( featureType, 'libPath' ) ||  ...
isequal( featureType, 'srcPath' )
for idx = 1:length( parseList )
if ~isempty( parseList{ idx } )
parseList{ idx } = strrep( parseList{ idx }, '$MATLABROOT', matlabroot );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYNJApi.p.
% Please follow local copyright laws when handling this file.

