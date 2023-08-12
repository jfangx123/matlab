function simRFV2TestbenchIQ2IQCallbackFcn( block, action )


top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'BlockDiagramType' ), 'library' )
return ;
end 

idxMaskNames = simrfV2getblockmaskparamsindex( block );
maskObj = get_param( block, 'MaskObject' );
isRunningorPaused = any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) );

switch action
case 'simrfInit'


if ( ~isRunningorPaused )



T_amp_dBm_scL = get_param( block, 'T_amp_dBm_scL' );
T_amp_dBm_scU = get_param( block, 'T_amp_dBm_scU' );
maskObj.Parameters( idxMaskNames.T_amp_dBm ).Range =  ...
[ str2double( T_amp_dBm_scL ), str2double( T_amp_dBm_scU ) ];
maskObj.Parameters( idxMaskNames.T_amp_dBmV ).Range =  ...
[ ( str2double( T_amp_dBm_scL ) + round( 30 + 10 * log10( 50 ) ) ) ...
, ( str2double( T_amp_dBm_scU ) + round( 30 + 10 * log10( 50 ) ) ) ];



blks = simrfV2_findConnected( [ block, '/Configuration' ],  ...
'simrfV2util1/Inport' );
blksInx = cellfun( @( x )strcmpi( get_param( x, 'Name' ),  ...
'Inport1' ), blks );
if ( ~isempty( blksInx ) && any( blksInx ) )
if ~isempty( simrfV2_find_repblk( block, 'Configuration1' ) )
phRepBlk = get_param( [ block, '/Configuration1' ],  ...
'PortHandles' );

simrfV2deletelines( get( phRepBlk.LConn, 'Line' ) )

simrfV2deletelines( get( phRepBlk.RConn, 'Line' ) )
delete_block( [ block, '/Configuration1' ] )
end 
elseif isempty( simrfV2_find_repblk( block, 'Configuration1' ) )
pos = get_param( [ block, '/Configuration' ], 'Position' );
deltaX = pos( 3 ) - pos( 1 );
deltaY = pos( 4 ) - pos( 2 );
pos = pos + [ 2.5 * deltaX, deltaY, 2.5 * deltaX, deltaY ];



src = 'simrfV2util1/Configuration';
Config1Handle = add_block( src,  ...
[ block, '/Configuration1' ], 'Position', pos );
set( Config1Handle,  ...
'StepSize', '(1/Base_bw)/OS',  ...
'Orientation', 'right' )
phConfig1Handle = get( Config1Handle, 'PortHandles' );
phInport1 = get_param( [ block, '/Inport1' ], 'PortHandles' );
add_line( block, phInport1.RConn( 1 ), phConfig1Handle.LConn( 1 ),  ...
'autorouting', 'on' )
end 

end 
return 
otherwise 

MaskVisibilities = get_param( block, 'MaskVisibilities' );
MaskEnables = get_param( block, 'MaskEnables' );

ModeStrLong = get_param( block, 'ModeStrLong' );
ModeStrShort = get_param( block, 'ModeStrShort' );
IPTypeStr = get_param( block, 'IPTypeStr' );
IQMeasureInStr = get_param( block, 'IQMeasureInStr' );
IQMeasureOutStr = get_param( block, 'IQMeasureOutStr' );
uncheckedNoise = ~strcmp( get_param( block, 'SimNoise' ), 'on' );
isVisLong = strcmp( MaskVisibilities{ idxMaskNames.ModeStrLong }, 'on' );
if ( isVisLong )
CurrentModeStr = ModeStrLong;
else 
CurrentModeStr = ModeStrShort;
end 


fullTypeOpts = { 'Gain', 'Noise Floor', 'IP3', 'IP2', 'DC Offset' };
ModeNum = strcmp( fullTypeOpts, CurrentModeStr ) * [ 1, 2, 3, 4, 5 ]';


fullTypeOpts = { 'Input referred', 'Output referred' };
IPTypeNum = strcmp( fullTypeOpts, IPTypeStr ) * [ 1, 2 ]';


fullTypeOpts = {  ...
'I and Q (Q = -1j * I)',  ...
'I and Q (Q = 1j * I)',  ...
'I only (Q = 0)',  ...
'Q only (I = 0)' };
IQMeasureInNum = strcmp( fullTypeOpts, IQMeasureInStr ) * [ 1, 2, 3, 4 ]';


fullTypeOpts = { 'I', 'Q' };
IQMeasureOutNum = strcmp( fullTypeOpts, IQMeasureOutStr ) * [ 1, 2 ]';

switch action
case 'NoiseboxCallback'


if ( ~isRunningorPaused )
if ( ( uncheckedNoise ) && ( isVisLong ) )


