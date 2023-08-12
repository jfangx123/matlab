function subsysCap = slmaskedcaps( block )










if ~strcmpi( get_param( block, 'Mask' ), 'on' )
DAStudio.error( 'Simulink:bcst:ErrOnlyMasks', mfilename );
end 

maskType = get_param( block, 'MaskType' );


[ maskStr, trans ] = getMaskStr( maskType );


if isempty( maskType ) &&  ...
strcmpi( get_param( block, 'Mask' ), 'on' ) &&  ...
strcmpi( get_param( block, 'BlockType' ), 'SubSystem' ) &&  ...
isSublibrary( block )
maskStr = '';
end 


subsysCap = bcstCreateCap( block, maskStr, trans );

if ~isempty( subsysCap.Modes )

if strcmp( maskType, 'PID 1dof' ) || strcmp( maskType, 'PID 2dof' )
subsysCap.CurrentMode = get_param( block, 'TimeDomain' );
end 

end 


function [ subsysCapStr, trans ] = getMaskStr( maskType )

persistent maskTable transTable;
if isempty( maskTable )
[ maskTable, transTable ] = getMaskTable;
end 

if isempty( maskType )

subsysCapStr = '';
trans = transTable;
else 

findMask = find( strcmp( maskType, maskTable( :, 2 ) ) );
if ~isempty( findMask )

if length( findMask ) > 1
subsysCapStr = maskTable( findMask, 1 );
else 
subsysCapStr = maskTable{ findMask, 1 };
end 
trans = transTable;
else 
DAStudio.error( 'Simulink:bcst:ErrMaskNotFound', maskType, mfilename );
end 
end 



function [ maskTable, transTable ] = getMaskTable



transTable.d = 'double';
transTable.s = 'single';
transTable.b = 'boolean';
transTable.i = 'integer';
transTable.f = 'fixedpt';
transTable.e = 'enumerated';
transTable.B = 'bus';
transTable.c = 'codegen';
transTable.p = 'production';
transTable.m = 'multidimension';
transTable.v = 'variablesize';
transTable.I = 'foreach';
transTable.S = 'symbolicdimension';
transTable.t = 'string';
transTable.M = 'image';
transTable.z = 'zerocrossing';
transTable.D = 'directfeedthrough';
transTable.C = 'simcgdiagnostic';
transTable.h = 'half';
transTable.E = 'eventsemantics';



























