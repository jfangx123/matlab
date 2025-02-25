function refreshWhenReady( this, options )













R36
this
options.TimeOut = 5;
options.Interval = 0.1;
end 

t = timer(  );
t.ExecutionMode = 'fixedSpacing';
t.TimerFcn = @( t, evt )refresh( t, this );
t.StopFcn = @( t, evt )delete( t );
t.StartDelay = 0;
t.Period = options.Interval;
t.TasksToExecute = options.TimeOut / options.Interval;
t.start(  );
end 

function refresh( t, this )
editor = this.Editor;
if ~isempty( editor ) && isa( editor, 'DAStudio.Explorer' )
dialog = editor.getDialog(  );
if ~isempty( dialog )
node = this.getCurrentTreeNode(  );
ed = DAStudio.EventDispatcher(  );
ed.broadcastEvent( 'ListChangedEvent', node );
ed.broadcastEvent( 'PropertyChangedEvent', node );
t.stop(  );
end 
else 
t.stop(  );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp6FtTJs.p.
% Please follow local copyright laws when handling this file.