set_param( [ block, '/Configuration' ], 'AddNoise', 'off' )
set_param( block, 'ModeStrShort', ModeStrLong )

MaskVisibilities{ idxMaskNames.ModeStrLong } = 'off';
MaskVisibilities{ idxMaskNames.ModeStrShort } = 'on';
set_param( block, 'MaskVisibilities', MaskVisibilities )
set_param( block, 'ModeStrShort', ModeStrLong )
set_param( block, 'ModeStrLong', ModeStrLong )
elseif ( ( ~uncheckedNoise ) && ( ~isVisLong ) )



set_param( [ block, '/Configuration' ], 'AddNoise', 'on' )
set_param( block, 'ModeStrLong', ModeStrShort )

MaskVisibilities{ idxMaskNames.ModeStrLong } = 'on';
MaskVisibilities{ idxMaskNames.ModeStrShort } = 'off';
set_param( block, 'MaskVisibilities', MaskVisibilities )
set_param( block, 'ModeStrLong', ModeStrShort )
set_param( block, 'ModeStrShort', ModeStrShort )
end 
end 
case 'LongPulldownModeCallback'


if ( ~isRunningorPaused )
if strcmp( get_param( block, 'ModeStrLong' ), 'Noise Floor' )
MaskEnables{ idxMaskNames.SimNoise } = 'off';
else 
MaskEnables{ idxMaskNames.SimNoise } = 'on';
end 
set_param( block, 'MaskEnables', MaskEnables )
end 
if ( str2double( get_param( block, 'Mode' ) ) ~= ModeNum )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'ShortPulldownModeCallback'
if ( str2double( get_param( block, 'Mode' ) ) ~= ModeNum )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'IQMeasureInCallback'
if ( str2double( get_param( block, 'IQMeasureIn' ) ) ~=  ...
IQMeasureInNum )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'IQMeasureOutCallback'
if ( str2double( get_param( block, 'IQMeasureOut' ) ) ~=  ...
IQMeasureOutNum )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'T_amp_dBmCallback'
if isnan( str2double( get_param( block, 'T_amp_dBm' ) ) )
error( message(  ...
'simrf:simrfV2errors:TestbenchInputNotNumeric',  ...
'''Input power amplitude (dBm)''', '''T_amp_dBm''' ) )
end 
T_amp_dBmV = num2str( str2double(  ...
get_param( block, 'T_amp_dBm' ) ) ...
 + round( 30 + 10 * log10( 50 ) ) );
if ( ~strcmpi( get_param( block, 'T_amp_dBmV' ), T_amp_dBmV ) )
set_param( block, 'T_amp_dBmV', T_amp_dBmV )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'T_amp_dBmVCallback'
if isnan( str2double( get_param( block, 'T_amp_dBmV' ) ) )
error( message(  ...
'simrf:simrfV2errors:TestbenchInputNotNumeric',  ...
'''Input RMS voltage (dBmV)''', '''T_amp_dBmV''' ) )
end 
T_amp_dBm = num2str( str2double(  ...
get_param( block, 'T_amp_dBmV' ) ) - round( 30 + 10 * log10( 50 ) ) );
if ( ~strcmpi( get_param( block, 'T_amp_dBm' ), T_amp_dBm ) )
set_param( block, 'T_amp_dBm', T_amp_dBm )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
case 'ResetButtonCallback'
if ( ~strcmpi( get_param( bdroot( gcb ), 'BlockDiagramType' ),  ...
'library' ) )
set_param( gcb, 'Reset', '1' )
set_param( gcb, 'ResetableRand', num2str( rand, '%.16e' ) )
end 
end 



set_param( block, 'Mode', num2str( ModeNum ) )
set_param( block, 'IPType', num2str( IPTypeNum ) )
set_param( block, 'IQMeasureIn', num2str( IQMeasureInNum ) )
set_param( block, 'IQMeasureOut', num2str( IQMeasureOutNum ) )


EmptyText6 = maskObj.getDialogControl( 'EmptyText6' );
EmptyText7 = maskObj.getDialogControl( 'EmptyText7' );
ResetContainer = maskObj.getDialogControl( 'ResetContainer' );
MaskVisibilities = get_param( block, 'MaskVisibilities' );
InstText = maskObj.getDialogControl( 'InstText' );
EmptyText10 = maskObj.getDialogControl( 'EmptyText10' );
EmptyText11 = maskObj.getDialogControl( 'EmptyText11' );