maskTable = {  ...
 ...
 ...
 ...
'd;s;i;f;c.FnConsiderMdlDiscr,FnAbsTimeInTrig,FnReliesOnMemOp;p;I', 'PID 1dof'; ...
'(Continuous-time)d;c.FnConsiderMdlDiscr,FnNot4ProdCode;I', 'PID 1dof'; ...
'(Discrete-time)d;s;i;f;c.FnAbsTimeInTrig,FnReliesOnMemOp;p;I', 'PID 1dof'; ...
'd;s;i;f;c.FnConsiderMdlDiscr,FnAbsTimeInTrig,FnReliesOnMemOp;p;I', 'PID 2dof'; ...
'(Continuous-time)d;c.FnConsiderMdlDiscr,FnNot4ProdCode;I', 'PID 2dof'; ...
'(Discrete-time)d;s;i;f;c.FnAbsTimeInTrig,FnReliesOnMemOp;p;I', 'PID 2dof'; ...
 ...
'd;c.FnNotInsideTrig;p;I', 'Band-Limited White Noise.'; ...
'd;c;I', 'chirp'; ...
'd-FnOnlyTrueFloat;s-FnOnlyTrueFloat;i;f;c;I', 'Counter Free-Running'; ...
'd-FnOnlyTrueFloat;s-FnOnlyTrueFloat;b;i;f;c;I',  ...
'Counter Limited'; ...
'c;p;e;m;I;S', 'Enumerated Constant'; ...
'd;c;I', 'Ramp'; ...
'd;c.FnUseRepSeqBlock', 'Repeating table'; ...
'd;s;b;i;f;c.FnNotInsideTrig;p;I', 'Repeating Sequence Interpolated'; ...
'd;s;b;i;f;e;c;p;I', 'Repeating Sequence Stair'; ...
'd;c;I;z', 'Sigbuilder block'; ...
'd;s;b;i;f;c', 'WaveformGenerator'; ...
'd;s;b;i;f;e;B;c;m;t;z;h', 'SignalEditor'; ...
 ...
'd;s;b;i;f;e;c-FnIgnoredCodeGen', 'XY scope.'; ...
 ...
'd;c.FnConsiderMdlDiscr,FnNot4ProdCode;I', 'PWM'; ...
 ...
'd;s;b.FnBoolNotRec;i;f;c;p;v;I;h', 'Difference'; ...
'd;s;i;f;c.FnAbsTimeInTrig,FnReliesOnMemOp;p;v;I;D', 'Discrete Derivative'; ...
'd;c;I;D', 'First-Order Hold'; ...
'd;s;b.FnBoolNotRec;i;f;c;p;v;I', 'Lead or Lag Compensator'; ...
'd;s;i;f;c;p;v;I', 'First Order Transfer Fcn'; ...
'd;s;b;i;f;c;p', 'Tapped Delay Line'; ...
'd;s;b.FnBoolNotRec;i;f;c;p;v;I', 'Transfer Fcn Real Zero'; ...
 ...
'd;I', 'Algebraic Constraint'; ...
'd;s;b;i;f;c;p;I', 'MinMax Running Resettable'; ...
'd;s;b;i;f;c;p;m;v;I', 'Slider Gain'; ...
 ...
'd;s;b;i;f;c;p;I;S;D;h', 'Transpose'; ...
'd;s;i;f;c;p;I;S;D;h', 'HermitianTranspose'; ...
'd;s;i;f;c;p;I;D;h', 'Matrix Square'; ...
'd;s;b;i;f;c;p;I;D;h', 'CrossProduct'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Submatrix'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Permute Matrix'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;I', 'Extract Diagonal'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;I', 'Create Diagonal Matrix'; ...
'd;s;i.BaseIntOnlySigned;f.BaseIntOnlySigned;c;p;I;v', 'Array-Vector Add'; ...
'd;s;i.BaseIntOnlySigned;f.BaseIntOnlySigned;c;p;I;v', 'Array-Vector Subtract'; ...
 ...
'b.FnBitOpNotBool;i;f;c;p;m;I;D', 'Bit Clear'; ...
'b.FnBitOpNotBool;i;f;c;p;m;I;D', 'Bit Set'; ...
'd;s;b;i;f;e;c;p;m;v;I;S;z;D;h', 'Compare To Constant'; ...
'd;s;b;i;f;c;p;m;v;I;S;z;D;h', 'Compare To Zero'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Change'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Decrease'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Increase'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Fall Negative'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Fall Nonpositive'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Rise Nonnegative'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;m;v;I;D', 'Detect Rise Positive'; ...
'd;s;b;i;f;c;p;m;I;D', 'Extract Bits'; ...
'd;s;b;i;f;e;c;p;m;I;D', 'Interval Test'; ...
'd;s;b;i;f;e;c;p;m;I;D', 'Interval Test Dynamic'; ...
'd;s;i;f;c;p;I', 'Shift Arithmetic'; ...
'd;s;b;i;f.comm_Fniu1,comm_Fnoasic;c;p;v;I', 'Bit to Integer Converter'; ...
'd;s;b;i;f.comm_Fnou1;c;p;v;I', 'Integer to Bit Converter'; ...
 ...
'd;s;b;i;f;e;B;c;m;I;h', 'Environment Controller'; ...
'd;s;b;i;f;e;B;c;m;v;I;D', 'Manual Switch'; ...
 ...
'd;s;b;i;f;e;c;p;m;v;I;D;h', 'Conversion Inherited'; ...
'd;s;b;i;f;c;p;m;v;I;D', 'Scaling Strip'; ...
 ...
'd;s;i;f;c;p;I', 'Coulombic and Viscous Friction'; ...
'd;s;i;f;c;p;I;D', 'Dead Zone Dynamic'; ...
'd;s;i;f;c;p;I', 'Rate Limiter Dynamic'; ...
'd;s;b.FnBoolNotRec;i;f;c;p;I', 'Saturation Dynamic'; ...
'd;s;b;i;f;c;p;m;I;D', 'Wrap To Zero'; ...
 ...
'd;s;b;i;f;c;p;I', 'Sine and Cosine'; ...
 ...
'd;s;b;i;c;p;v', 'Stateflow'; ...
'd;s;b;i;f;c;p;m', 'S-Function Builder'; ...
 ...
'd;s;b;i;f;e;c;m;h', 'Checks_DGap'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_DRange'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_SGap'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_SRange'; ...
'd;s;i;f;c;m', 'Checks_Gradient'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_DMin'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_DMax'; ...
'd;c;m', 'Checks_Resolution'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_SMin'; ...
'd;s;b;i;f;e;c;m;h', 'Checks_SMax'; ...
 ...
'd;s;b;i;f;c;p;m;v;I', 'Atomic Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I', 'Code Reuse Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;z', 'Enabled Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;z', 'Enabled And Triggered Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;D', 'For Iterator Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I', 'Function-Call Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I', 'If Action Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I', 'Virtual Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;z', 'Switch Case Action Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;z', 'Triggered Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;D', 'While Iterator Subsystem'; ...
 ...
'd;s;i;f;c;p;v;I', 'Real World Value Decrement'; ...
'd;s;i;f;c;p;v;I;D', 'Stored Integer Value Decrement'; ...
'd;s;i;f;c;p;I', 'Decrement Time To Zero'; ...
'd;s;i;f;c;p;I;D', 'Decrement To Zero'; ...
'd;s;i;f;c;p;v;I;D', 'Real World Value Increment'; ...
'd;s;i;f;c;p;m;v;I;D', 'Stored Integer Value Increment'; ...
 ...
'd;s;b.FnBoolNotRec;i;f;c;p;v;I', 'Fixed-Point State-Space'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay Enabled'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;I', 'Unit Delay Enabled External Initial Condition'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay Enabled Resettable'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;I', 'Unit Delay Enabled Resettable External Initial Condition'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;v;I', 'Unit Delay External Initial Condition'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay Resettable'; ...
'd;s;b;i;f;c.FnReliesOnMemOp;p;I', 'Unit Delay Resettable External Initial Condition'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay With Preview Enabled'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay With Preview Enabled Resettable'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay With Preview Enabled Resettable External RV'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay With Preview Resettable'; ...
'd;s;b;i;f;e;c.FnReliesOnMemOp;p;I', 'Unit Delay With Preview Resettable External RV'; ...
'd;s;i;f;c.FnReliesOnMemOp;p;I', 'Transfer Fcn Direct Form II'; ...
'd;s;b.FnBoolNotRec;i;f;c.FnReliesOnMemOp;p;I', 'Transfer Fcn Direct Form II Time Varying'; ...
 ...
 ...
 ...
'd;s;b;i;f;c;p', 'Integer Delay'; ...
'd;s;b;i;f;c', 'Weighted Moving Average'; ...
 ...
'd;s;i;f;c;p;m;I', 'Unary Minus'; ...
 ...
'b.FnBitOpNotBool;i;f;c;p;m;I;S', 'Bitwise Operator'; ...
 ...
'd;s;b;i;f;c;p;m;v;I;h;S', 'Data Type Propagation'; ...
'd;s;b;i;f;c;p;m', 'Sample Time Math'; ...
 ...
'd;s;b;i;f;c;p;m;D', 'Lookup Table Dynamic'; ...
 ...
'c;p;I;E', 'Function-Call Generator'; ...
 ...
'c;p', 'CMBlock'; ...
'c;p', 'DocBlock'; ...
'c;p', 'Block Support Table'; ...
'd;s;b;i;f', 'Triggered Linearization'; ...
'', 'Timed Linearization'; ...
 ...
'd;s;b;i;f;c;p;m;v;I;z;E', 'Message Triggered Subsystem'; ...
'd;s;b;i;f;c;p;m;v;I;z;E', 'Message Polling Subsystem'; ...
 };