if any( strcmpi( get_param( bdroot( block ), 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
suggestionStr1 = 'stop the simulation, ';
suggestionStr1IP3 = 'stop the simulation, and ';
suggestionStr2 = ', and run the simulation again';
suggestionStr2IP3 = '. Then run the simulation again';
else 
suggestionStr1 = '';
suggestionStr1IP3 = '';
suggestionStr2 = '';
suggestionStr2IP3 = '';
end 


switch ModeNum
case 1
MaskVisibilities{ idxMaskNames.T_amp_dBm } = 'on';
MaskVisibilities{ idxMaskNames.T_amp_dBmV } = 'off';
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'off';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'off';
EmptyText7.Visible = 'off';
MaskVisibilities{ idxMaskNames.IPTypeStr } = 'off';
EmptyText10.Visible = 'on';
EmptyText11.Visible = 'on';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate gain measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the gain ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. For high input power, the measured gain ' ...
, 'may be affected by nonlinearities of the Device Under ' ...
, 'Test (DUT) and differ from the gain calculated in the RF ' ...
, 'budget app. In this case, use the knob to reduce the ' ...
, 'input power amplitude value until the resulting gain ' ...
, 'value settles down.\n\n' ];
string_out{ 3 } = [ '3. Other discrepancies between the measured ' ...
, 'gain and that calculated in the RF budget app may ' ...
, 'originate from the more realistic account of the DUT ' ...
, 'performance obtained using RF Blockset simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
string_out{ 4 } = '';
case 2
MaskVisibilities{ idxMaskNames.T_amp_dBm } = 'on';
MaskVisibilities{ idxMaskNames.T_amp_dBmV } = 'off';
ResetContainer.Visible = 'on';
EmptyText6.Visible = 'off';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'off';
EmptyText7.Visible = 'off';
MaskVisibilities{ idxMaskNames.IPTypeStr } = 'off';
EmptyText10.Visible = 'on';
EmptyText11.Visible = 'on';
string_out{ 1 } = [ '1. Correct calculation of the spot noise ' ...
, 'floor (NFloor) assumes a frequency-independent system ' ...
, 'within the given bandwidth. Please ', suggestionStr1 ...
, 'reduce the Baseband bandwidth until this condition is ' ...
, 'fulfilled', suggestionStr2, '. In common RF systems, the ' ...
, 'bandwidth should be reduced below 1 KHz for NFloor testing.\n\n' ];
string_out{ 2 } = [ '2. For high input power, the measured NFloor ' ...
, 'may be affected by nonlinearities of the Device Under ' ...
, 'Test (DUT) and differ from the NFloor calculated in the RF ' ...
, 'budget app. In this case, use the knob to reduce the ' ...
, 'input power amplitude value until the resulting NFloor value ' ...
, 'settles down. \n\n' ];
string_out{ 3 } = [ '3. Other discrepancies between the ' ...
, 'measured NFloor and that calculated in the RF budget app may ' ...
, 'originate from the more realistic account of the DUT ' ...
, 'performance obtained using RF Blockset simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
string_out{ 4 } = '';
case 3
MaskVisibilities{ idxMaskNames.T_amp_dBm } = 'on';
MaskVisibilities{ idxMaskNames.T_amp_dBmV } = 'off';
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'on';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'on';
EmptyText7.Visible = 'on';
MaskVisibilities{ idxMaskNames.IPTypeStr } = 'on';
EmptyText10.Visible = 'off';
EmptyText11.Visible = 'off';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate IP3 measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the IP3 ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. Correct calculation of the IP3 assumes ' ...
, 'a frequency-independent system in the frequencies ' ...
, 'surrounding the test tones. Please ', suggestionStr1IP3 ...
, 'either reduce the frequency separation between the test ' ...
, 'tones (by reducing the ''Ratio of test tone frequency to ' ...
, 'baseband bandwidth''), or reduce the Baseband ' ...
, 'bandwidth itself until this condition is fulfilled' ...
, suggestionStr2IP3, '. In common RF systems, the bandwidth ' ...
, 'should be reduced below 1 KHz for IP3 testing.\n\n' ];
string_out{ 3 } = [ '3. For high input power, the measured IP3 ' ...
, 'may be affected by nonlinearities of the ' ...
, 'Device Under Test (DUT) and differ from the IP3 ' ...
, 'calculated in the RF budget app. In this case, use the ' ...
, 'knob to reduce the input power amplitude value until the ' ...
, 'resulting IP3 value settles down.\n\n' ];
string_out{ 4 } = [ '4. Other discrepancies between the ' ...
, 'measured IP3 and that calculated in the RF budget app ' ...
, 'may originate from the more realistic account of the DUT ' ...
, 'performance obtained using RF Blockset simulation. In this ' ...
, 'case, verify that the DUT performance is evaluated ' ...
, 'correctly using RF budget calculations. For more ' ...
, 'details, see the RF budget app documentation.' ];
case 4
MaskVisibilities{ idxMaskNames.T_amp_dBm } = 'on';
MaskVisibilities{ idxMaskNames.T_amp_dBmV } = 'off';
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'on';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'on';
EmptyText7.Visible = 'on';
MaskVisibilities{ idxMaskNames.IPTypeStr } = 'on';
EmptyText10.Visible = 'off';
EmptyText11.Visible = 'off';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate IP2 measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the IP2 ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. Correct calculation of the IP2 assumes ' ...
, 'a frequency-independent system in the frequencies ' ...
, 'surrounding the test tones. Please ', suggestionStr1IP3 ...
, 'either reduce the frequency separation between the test ' ...
, 'tones (by reducing the ''Ratio of test tone frequency to ' ...
, 'baseband bandwidth''), or reduce the Baseband ' ...
, 'bandwidth itself until this condition is fulfilled' ...
, suggestionStr2IP3, '. In common RF systems, the bandwidth ' ...
, 'should be reduced below 1 KHz for IP2 testing.\n\n' ];
string_out{ 3 } = [ '3. For high input power, the measured IP2 ' ...
, 'may be affected by high-order nonlinearities of the ' ...
, 'Device Under Test (DUT) and differ from expected values. In this ' ...
, 'case, use the knob to reduce the input power amplitude ' ...
, 'value until the resulting IP3 value settles down.\n\n' ];
string_out{ 4 } = [ '4. Other discrepancies between the ' ...
, 'measured and expected IP2 values may originate from the ' ...
, 'realistic account of the DUT performance obtained using ' ...
, 'RF Blockset simulation. In this case, verify that the DUT ' ...
, 'performance is evaluated correctly using RF budget ' ...
, 'calculations. For more details, see the RF budget app ' ...
, 'documentation.' ];
case 5
MaskVisibilities{ idxMaskNames.T_amp_dBm } = 'off';
MaskVisibilities{ idxMaskNames.T_amp_dBmV } = 'on';
ResetContainer.Visible = 'off';
EmptyText6.Visible = 'on';
MaskVisibilities{ idxMaskNames.F_tone_over_Base_bw } = 'on';
EmptyText7.Visible = 'off';
MaskVisibilities{ idxMaskNames.IPTypeStr } = 'off';
EmptyText10.Visible = 'on';
EmptyText11.Visible = 'on';
if ( strcmp( get_param( block, 'SimNoise' ), 'on' ) )
string_out{ 1 } = [ '1. For accurate DC offset measurement, please ' ...
, suggestionStr1, 'uncheck the ''Simulate noise'' checkbox' ...
, suggestionStr2, '.\n\n' ];
else 
string_out{ 1 } = [ '1. To account for noise in the DC offset ' ...
, 'measurement, please ', suggestionStr1, 'check the ' ...
, '''Simulate noise'' checkbox', suggestionStr2, '.\n\n' ];
end 
string_out{ 2 } = [ '2. Correct calculation of the DC offset assumes ' ...
, 'a frequency-independent system in the frequencies ' ...
, 'surrounding the test tones. Please ', suggestionStr1IP3 ...
, 'either reduce the frequency separation between the test ' ...
, 'tones (by reducing the ''Ratio of test tone frequency to ' ...
, 'baseband bandwidth''), or reduce the Baseband ' ...
, 'bandwidth itself until this condition is fulfilled' ...
, suggestionStr2IP3, '. In common RF systems, the bandwidth ' ...
, 'should be reduced below 1 KHz for DC offset testing.\n\n' ];
string_out{ 3 } = [ '3. For high input voltage, the measured DC offset ' ...
, 'may be affected by nonlinearities of the ' ...
, 'Device Under Test (DUT) and differ from expected values. In this ' ...
, 'case, use the knob to reduce the input RMS voltage ' ...
, 'value until the resulting DC offset value settles down.\n\n' ];
string_out{ 4 } = [ '4. Other discrepancies between the ' ...
, 'measured and expected DC offset values may originate from the ' ...
, 'realistic account of the DUT performance obtained using ' ...
, 'RF Blockset simulation. In this case, verify that the DUT ' ...
, 'performance is evaluated correctly using RF budget ' ...
, 'calculations. For more details, see the RF budget app ' ...
, 'documentation.' ];
end 


newInstText = sprintf( cell2mat( string_out ) );
if ( ~strcmp( InstText.Prompt, newInstText ) )
InstText.Prompt = newInstText;
end 
set_param( block, 'MaskVisibilities', MaskVisibilities )
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp24QC4c.p.
% Please follow local copyright laws when handling this file.