function isSubLib = isSublibrary( block )

sublibs = {  ...
'simulink/Sources',  ...
'simulink/Sinks',  ...
'simulink/Continuous',  ...
'simulink/Discrete',  ...
'simulink/Discontinuities',  ...
'simulink/Signal Routing',  ...
'simulink/Signal Attributes',  ...
'simulink/Math Operations',  ...
'simulink/Matrix Operations',  ...
'simulink/Logic and Bit Operations',  ...
'simulink/Lookup Tables',  ...
'simulink/User-Defined Functions',  ...
'simulink/Model Verification',  ...
'simulink/Ports & Subsystems',  ...
'simulink/Model-Wide Utilities',  ...
'simulink/Blocksets & Toolboxes',  ...
'simulink/Commonly Used Blocks',  ...
'simulink/Additional Math & Discrete',  ...
'simulink/Additional Math & Discrete/Additional Math: Increment - Decrement',  ...
'simulink/Additional Math & Discrete/Additional Discrete',  ...
'simulink/Demos' };


nameSp = regexprep( [ get_param( block, 'Parent' ), '/', get_param( block, 'Name' ) ],  ...
'\s', ' ' );


isSubLib = any( strcmp( nameSp, sublibs ) );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpERu93N.p.
% Please follow local copyright laws when handling this file.

